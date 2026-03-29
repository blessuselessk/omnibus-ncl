# Nickel project structure contracts — what a generated project looks like
{
  ProjectKind
    | doc "What the Nickel project generates"
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.array.elem
          val
          ["config", "infrastructure", "schema", "tool-definitions"]
      ),

  ProjectFile
    | doc "A file in a generated Nickel project"
    | not_exported
    = {
      path | String,
      description | String | optional,
      kind
        | std.contract.from_predicate (fun val =>
          std.is_string val
          && std.array.elem
            val
            ["contract", "builder", "example", "export", "config", "test"]
        )
        | optional,
    },

  ProjectStructure
    | doc m%"
      Describes the shape of a Nickel project.
      Used by the agent to plan what files to create.
    "%
    | not_exported
    = {
      name | String,
      description | String,
      kind | ProjectKind | optional,
      target_format
        | std.contract.from_predicate (fun val =>
          std.is_string val
          && std.array.elem val ["json", "yaml", "toml", "text"]
        )
        | default
        = "json",
      files | Array ProjectFile | optional,
      has_flake | Bool | default = true,
      has_makefile | Bool | default = true,
    },
}
