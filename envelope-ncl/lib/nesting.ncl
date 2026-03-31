# Nesting — monotonic restriction enforcement for composed envelopes
#
# The core rule: inner constraints <= outer constraints.
# Network: deny < localhost < whitelist < full
# Filesystem: none < ro < whitelist < rw
# Resources: inner limits <= outer limits
#
# The `restrict` function takes outer constraints and an inner envelope,
# clamping the inner's constraints to not exceed the outer's.
let { Constraints, .. } = import "constraints.ncl" in

let network_rank = fun _mode =>
  _mode
  |> match {
    'deny => 0,
    'localhost => 1,
    'whitelist => 2,
    'full => 3,
  }
in

let fs_rank = fun _mode =>
  _mode
  |> match {
    'none => 0,
    'ro => 1,
    'whitelist => 2,
    'rw => 3,
  }
in

let min_num = fun _a =>
  fun _b =>
    if _a <= _b then _a else _b
in

let rank_to_network = fun _rank =>
  if _rank <= 0 then
    'deny
  else if _rank <= 1 then
    'localhost
  else if _rank <= 2 then
    'whitelist
  else
    'full
in

let rank_to_fs = fun _rank =>
  if _rank <= 0 then
    'none
  else if _rank <= 1 then
    'ro
  else if _rank <= 2 then
    'whitelist
  else
    'rw
in

# Default constraint values for normalization
let default_network = { mode = 'deny, allowed_hosts = [] } in
let default_fs = { mode = 'ro, allowed_paths = [] } in
let default_resources = {
  max_memory_mb = 256,
  max_cpu_seconds = 60,
  max_file_descriptors = 128,
  timeout_seconds = 300,
}
in

# Normalize a constraints record by filling in missing fields with defaults
let get_field = fun _rec =>
  fun _field =>
    fun _default =>
      if std.record.has_field _field _rec then
        std.record.get _field _rec
      else
        _default
in

let norm_net = fun _c =>
  let raw = get_field _c "network" default_network in
  {
    mode = get_field raw "mode" 'deny,
    allowed_hosts = get_field raw "allowed_hosts" [],
  }
in

let norm_fs = fun _c =>
  let raw = get_field _c "fs" default_fs in
  {
    mode = get_field raw "mode" 'ro,
    allowed_paths = get_field raw "allowed_paths" [],
  }
in

let norm_res = fun _c =>
  let raw = get_field _c "resources" default_resources in
  {
    max_memory_mb = get_field raw "max_memory_mb" 256,
    max_cpu_seconds = get_field raw "max_cpu_seconds" 60,
    max_file_descriptors = get_field raw "max_file_descriptors" 128,
    timeout_seconds = get_field raw "timeout_seconds" 300,
  }
in

{
  restrict
    | doc m%"
      Clamp inner constraints to not exceed outer constraints.

      Enforces monotonic restriction:
      - Network mode: min(outer, inner)
      - Filesystem mode: min(outer, inner)
      - Allowed hosts: intersection (inner filtered by outer)
      - Allowed paths: intersection (inner filtered by outer)
      - Resources: min of each limit
      - Env/secrets: passed through from inner (outer controls at runtime)

      # Examples

      ```nickel
      let outer = { network = { mode = 'localhost }, fs = { mode = 'ro } } in
      let inner = { network = { mode = 'full }, fs = { mode = 'rw } } in
      restrict outer inner
      # => { network = { mode = 'localhost, ... }, fs = { mode = 'ro, ... }, ... }
      ```
    "%
    | not_exported
    = fun _outer =>
      fun _inner =>
        let o_net = norm_net _outer in
        let i_net = norm_net _inner in
        let o_fs = norm_fs _outer in
        let i_fs = norm_fs _inner in
        let o_res = norm_res _outer in
        let i_res = norm_res _inner in
        let net_mode =
          rank_to_network (min_num (network_rank o_net.mode) (network_rank i_net.mode))
        in
        let fs_mode =
          rank_to_fs (min_num (fs_rank o_fs.mode) (fs_rank i_fs.mode))
        in
        {
          network = {
            mode = net_mode,
            allowed_hosts =
              if std.array.length o_net.allowed_hosts == 0 then
                i_net.allowed_hosts
              else if std.array.length i_net.allowed_hosts == 0 then
                o_net.allowed_hosts
              else
                std.array.filter
                  (fun h => std.array.any (fun oh => oh == h) o_net.allowed_hosts)
                  i_net.allowed_hosts,
          },
          fs = {
            mode = fs_mode,
            allowed_paths =
              if std.array.length o_fs.allowed_paths == 0 then
                i_fs.allowed_paths
              else if std.array.length i_fs.allowed_paths == 0 then
                o_fs.allowed_paths
              else
                std.array.filter
                  (fun p => std.array.any (fun op => op == p) o_fs.allowed_paths)
                  i_fs.allowed_paths,
          },
          resources = {
            max_memory_mb = min_num o_res.max_memory_mb i_res.max_memory_mb,
            max_cpu_seconds = min_num o_res.max_cpu_seconds i_res.max_cpu_seconds,
            max_file_descriptors = min_num o_res.max_file_descriptors i_res.max_file_descriptors,
            timeout_seconds = min_num o_res.timeout_seconds i_res.timeout_seconds,
          },
          env = get_field _inner "env" [],
          secrets = get_field _inner "secrets" [],
        },

  nest
    | doc m%"
      Compose two envelopes — place inner inside outer.

      The outer envelope's payload becomes a wrapper that runs the inner.
      The inner's constraints are clamped to not exceed the outer's.
      Returns a new envelope with the inner nested inside.

      # Examples

      ```nickel
      let sandbox_env = { name = "sandbox", ... } in
      let tool_env = { name = "jq-tool", ... } in
      nest sandbox_env tool_env
      # => { name = "sandbox", ..., inner = { name = "jq-tool", constraints = <restricted>, ... } }
      ```
    "%
    | not_exported
    = fun _outer =>
      fun _inner =>
        let restricted_constraints = restrict _outer.constraints _inner.constraints in
        let inner_without_constraints = std.record.remove "constraints" _inner in
        _outer
        & {
          inner =
            inner_without_constraints
            & { constraints = restricted_constraints },
        },

  flatten
    | doc m%"
      Export a nested envelope as a flat array of layers (outermost first).

      Useful for serialization and inspection — each layer is a record
      with name, payload, constraints, and target (no inner field).
    "%
    | not_exported
    = fun _envelope =>
      let this_layer = {
        name = _envelope.name,
        payload = _envelope.payload,
        constraints = _envelope.constraints,
        target = _envelope.target,
      }
      in
      if std.record.has_field "inner" _envelope then
        [this_layer] @ (flatten _envelope.inner)
      else
        [this_layer],
}
