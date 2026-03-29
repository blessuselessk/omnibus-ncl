# Builders for codemode-nix tool definitions
#
# Extends base codemode builders with Nix-tool-specific constructors:
#   nix_tool        — flakeRef + securityLevel + description + inputSchema
#   nix_tool_with_paths — adds custom allowedPaths
#   to_llm_view     — strips Nix/sandbox fields for LLM consumption
let base = import "../_deps/codemode-ncl/lib/builders.ncl" in

base
& {
  nix_tool
    | doc m%"
      Build a Nix tool descriptor.

      Example:
        nix_tool "nixpkgs#jq" "strict"
          "Process JSON with jq expressions"
          (object_schema { filter = string_field "jq filter" } ["filter"])
    "%
    | not_exported
    = fun flake_ref =>
      fun security =>
        fun desc =>
          fun input =>
            {
              flakeRef = flake_ref,
              securityLevel = security,
              description = desc,
              inputSchema = input,
            },

  nix_tool_with_paths
    | doc "Build a Nix tool with custom allowed filesystem paths"
    | not_exported
    = fun flake_ref =>
      fun security =>
        fun desc =>
          fun input =>
            fun paths =>
              {
                flakeRef = flake_ref,
                securityLevel = security,
                description = desc,
                inputSchema = input,
                allowedPaths = paths,
              },

  to_llm_view
    | doc m%"
      Project a NixToolSet to its LLM-facing view.
      Strips flakeRef, securityLevel, allowedPaths — LLM only sees
      description + inputSchema (+ optional outputSchema).
    "%
    | not_exported
    = fun nix_tools =>
      std.record.map
        (fun _name tool =>
          { description = tool.description, inputSchema = tool.inputSchema }
          & (
            if std.record.has_field "outputSchema" tool then
              { outputSchema = tool.outputSchema }
            else
              {}
          )
        )
        nix_tools,
}
