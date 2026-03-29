# JSON Schema Draft 7 contracts — the subset used by @cloudflare/codemode
#
# These contracts validate that Nickel records conform to the JSON Schema
# shape expected by generateTypesFromJsonSchema(). Only the subset actually
# used by codemode tool definitions is modeled here.
{
  JsonSchemaTypeString
    | doc m%"
      Validates a JSON Schema `type` string.
      Allowed: "string", "number", "integer", "boolean", "object", "array", "null".
    "%
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.array.elem
          val
          [
            "string",
            "number",
            "integer",
            "boolean",
            "object",
            "array",
            "null",
          ]
      ),

  JsonSchema
    | doc m%"
      Contract for a JSON Schema Draft 7 object.

      Covers the subset used by codemode: type, properties, required,
      enum, items, description, default, format, additionalProperties.
      Open record (`{ .. }`) to allow additional JSON Schema fields.
    "%
    | not_exported
    = {
      type | JsonSchemaTypeString | optional,
      properties | { _ : JsonSchema } | optional,
      required | Array String | optional,
      enum | Array String | optional,
      items | JsonSchema | optional,
      description | String | optional,
      default | Dyn | optional,
      format | String | optional,
      additionalProperties | Dyn | optional,
      ..
    },
}
