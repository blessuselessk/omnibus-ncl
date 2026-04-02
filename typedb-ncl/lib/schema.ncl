# Schema — TypeQL code generation from SchemaDef
#
# to_typeql(schema) → string of valid TypeQL `define` block
# to_json(schema) → schema record validated against SchemaDef
let { SchemaDef, .. } = import "types.ncl" in
let has = std.record.has_field in

let annotation_str = match {
  'key => " @key",
  'unique => " @unique",
  'abstract => " @abstract",
}
in

let cardinality_str = fun _card =>
  " @card(%{std.string.from_number _card.min}..%{std.string.from_number _card.max})"
in

let annotations_suffix = fun _anns =>
  fun _has_card =>
    fun _card =>
      let ann_strs = std.array.map annotation_str _anns in
      let card_str =
        if _has_card then
          [cardinality_str _card]
        else
          []
      in
      std.string.join "" (ann_strs @ card_str)
in

let value_type_str = match {
  'string => "string",
  'integer => "integer",
  'long => "long",
  'double => "double",
  'boolean => "boolean",
  'datetime => "datetime",
}
in

let render_attribute = fun _attr =>
  let abstract_suffix =
    if std.array.elem 'abstract _attr.annotations then
      " @abstract"
    else
      ""
  in
  if has "parent" _attr then
    # Sub-attribute — inherits value type from parent
    "  attribute %{_attr.name} sub %{_attr.parent}%{abstract_suffix};"
  else
    # Root attribute — must specify value type
    "  attribute %{_attr.name}%{abstract_suffix}, value %{value_type_str _attr.value_type};"
in

let render_owns = fun _oc =>
  let _has_card = has "cardinality" _oc in
  let _card = if _has_card then _oc.cardinality else { min = 0, max = 0 } in
  "    owns %{_oc.attribute}%{annotations_suffix _oc.annotations _has_card _card}"
in

let render_plays = fun _pc =>
  "    plays %{_pc.relation}:%{_pc.role}"
in

let render_relates = fun _rc =>
  let _has_card = has "cardinality" _rc in
  let _card = if _has_card then _rc.cardinality else { min = 0, max = 0 } in
  let sub_clause = if has "parent" _rc then " sub %{_rc.parent}" else "" in
  "    relates %{_rc.role}%{sub_clause}%{annotations_suffix _rc.annotations _has_card _card}"
in

let render_entity = fun _ent =>
  let sub_clause =
    if has "parent" _ent then
      " sub %{_ent.parent}"
    else
      ""
  in
  let abstract_suffix =
    if std.array.elem 'abstract _ent.annotations then
      " @abstract"
    else
      ""
  in
  let header = "  entity %{_ent.name}%{sub_clause}%{abstract_suffix}" in
  let clauses =
    (std.array.map render_owns _ent.owns)
    @ (std.array.map render_plays _ent.plays)
  in
  if std.array.length clauses == 0 then
    header ++ ";"
  else
    header ++ ",\n" ++ std.string.join ",\n" clauses ++ ";"
in

let render_relation = fun _rel =>
  let sub_clause =
    if has "parent" _rel then
      " sub %{_rel.parent}"
    else
      ""
  in
  let header = "  relation %{_rel.name}%{sub_clause}" in
  let clauses =
    (std.array.map render_relates _rel.relates)
    @ (std.array.map render_owns _rel.owns)
    @ (std.array.map render_plays _rel.plays)
  in
  if std.array.length clauses == 0 then
    header ++ ";"
  else
    header ++ ",\n" ++ std.string.join ",\n" clauses ++ ";"
in

let render_rule = fun _rule =>
  let comment_line =
    if has "comment" _rule then
      "# %{_rule.comment}\n"
    else
      ""
  in
  "%{comment_line}rule %{_rule.name}: when {\n%{_rule.when_clause}\n} then {\n%{_rule.then_clause}\n};"
in

let render_query = fun _qdef =>
  let comment_line =
    if has "comment" _qdef then
      "# %{_qdef.comment}\n"
    else
      ""
  in
  "%{comment_line}# Query: %{_qdef.name}\n%{_qdef.query}"
in

{
  to_typeql
    | doc m%"
      Generate a TypeQL `define` statement from a SchemaDef.

      Renders attributes, entities, relations, then rules.
      Output is a string for `nickel export --format text`.
    "%
    | not_exported
    = fun _schema =>
      let validated = _schema | SchemaDef in
      let attr_lines = std.array.map render_attribute validated.attributes in
      let entity_lines = std.array.map render_entity validated.entities in
      let relation_lines = std.array.map render_relation validated.relations in
      let rule_lines = std.array.map render_rule validated.rules in
      let type_lines = attr_lines @ [""] @ entity_lines @ [""] @ relation_lines in
      let all_lines =
        if std.array.length rule_lines > 0 then
          type_lines @ [""] @ rule_lines
        else
          type_lines
      in
      "define\n" ++ std.string.join "\n" all_lines,

  render_queries
    | doc "Render an array of QueryDefs as a TypeQL script"
    | not_exported
    = fun _queries =>
      std.string.join "\n\n" (std.array.map render_query _queries),

  to_json
    | doc "Return the schema as a validated record for JSON export"
    | not_exported
    = fun _schema =>
      _schema | SchemaDef,
}
