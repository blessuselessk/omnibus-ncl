# Preload — the gate between creation and composition
#
# preload(node) → PreloadedNode: diagnoses, infers, captures state
# preload_all(name, nodes) → PreloadManifest: aggregate with stats
# compose_validated(manifest) → Pipeline: only if all nodes composable
#
# The manifest IS the cache — export as JSON, diff between runs.
let { CodeNode, .. } = import "node.ncl" in
let D = import "diagnose.ncl" in
let P = import "pipe.ncl" in
let has = std.record.has_field in

# --- State enum for lifecycle tracking ---
let PreloadState = [| 'bare, 'partial, 'inferred, 'ready |] in

# --- Compute state from diagnosis ---
let state_of = fun _diag =>
  if _diag.ready then
    'ready
  else if _diag.completeness >= 35 then
    'inferred
  else if _diag.completeness > 10 then
    'partial
  else
    'bare
in

{
  PreloadedNode
    | doc m%"
      A CodeNode wrapped with its diagnosis and enriched variant.

      - original: the CodeNode as provided
      - enriched: the CodeNode after apply_inferences
      - diagnosis: the full diagnose() output
      - state: lifecycle position ('bare, 'partial, 'inferred, 'ready)
      - ready: can execute standalone (completeness >= 60, has code + lang)
      - composable: ready AND has input_schema AND output_schema (safe for ValidChain)
    "%
    | not_exported
    = {
      original | CodeNode,
      enriched | CodeNode,
      diagnosis
        | {
          completeness | Number,
          present | Array String,
          missing | Array String,
          inferred | { .. },
          suggestions | Array String,
          ready | Bool,
        },
      state | PreloadState,
      ready | Bool,
      composable | Bool,
    },

  PreloadManifest
    | doc m%"
      Collection of PreloadedNodes with aggregate statistics.

      The manifest is the cache format — export as JSON, compare
      between runs to detect what changed.
    "%
    | not_exported
    = {
      nodes | Array PreloadedNode,
      stats
        | {
          total | Number,
          ready_count | Number,
          composable_count | Number,
          blocked_count | Number,
          avg_completeness | Number,
          all_ready | Bool,
          all_composable | Bool,
          blockers | Array String,
        },
      pipeline_name | String | optional,
    },

  ReadyManifest
    | doc "Contract: every node in the manifest must be ready."
    | not_exported
    =
      std.contract.from_predicate (fun manifest =>
        manifest.stats.all_ready
      ),

  ComposableManifest
    | doc "Contract: every node must be composable (ready + has schemas)."
    | not_exported
    =
      std.contract.from_predicate (fun manifest =>
        manifest.stats.all_composable
      ),

  # --- Core functions ---

  preload
    | doc m%"
      Preload a single CodeNode: diagnose + infer + capture state.

      Returns a PreloadedNode with original, enriched, diagnosis,
      state, ready, and composable fields.

      # Examples

      ```nickel
      preload { name = "filter", lang = 'bash, code = "jq '.name'" }
      ```
    "%
    | not_exported
    = fun _node =>
      let _enriched = D.apply_inferences _node in
      let _diag = D.diagnose _enriched in
      {
        original = _node,
        enriched = _enriched,
        diagnosis = _diag,
        state = state_of _diag,
        ready = _diag.ready,
        composable =
          _diag.ready
          && has "input_schema" _enriched
          && has "output_schema" _enriched,
      },

  preload_all
    | doc m%"
      Preload an array of CodeNodes into a PreloadManifest.

      Each node is diagnosed and inferred. The manifest includes
      aggregate stats: how many ready/composable, what's blocking.

      # Examples

      ```nickel
      preload_all "my-pipeline" [node_a, node_b, node_c]
      ```
    "%
    | not_exported
    = fun _pipeline_name =>
      fun _nodes =>
        let preloaded =
          std.array.map (fun n => preload n) _nodes
        in
        let n_total = std.array.length preloaded in
        let n_ready =
          std.array.length (std.array.filter (fun pn => pn.ready) preloaded)
        in
        let n_composable =
          std.array.length (std.array.filter (fun pn => pn.composable) preloaded)
        in
        let n_blocked = n_total - n_ready in
        let sum_completeness =
          std.array.fold_left
            (fun acc pn => acc + pn.diagnosis.completeness)
            0
            preloaded
        in
        let avg_comp =
          if n_total > 0 then
            sum_completeness / n_total
          else
            0
        in
        let blocker_names =
          std.array.filter (fun pn => !(pn.ready)) preloaded
          |> std.array.map (fun pn => pn.enriched.name)
        in
        {
          nodes = preloaded,
          stats = {
            total = n_total,
            ready_count = n_ready,
            composable_count = n_composable,
            blocked_count = n_blocked,
            avg_completeness = avg_comp,
            all_ready = n_blocked == 0,
            all_composable = n_composable == n_total,
            blockers = blocker_names,
          },
          pipeline_name = _pipeline_name,
        },

  compose_validated
    | doc m%"
      Compose a ComposableManifest into a Pipeline.

      Only accepts manifests where ALL nodes are composable
      (ready + have schemas). Extracts enriched nodes and passes
      them to pipe.pipeline with ValidChain enforcement.

      # Examples

      ```nickel
      let manifest = preload_all "my-pipe" [a, b, c] in
      compose_validated manifest
      ```
    "%
    | not_exported
    = fun _manifest =>
      let checked = _manifest | ComposableManifest in
      let enriched_nodes =
        std.array.map (fun pn => pn.enriched) checked.nodes
      in
      P.pipeline checked.pipeline_name enriched_nodes,

  # --- Ralph integration ---

  to_ralph_events
    | doc m%"
      Convert manifest blockers to ralph events.

      Emits one event per non-ready node on topic "node.preload".
      Ready nodes are skipped.
    "%
    | not_exported
    = fun _manifest =>
      std.array.filter (fun pn => !(pn.ready)) _manifest.nodes
      |> std.array.map (fun pn =>
        let evt = D.to_ralph_event pn.enriched.name pn.diagnosis in
        {
          topic = "node.preload",
          payload = evt.payload,
        }
      ),

  # --- Cache comparison ---

  manifest_fingerprint
    | doc m%"
      Extract a fingerprint for cache comparison.

      Returns {node_name → {state, completeness, present, ready, composable}}.
      Diff two fingerprints to detect what changed between runs.
    "%
    | not_exported
    = fun _manifest =>
      std.array.fold_left
        (fun acc pn =>
          acc
          & {
            "%{pn.enriched.name}" = {
              state = pn.state,
              completeness = pn.diagnosis.completeness,
              present = pn.diagnosis.present,
              ready = pn.ready,
              composable = pn.composable,
            },
          }
        )
        {}
        _manifest.nodes,
}
