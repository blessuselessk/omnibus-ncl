# TypeDB 3.0 type system contracts
#
# Models the three TypeDB type kinds (entity, relation, attribute)
# and their structural properties (owns, plays, relates, sub).
{
  ValueType
    | doc "TypeDB attribute value types"
    | not_exported
    = [| 'string, 'integer, 'long, 'double, 'boolean, 'datetime |],

  Annotation
    | doc "TypeDB schema annotation (@key, @unique, @abstract)"
    | not_exported
    = [| 'key, 'unique, 'abstract |],

  Cardinality
    | doc "TypeDB @card(min..max) constraint"
    | not_exported
    = {
      min | Number,
      max | Number,
    },

  OwnsClause
    | doc "An 'owns <attribute>' clause with optional annotations"
    | not_exported
    = {
      attribute | String,
      annotations | Array Annotation | default = [],
      cardinality | Cardinality | optional,
    },

  PlaysClause
    | doc "A 'plays <relation>:<role>' clause"
    | not_exported
    = {
      relation | String,
      role | String,
    },

  RelatesClause
    | doc "A 'relates <role>' clause with optional cardinality and role inheritance"
    | not_exported
    = {
      role | String,
      parent | String | optional,
      annotations | Array Annotation | default = [],
      cardinality | Cardinality | optional,
    },

  AttributeDef
    | doc "A TypeDB attribute type definition"
    | not_exported
    = {
      name | String,
      kind | default = 'attribute,
      value_type | ValueType | optional,
      parent | String | optional,
      annotations | Array Annotation | default = [],
    },

  EntityDef
    | doc "A TypeDB entity type definition"
    | not_exported
    = {
      name | String,
      kind | default = 'entity,
      parent | String | optional,
      annotations | Array Annotation | default = [],
      owns | Array OwnsClause | default = [],
      plays | Array PlaysClause | default = [],
    },

  RelationDef
    | doc "A TypeDB relation type definition"
    | not_exported
    = {
      name | String,
      kind | default = 'relation,
      parent | String | optional,
      annotations | Array Annotation | default = [],
      relates | Array RelatesClause | default = [],
      owns | Array OwnsClause | default = [],
      plays | Array PlaysClause | default = [],
    },

  RuleDef
    | doc "A TypeDB inference rule (when/then pattern)"
    | not_exported
    = {
      name | String,
      comment | String | optional,
      when_clause | String,
      then_clause | String,
    },

  QueryDef
    | doc "A named TypeQL query template"
    | not_exported
    = {
      name | String,
      comment | String | optional,
      query | String,
    },

  SchemaDef
    | doc m%"
      A complete TypeDB schema definition.

      Compose layers with merge_schemas (from builders.ncl),
      NOT with record merge (&) — Nickel's & overrides arrays.
    "%
    | not_exported
    = {
      attributes | Array AttributeDef | default = [],
      entities | Array EntityDef | default = [],
      relations | Array RelationDef | default = [],
      rules | Array RuleDef | default = [],
    },
}
