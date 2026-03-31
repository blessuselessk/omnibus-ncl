# Schema — JSON Schema contracts and compatibility checking
#
# Provides a proper JsonSchema contract and a compatibility check
# that verifies one schema's output can feed another's input.
{
  JsonSchema
    | doc m%"
      JSON Schema (Draft 7 subset) for CodeNode input/output.

      Must specify at least a `type` field. Object types should
      fully define `properties` and `required`.
    "%
    | not_exported
    = {
      type
        | doc "JSON Schema type"
        | [| 'object, 'array, 'string, 'number, 'integer, 'boolean, 'null |],
      properties
        | doc "Object properties (when type = object)"
        | { .. }
        | optional,
      required
        | doc "Required property names"
        | Array String
        | optional,
      items
        | doc "Array item schema (when type = array)"
        | { .. }
        | optional,
      description
        | doc "Human-readable description"
        | String
        | optional,
      enum
        | doc "Allowed values"
        | Array Dyn
        | optional,
      ..
    },

  # -- Schema compatibility --

  types_compatible
    | doc m%"
      Check if an output type can feed an input type.

      Rules:
      - Same type: always compatible
      - object→object: compatible (property check is deeper)
      - any→any with input type unspecified: compatible (permissive input)
      - mismatch: incompatible
    "%
    | not_exported
    = fun _output =>
      fun _input =>
        let out_type =
          if std.record.has_field "type" _output then
            _output.type
          else
            'object
        in
        let in_type =
          if std.record.has_field "type" _input then
            _input.type
          else
            'object
        in
        out_type == in_type,

  properties_compatible
    | doc m%"
      Check if output properties satisfy input required fields.

      The output must have at least every field the input requires.
    "%
    | not_exported
    = fun _output =>
      fun _input =>
        let out_props =
          if std.record.has_field "properties" _output then
            std.record.fields _output.properties
          else
            []
        in
        let in_required =
          if std.record.has_field "required" _input then
            _input.required
          else
            []
        in
        std.array.all
          (fun req => std.array.any (fun p => p == req) out_props)
          in_required,

  schemas_compatible
    | doc m%"
      Full compatibility check between an output schema and an input schema.

      Returns true if the output can feed the input:
      1. Types must match
      2. Output must provide all required input properties

      # Examples

      ```nickel
      schemas_compatible
        { type = 'object, properties = { name = {}, age = {} } }
        { type = 'object, required = ["name"] }
      # => true (output has "name")
      ```
    "%
    | not_exported
    = fun _output =>
      fun _input =>
        types_compatible _output _input
        && properties_compatible _output _input,

  CompatibleSchemas
    | doc m%"
      Contract that validates schema compatibility between two nodes.

      Applied to a record { output_schema, input_schema }.
      Fails if the output can't feed the input.
    "%
    | not_exported
    =
      std.contract.from_predicate (fun value =>
        schemas_compatible value.output_schema value.input_schema
      ),
}
