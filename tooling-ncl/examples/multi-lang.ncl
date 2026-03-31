# Multi-language pipeline
#
# Shows that nodes can be different languages — the pipeline
# doesn't care, it just wires stdin/stdout between them.
let B = import "../lib/builders.ncl" in
let P = import "../lib/pipe.ncl" in

let generate =
  B.python "generate" "import json; print(json.dumps([{'name': f'item-{i}', 'value': i*10} for i in range(5)]))"
  |> B.sandboxed
  & { description = "Generate test data in Python" }
in

let filter =
  B.nushell "filter" "from json | where value > 20 | to json"
  |> B.sandboxed
  & { description = "Filter in nushell" }
in

let format =
  B.bash "format" "jq -r '.[] | \"\\(.name): \\(.value)\"'"
  |> B.sandboxed
  & { description = "Format as text in bash/jq" }
in

P.pipeline "multi-lang" [generate, filter, format]
