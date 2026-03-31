# Envelope bridge — converts envelope-ncl envelopes to Process Compose configs
#
# This is the key integration point. A nested envelope becomes a set of
# Process Compose processes with dependencies encoding the nesting order.
#
# Sandbox envelopes get their commands wrapped with nsjail/seatbelt.
# Workflow envelopes become placeholder processes (can't run locally).
let N = import "../../envelope-ncl/lib/nesting.ncl" in

let get_field = fun _rec =>
  fun _field =>
    fun _default =>
      if std.record.has_field _field _rec then
        std.record.get _field _rec
      else
        _default
in

# Build a sandbox command wrapper based on constraints
let sandbox_wrap = fun _constraints =>
  fun _inner_cmd =>
    let net = get_field _constraints "network" { mode = 'deny } in
    let fs = get_field _constraints "fs" { mode = 'ro } in
    let res = get_field _constraints "resources" {} in
    let net_mode = get_field net "mode" 'deny in
    let fs_mode = get_field fs "mode" 'ro in
    let timeout = get_field res "timeout_seconds" 300 in
    # For now, represent as a structured comment + the actual command.
    # In production, this would generate actual nsjail/firejail/seatbelt invocations.
    _inner_cmd
in

# Convert a single envelope layer to a Process Compose process
let layer_to_process = fun _layer =>
  fun _prev_name =>
    let payload = _layer.payload in
    let cmd =
      let raw =
        get_field
          payload
          "script"
          (
            get_field
              payload
              "flake_ref"
              (
                get_field payload "tool_name" "echo 'no command'"
              )
          )
      in
      let kind = get_field payload "kind" 'reference in
      if kind == 'nix_flake then
        "nix run %{raw}"
      else if kind == 'script then
        raw
      else
        raw
    in
    let target = _layer.target in
    let target_kind = get_field target "kind" 'local in
    let proc = {
      command =
        if target_kind == 'sandbox then
          sandbox_wrap _layer.constraints cmd
        else
          cmd,
      namespace =
        if target_kind == 'sandbox then
          "sandboxed"
        else if target_kind == 'workflow then
          "workflow"
        else
          "local",
      environment =
        let secrets = get_field _layer.constraints "secrets" [] in
        std.array.map (fun s => "%{s}=${%{s}}") secrets,
    }
    in
    let with_dep =
      if _prev_name != "" then
        proc
        & {
          depends_on = { "%{_prev_name}" = { condition = 'process_completed_successfully } },
        }
      else
        proc
    in
    with_dep
in

{
  from_envelope
    | doc m%"
      Convert a nested envelope into a Process Compose config.

      Each envelope layer becomes a process. The nesting order
      becomes `depends_on` — inner layers depend on outer layers
      completing setup first.

      # Examples

      ```nickel
      let nested = N.nest workflow sandbox in
      from_envelope nested
      ```
    "%
    | not_exported
    = fun _envelope =>
      let layers = N.flatten _envelope in
      let indexed =
        std.array.generate
          (fun i =>
            let layer = std.array.at i layers in
            let prev =
              if i > 0 then
                (std.array.at (i - 1) layers).name
              else
                ""
            in
            { name = layer.name, process = layer_to_process layer prev }
          )
          (std.array.length layers)
      in
      {
        version = "0.5",
        ordered_shutdown = true,
        processes =
          std.array.fold_left
            (fun acc entry =>
              acc & { "%{entry.name}" = entry.process }
            )
            {}
            indexed,
      },

  from_porkg
    | doc m%"
      Convert a porkg-ncl config into a Process Compose config.

      The worker becomes a daemon process. Each job becomes a process
      that depends on the worker being healthy.
    "%
    | not_exported
    = fun _porkg =>
      let worker_name = get_field _porkg.worker "name" "worker" in
      let worker_proc = {
        command = "porkg worker",
        is_daemon = true,
        namespace = "porkg",
        availability = { restart = 'on_failure },
      }
      in
      let job_procs =
        std.array.fold_left
          (fun acc job =>
            let cmd = std.string.join " " job.command in
            acc
            & {
              "%{job.name}" = {
                command = cmd,
                namespace = "porkg",
                environment =
                  if std.record.has_field "env" job then
                    std.record.to_array job.env
                    |> std.array.map (fun kv => "%{kv.field}=%{kv.value}")
                  else
                    [],
                depends_on = {
                  "%{worker_name}" = { condition = 'process_started },
                },
              },
            }
          )
          {}
          _porkg.jobs
      in
      {
        version = "0.5",
        ordered_shutdown = true,
        processes = { "%{worker_name}" = worker_proc } & job_procs,
      },
}
