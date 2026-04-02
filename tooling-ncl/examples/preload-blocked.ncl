# Preload with incomplete nodes — shows blocking info
#
# bare-node has only a name (10% complete).
# partial-node has name + lang (20% complete).
# Neither is ready, so the manifest reports blockers and ralph events.
let PL = import "../lib/preload.ncl" in

let bare = { name = "bare-node" } in
let partial = { name = "partial-node", lang = 'bash } in

let manifest = PL.preload_all "incomplete-pipe" [bare, partial] in

{
  stats = manifest.stats,
  node_states =
    std.array.map
      (fun pn =>
        {
          name = pn.enriched.name,
          state = pn.state,
          completeness = pn.diagnosis.completeness,
          ready = pn.ready,
          composable = pn.composable,
          suggestions = pn.diagnosis.suggestions,
        }
      )
      manifest.nodes,
  ralph_events = PL.to_ralph_events manifest,
  fingerprint = PL.manifest_fingerprint manifest,
}
