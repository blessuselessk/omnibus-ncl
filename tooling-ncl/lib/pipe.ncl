# Pipe — compose CodeNodes into pipelines
#
# pipe connects two nodes: A's output feeds B's input.
# pipeline chains an array of nodes.
# The output is a Pipeline record with the nodes and their wiring.
let { CodeNode, .. } = import "node.ncl" in
let { schemas_compatible, .. } = import "schema.ncl" in

# Contract: validates that adjacent nodes have compatible schemas.
# Applied to the nodes array — checked when the pipeline is exported.
let ValidChain =
  std.contract.from_predicate (fun nodes =>
    let len = std.array.length nodes in
    if len <= 1 then
      true
    else
      std.array.all
        (fun i =>
          if i < len - 1 then
            let a = std.array.at i nodes in
            let b = std.array.at (i + 1) nodes in
            schemas_compatible a.output_schema b.input_schema
          else
            true
        )
        (std.array.generate (fun i => i) len)
  )
in

{
  Pipeline
    | doc m%"
      An ordered sequence of CodeNodes where each node's output
      feeds the next node's input. Schema compatibility is checked
      at pipeline construction time.
    "%
    | not_exported
    = {
      name | String,
      nodes | Array CodeNode | ValidChain,
      description | String | optional,
    },

  pipe
    | doc m%"
      Connect two CodeNodes — A's output feeds B's input.

      Validates schema compatibility at export time via the
      ValidChain contract on the Pipeline.nodes field.

      # Examples

      ```nickel
      pipe node_a node_b
      ```
    "%
    | not_exported
    = fun _a =>
      fun _b =>
        {
          name = "%{_a.name}|%{_b.name}",
          nodes | ValidChain = [_a, _b],
        },

  pipeline
    | doc m%"
      Chain an array of CodeNodes into a Pipeline.

      Validates schema compatibility between every adjacent pair
      at export time via the ValidChain contract.

      # Examples

      ```nickel
      pipeline "my-pipe" [node_a, node_b, node_c]
      ```
    "%
    | not_exported
    = fun _name =>
      fun _nodes =>
        {
          name = _name,
          nodes | ValidChain = _nodes,
        },

  to_process_compose
    | doc m%"
      Export a Pipeline as a process-compose config.

      Each node becomes a process, piped via files:
      node_0 writes to /tmp/pipe-0.json, node_1 reads it, etc.
    "%
    | not_exported
    = fun _pipeline =>
      let nodes = _pipeline.nodes in
      let indexed =
        std.array.generate
          (fun i =>
            let node = std.array.at i nodes in
            let prev_file =
              if i > 0 then
                "/tmp/pipeline-%{_pipeline.name}-%{std.to_string (i - 1)}.json"
              else
                ""
            in
            let out_file = "/tmp/pipeline-%{_pipeline.name}-%{std.to_string i}.json" in
            let cmd =
              node.lang
              |> match {
                'bash => node.code,
                'nickel => "nickel eval '%{node.code}'",
                'nushell => "nu -c '%{node.code}'",
                'python => "python3 -c '%{node.code}'",
                'javascript => "node -e '%{node.code}'",
              }
            in
            let wrapped =
              if prev_file != "" then
                "%{cmd} < %{prev_file} > %{out_file}"
              else
                "%{cmd} > %{out_file}"
            in
            {
              name = node.name,
              process = {
                command = wrapped,
                depends_on =
                  if i > 0 then
                    let prev = std.array.at (i - 1) nodes in
                    { "%{prev.name}" = { condition = 'process_completed_successfully } }
                  else
                    {},
                environment =
                  if std.record.has_field "env" node then
                    std.record.to_array node.env
                    |> std.array.map (fun kv => "%{kv.field}=%{kv.value}")
                  else
                    [],
              },
            }
          )
          (std.array.length nodes)
      in
      {
        version = "0.5",
        ordered_shutdown = true,
        processes =
          std.array.fold_left
            (fun acc entry => acc & { "%{entry.name}" = entry.process })
            {}
            indexed,
      },

  to_shell_script
    | doc m%"
      Export a Pipeline as a single bash script.

      Each node's code runs in sequence, piping stdout to stdin.
    "%
    | not_exported
    = fun _pipeline =>
      let nodes = _pipeline.nodes in
      let lines =
        std.array.generate
          (fun i =>
            let node = std.array.at i nodes in
            let cmd =
              node.lang
              |> match {
                'bash => node.code,
                'nickel => "nickel eval '%{node.code}'",
                'nushell => "nu -c '%{node.code}'",
                'python => "python3 -c '%{node.code}'",
                'javascript => "node -e '%{node.code}'",
              }
            in
            cmd
          )
          (std.array.length nodes)
      in
      {
        script =
          "#!/usr/bin/env bash\nset -euo pipefail\n\n"
          ++ std.string.join " \\\n  | " lines
          ++ "\n",
      },
}
