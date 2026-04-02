# Builders — ergonomic constructors for TypeDB schema elements
#
# Curried functions producing records conforming to types.ncl contracts.
# All let bindings prefixed with _ to avoid Nickel self-reference.
{
  # -- Attribute builders --

  attr
    | doc "Build an attribute: attr \"name\" 'string"
    | not_exported
    = fun _name =>
      fun _vtype =>
        { name = _name, value_type = _vtype },

  attr_sub
    | doc "Build a sub-attribute (inherits value type): attr_sub \"claimed-at\" \"timestamp\""
    | not_exported
    = fun _name =>
      fun _parent =>
        { name = _name, parent = _parent },

  # -- Clause builders --

  owns
    | doc "Build an owns clause: owns \"username\""
    | not_exported
    = fun _attr =>
      { attribute = _attr },

  owns_key
    | doc "Build an owns @key clause: owns_key \"username\""
    | not_exported
    = fun _attr =>
      { attribute = _attr, annotations = ['key] },

  owns_unique
    | doc "Build an owns @unique clause"
    | not_exported
    = fun _attr =>
      { attribute = _attr, annotations = ['unique] },

  plays
    | doc "Build a plays clause: plays \"authoring\" \"author\""
    | not_exported
    = fun _rel =>
      fun _role =>
        { relation = _rel, role = _role },

  relates
    | doc "Build a relates clause: relates \"author\""
    | not_exported
    = fun _role =>
      { role = _role },

  relates_card
    | doc "Build a relates with cardinality: relates_card \"friend\" 2 2"
    | not_exported
    = fun _role =>
      fun _min =>
        fun _max =>
          { role = _role, cardinality = { min = _min, max = _max } },

  # -- Type builders --

  entity
    | doc "Build an entity: entity \"user\" [owns_key \"login\"] [plays \"auth\" \"author\"]"
    | not_exported
    = fun _name =>
      fun _owns =>
        fun _plays =>
          { name = _name, owns = _owns, plays = _plays },

  entity_sub
    | doc "Build a sub-entity: entity_sub \"company\" \"organization\" [...] [...]"
    | not_exported
    = fun _name =>
      fun _parent =>
        fun _owns =>
          fun _plays =>
            { name = _name, parent = _parent, owns = _owns, plays = _plays },

  entity_abstract
    | doc "Build an abstract entity"
    | not_exported
    = fun _name =>
      fun _owns =>
        fun _plays =>
          { name = _name, annotations = ['abstract], owns = _owns, plays = _plays },

  relation
    | doc "Build a relation: relation \"auth\" [relates \"author\"] [owns ...] [plays ...]"
    | not_exported
    = fun _name =>
      fun _relates =>
        fun _owns =>
          fun _plays =>
            { name = _name, relates = _relates, owns = _owns, plays = _plays },

  # -- Rule and query builders --

  rule
    | doc "Build an inference rule: rule \"name\" \"when ...\" \"then ...\""
    | not_exported
    = fun _name =>
      fun _when =>
        fun _then =>
          { name = _name, when_clause = _when, then_clause = _then },

  rule_commented
    | doc "Build a rule with a comment"
    | not_exported
    = fun _name =>
      fun _comment =>
        fun _when =>
          fun _then =>
            { name = _name, comment = _comment, when_clause = _when, then_clause = _then },

  query
    | doc "Build a named query: query \"name\" \"match ...\""
    | not_exported
    = fun _name =>
      fun _q =>
        { name = _name, query = _q },

  query_commented
    | doc "Build a query with a comment"
    | not_exported
    = fun _name =>
      fun _comment =>
        fun _q =>
          { name = _name, comment = _comment, query = _q },

  # -- Schema composition --

  merge_schemas
    | doc "Merge two SchemaDefs by concatenating arrays (NOT record merge)"
    | not_exported
    = fun _a =>
      fun _b =>
        {
          attributes = _a.attributes @ _b.attributes,
          entities = _a.entities @ _b.entities,
          relations = _a.relations @ _b.relations,
          rules = _a.rules @ _b.rules,
        },
}
