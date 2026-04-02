# Incremental preload — node evolving from bare → partial → composable
#
# Shows three snapshots of the same node as fields are added.
# Each snapshot is a full preload with state, readiness, and composability.
# In a real ralph loop, each iteration would add fields based on events.
let B = import "../lib/builders.ncl" in
let PL = import "../lib/preload.ncl" in

# --- Step 1: just a name ---
let step_1 = { name = "transform" } in
let snap_1 = PL.preload step_1 in

# --- Step 2: add lang + code ---
let step_2 = step_1 & { lang = 'bash, code = "jq '[.[] | .name]'" } in
let snap_2 = PL.preload step_2 in

# --- Step 3: add schemas (via inference or manually) ---
let step_3 =
  step_2
  & {
    input_schema = { type = 'object, description = "JSON array input" },
    output_schema = { type = 'object, description = "Array of name strings" },
  }
in
let snap_3 = PL.preload step_3 in

let summary = fun snap =>
  {
    state = snap.state,
    completeness = snap.diagnosis.completeness,
    ready = snap.ready,
    composable = snap.composable,
    present = snap.diagnosis.present,
    missing = snap.diagnosis.missing,
  }
in

{
  iterations = [
    { step = 1, note = "bare — just a name", result = summary snap_1 },
    { step = 2, note = "partial — has code + lang, inferences applied", result = summary snap_2 },
    { step = 3, note = "composable — schemas present, safe for ValidChain", result = summary snap_3 },
  ],
  fingerprints = {
    snap_1 = PL.manifest_fingerprint (PL.preload_all "evolving" [step_1]),
    snap_2 = PL.manifest_fingerprint (PL.preload_all "evolving" [step_2]),
    snap_3 = PL.manifest_fingerprint (PL.preload_all "evolving" [step_3]),
  },
}
