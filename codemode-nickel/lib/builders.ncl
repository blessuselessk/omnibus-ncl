# Builders for codemode-nickel tool definitions and project scaffolding
#
# Three layers:
#   1. Base field builders (from codemode-ncl)
#   2. Nickel tool builders (nickel.export, nickel.validate, etc.)
#   3. Project scaffolding builders (contract files, builder files, examples)
let base = import "../_deps/codemode-ncl/lib/builders.ncl" in

base
& {
  # -- Nickel tool builders ------------------------------------------------
  # These produce JsonSchemaToolDescriptor records for the nickel.* provider.

  nickel_export
    | doc "Tool: export a .ncl file to JSON/YAML/TOML/text"
    | not_exported
    = {
      description = "Export a Nickel file to the specified format. Returns the exported content or an error with diagnostics.",
      inputSchema =
        base.object_schema
          {
            path = base.string_field "Path to the .ncl file",
            format =
              base.enum_field
                "Output format"
                ["json", "yaml", "toml", "text"],
            field = base.string_field "Export a specific field (optional)",
          }
          ["path"],
    },

  nickel_validate
    | doc "Tool: validate a .ncl file without exporting"
    | not_exported
    = {
      description = "Check if a Nickel file evaluates without errors. Returns { valid: true } or { valid: false, error: '...' }.",
      inputSchema =
        base.object_schema
          {
            path = base.string_field "Path to the .ncl file",
          }
          ["path"],
    },

  nickel_format
    | doc "Tool: format a .ncl file in place"
    | not_exported
    = {
      description = "Format a Nickel file using the canonical style. Returns { formatted: true } or an error.",
      inputSchema =
        base.object_schema
          {
            path = base.string_field "Path to the .ncl file",
            check = {
              type = "boolean",
              description = "Check only, don't modify (default: false)",
            },
          }
          ["path"],
    },

  nickel_typecheck
    | doc "Tool: typecheck a .ncl file"
    | not_exported
    = {
      description = "Run Nickel's typechecker on a file. Returns diagnostics for type and contract errors.",
      inputSchema =
        base.object_schema
          {
            path = base.string_field "Path to the .ncl file",
          }
          ["path"],
    },

  nickel_query
    | doc "Tool: query a field from a .ncl file"
    | not_exported
    = {
      description = "Query a specific field from a Nickel file. Returns the field's value, type, contract, and documentation.",
      inputSchema =
        base.object_schema
          {
            path = base.string_field "Path to the .ncl file",
            field = base.string_field "Dot-separated field path to query",
          }
          ["path", "field"],
    },

  nickel_eval
    | doc "Tool: evaluate a Nickel expression"
    | not_exported
    = {
      description = "Evaluate a Nickel expression string and return the result. Useful for testing contracts and snippets.",
      inputSchema =
        base.object_schema
          {
            expression = base.string_field "Nickel expression to evaluate",
          }
          ["expression"],
    },

  # -- Project scaffolding builders ----------------------------------------
  # These produce project file descriptors for the agent to create.

  contract_file
    | doc "Describe a contract .ncl file to create"
    | not_exported
    = fun p =>
      fun d =>
        {
          path = p,
          description = d,
          kind = "contract",
        },

  builder_file
    | doc "Describe a builder .ncl file to create"
    | not_exported
    = fun p =>
      fun d =>
        {
          path = p,
          description = d,
          kind = "builder",
        },

  example_file
    | doc "Describe an example .ncl file to create"
    | not_exported
    = fun p =>
      fun d =>
        {
          path = p,
          description = d,
          kind = "example",
        },

  export_file
    | doc "Describe an export wrapper .ncl file"
    | not_exported
    = fun p =>
      fun d =>
        {
          path = p,
          description = d,
          kind = "export",
        },

  test_file
    | doc "Describe a test/validation file"
    | not_exported
    = fun p =>
      fun d =>
        {
          path = p,
          description = d,
          kind = "test",
        },

  project
    | doc m%"
      Build a project structure descriptor.

      Example:
        project "my-config" "Nickel config for K8s deployments" [
          contract_file "lib/schema.ncl" "Core contracts",
          builder_file "lib/builders.ncl" "Builder functions",
          example_file "examples/deployment.ncl" "Sample deployment",
        ]
    "%
    | not_exported
    = fun proj_name =>
      fun proj_desc =>
        fun file_list =>
          {
            name = proj_name,
            description = proj_desc,
            files = file_list,
          },
}
