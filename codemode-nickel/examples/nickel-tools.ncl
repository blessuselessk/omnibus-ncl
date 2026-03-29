# Nickel tool definitions — the nickel.* provider tools
#
# These are the tool schemas the LLM sees via TypeScript type declarations.
# Export as JSON to feed into generateTypesFromJsonSchema().
let B = import "../lib/builders.ncl" in
let { NickelToolSet, .. } = import "../lib/nickel.ncl" in

{
  export = B.nickel_export,
  validate = B.nickel_validate,
  format = B.nickel_format,
  typecheck = B.nickel_typecheck,
  query = B.nickel_query,
  eval = B.nickel_eval,
}
  | NickelToolSet
