# Diagnose — inspect a partial CodeNode and report what's missing
#
# Returns a structured report: completeness score, missing fields,
# inferences from what's present, and suggestions for next steps.
# Designed to feed into a ralph loop as event payload.
let has = std.record.has_field in

# Field weights for completeness scoring
let field_weights = {
  name = 10,
  lang = 10,
  code = 25,
  description = 10,
  input_schema = 15,
  output_schema = 15,
  constraints = 10,
  env = 5,
}
in

let total_weight = 100 in

# Infer what we can from code + lang
let infer_from_code = fun _node =>
  let has_code = has "code" _node in
  let has_lang = has "lang" _node in
  let code = if has_code then _node.code else "" in
  let lang = if has_lang then _node.lang else 'bash in

  let inferred_input =
    if std.string.is_match "jq" code then
      { type = 'object, description = "JSON input (inferred: code uses jq)" }
    else if std.string.is_match "pandoc.*-f markdown" code then
      { type = 'string, description = "Markdown text (inferred: code uses pandoc -f markdown)" }
    else if std.string.is_match "curl" code then
      { type = 'null, description = "No input (inferred: code uses curl to fetch)" }
    else
      null
  in

  let inferred_output =
    if std.string.is_match "jq" code then
      { type = 'object, description = "JSON output (inferred: jq produces JSON)" }
    else if std.string.is_match "pandoc.*-t json" code then
      { type = 'object, description = "Pandoc AST (inferred: pandoc -t json)" }
    else if std.string.is_match "pandoc.*-t html" code then
      { type = 'string, description = "HTML string (inferred: pandoc -t html)" }
    else
      null
  in

  let inferred_constraints =
    if std.string.is_match "curl|wget|fetch" code then
      { network = { mode = 'full }, note = "Code makes network requests" }
    else if std.string.is_match ">" code || std.string.is_match "tee " code then
      { fs = { mode = 'rw }, note = "Code writes to files" }
    else
      { network = { mode = 'deny }, fs = { mode = 'ro }, note = "No network or file writes detected" }
  in

  {
    input_schema = inferred_input,
    output_schema = inferred_output,
    constraints = inferred_constraints,
  }
in

{
  diagnose
    | doc m%"
      Inspect a partial CodeNode and report what's missing.

      Returns:
      - completeness: 0-100 percentage
      - missing: list of missing field names
      - present: list of present field names
      - inferred: fields that can be auto-filled from code analysis
      - suggestions: human-readable next steps
      - ready: true if the node is complete enough to run

      # Examples

      ```nickel
      diagnose { name = "filter" }
      # => { completeness = 10, missing = ["lang", "code", ...], ... }

      diagnose { name = "filter", lang = 'bash, code = "jq '.name'" }
      # => { completeness = 45, inferred = { input_schema = { type = 'object, ... } }, ... }
      ```
    "%
    | not_exported
    = fun _node =>
      let fields = ["name", "lang", "code", "description", "input_schema", "output_schema", "constraints", "env"] in
      let present_fields =
        std.array.filter (fun f => has f _node) fields
      in
      let missing_fields =
        std.array.filter (fun f => !(has f _node)) fields
      in
      let score =
        std.array.fold_left
          (fun acc f =>
            if has f _node then
              acc + (std.record.get f field_weights)
            else
              acc
          )
          0
          fields
      in
      let inferred_fields =
        if has "code" _node then
          infer_from_code _node
        else
          { input_schema = null, output_schema = null, constraints = null }
      in
      let next_steps =
        (
          if !(has "code" _node) then
            ["Add code — the implementation that transforms input to output"]
          else
            []
        )
        @ (
          if !(has "lang" _node) then
            ["Add lang — 'bash, 'nickel, 'nushell, 'python, or 'javascript"]
          else
            []
        )
        @ (
          if !(has "input_schema" _node) then
            if inferred_fields.input_schema != null then
              ["input_schema can be inferred — accept or refine the suggestion"]
            else
              ["Add input_schema — what JSON shape does this node receive?"]
          else
            []
        )
        @ (
          if !(has "output_schema" _node) then
            if inferred_fields.output_schema != null then
              ["output_schema can be inferred — accept or refine the suggestion"]
            else
              ["Add output_schema — what JSON shape does this node produce?"]
          else
            []
        )
        @ (
          if !(has "constraints" _node) then
            if inferred_fields.constraints != null then
              ["constraints can be inferred — review the suggested permissions"]
            else
              ["Add constraints — what can this code touch? (network, fs, resources)"]
          else
            []
        )
        @ (
          if !(has "description" _node) then
            ["Add description — one line explaining what this node does"]
          else
            []
        )
      in

      {
        completeness = score,
        present = present_fields,
        missing = missing_fields,
        inferred = inferred_fields,
        suggestions = next_steps,
        ready = score >= 60 && has "code" _node && has "lang" _node,
      },

  apply_inferences
    | doc m%"
      Apply inferred fields to a partial node.

      Only fills fields that are missing — won't override existing values.

      # Examples

      ```nickel
      apply_inferences { name = "filter", lang = 'bash, code = "jq '.name'" }
      # => { name = "filter", lang = 'bash, code = "jq '.name'", input_schema = { type = 'object, ... }, ... }
      ```
    "%
    | not_exported
    = fun _node =>
      let inferences =
        if has "code" _node then
          infer_from_code _node
        else
          { input_schema = null, output_schema = null, constraints = null }
      in
      _node
      & (
        if !(has "input_schema" _node) && inferences.input_schema != null then
          { input_schema = inferences.input_schema }
        else
          {}
      )
      & (
        if !(has "output_schema" _node) && inferences.output_schema != null then
          { output_schema = inferences.output_schema }
        else
          {}
      )
      & (
        if !(has "constraints" _node) && inferences.constraints != null then
          let c = inferences.constraints in
          {
            constraints =
              std.record.remove "note" c,
          }
        else
          {}
      ),

  to_ralph_event
    | doc m%"
      Convert a diagnosis into a ralph event payload.

      Emits on topic "node.incomplete" with the diagnosis as payload,
      so a ralph hat can pick it up and fill in the gaps.
    "%
    | not_exported
    = fun _node_name =>
      fun _diagnosis =>
        {
          topic = "node.incomplete",
          payload =
            std.string.join
              "\n"
              (
                ["Node '%{_node_name}' is %{std.to_string _diagnosis.completeness}%% complete."]
                @ (
                  if std.array.length _diagnosis.missing > 0 then
                    ["Missing: %{std.string.join ", " _diagnosis.missing}"]
                  else
                    []
                )
                @ [""]
                @ _diagnosis.suggestions
              ),
        },
}
