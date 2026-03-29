# Builder functions for codemode tool definitions
#
# Ergonomic API for constructing JSON Schema records and tool descriptors.
# All builders produce plain serializable records (no enum tags, no functions
# in output). Use these instead of writing raw JSON Schema by hand.
{
  # -- Leaf type builders --------------------------------------------------

  string_field
    | doc "Build a { type: \"string\" } schema with description"
    | not_exported
    = fun desc => { type = "string", description = desc },

  number_field
    | doc "Build a { type: \"number\" } schema with description"
    | not_exported
    = fun desc => { type = "number", description = desc },

  integer_field
    | doc "Build a { type: \"integer\" } schema with description"
    | not_exported
    = fun desc => { type = "integer", description = desc },

  boolean_field
    | doc "Build a { type: \"boolean\" } schema with description"
    | not_exported
    = fun desc => { type = "boolean", description = desc },

  # -- Compound type builders ----------------------------------------------

  enum_field
    | doc "Build a { type: \"string\", enum: [...] } schema with description"
    | not_exported
    = fun desc =>
      fun values => { type = "string", description = desc, enum = values },

  array_field
    | doc "Build a { type: \"array\" } schema with description and item schema"
    | not_exported
    = fun desc =>
      fun items_schema =>
        { type = "array", description = desc, items = items_schema },

  # -- Object schema builders ----------------------------------------------

  object_schema
    | doc m%"
      Build an object schema from properties and required field names.

      Example:
        object_schema { name = string_field "Name" } ["name"]
    "%
    | not_exported
    = fun props =>
      fun req =>
        {
          type = "object",
          properties = props,
          required = req,
        },

  object_schema_optional
    | doc "Build an object schema where all fields are optional (empty required)"
    | not_exported
    = fun props =>
      {
        type = "object",
        properties = props,
      },

  # -- Tool descriptor builders --------------------------------------------

  tool
    | doc m%"
      Build a tool descriptor from description and input schema.

      Example:
        tool "Create a project" (object_schema { name = string_field "Name" } ["name"])
    "%
    | not_exported
    = fun desc =>
      fun input =>
        {
          description = desc,
          inputSchema = input,
        },

  tool_with_output
    | doc "Build a tool descriptor with both input and output schemas"
    | not_exported
    = fun desc =>
      fun input =>
        fun output =>
          {
            description = desc,
            inputSchema = input,
            outputSchema = output,
          },
}
