# PROSE Skill contract
#
# Skills are reusable capability packages with references and scripts.
# Name is validated: 1-64 chars, lowercase alphanumeric + hyphens.
let skill_name_contract =
  std.contract.from_predicate (fun value =>
    std.is_string value
    && std.string.length value >= 1
    && std.string.length value <= 64
    && std.string.is_match "^[a-z0-9][a-z0-9-]*$" value
  )
in

{
  SkillName
    | doc "Validated skill name: 1-64 chars, lowercase alphanumeric + hyphens"
    | not_exported
    = skill_name_contract,

  Skill
    | doc m%"
      A reusable capability package.
      Contains reference materials and executable scripts.
    "%
    | not_exported
    = {
      name
        | doc "Unique identifier (1-64 chars, lowercase alphanumeric + hyphens)"
        | skill_name_contract,
      description
        | doc "What this skill provides"
        | String,
      references
        | doc "Paths to reference documentation files"
        | Array String
        | optional,
      scripts
        | doc "Paths to executable script files"
        | Array String
        | optional,
    },
}
