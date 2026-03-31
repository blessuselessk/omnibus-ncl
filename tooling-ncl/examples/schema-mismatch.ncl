# Schema mismatch — this SHOULD fail at export time
#
# Node A outputs a string, Node B expects an object.
# The pipeline contract catches this before anything runs.
let B = import "../lib/builders.ncl" in
let P = import "../lib/pipe.ncl" in

let produces_string =
  B.bash "to-string" "echo hello"
  |> B.with_schemas
    { type = 'object }
    { type = 'string, description = "Plain text output" }
in

let expects_object =
  B.bash "parse-object" "jq .name"
  |> B.with_schemas
    { type = 'object, properties = { name = { type = 'string } }, required = ["name"] }
    { type = 'string }
in

# This should fail: string output can't feed object input
P.pipe produces_string expects_object
