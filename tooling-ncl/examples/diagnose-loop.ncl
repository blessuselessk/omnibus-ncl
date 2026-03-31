# Diagnose loop — shows what a ralph iteration WOULD look like
#
# STATUS: This is a simulation, not a real loop.
#
# What exists:
#   - diagnose: inspects a partial node → returns {completeness, missing, inferred}
#   - apply_inferences: auto-fills fields from code analysis
#   - to_ralph_event: formats diagnosis as a ralph event record
#
# What does NOT exist:
#   - No ralph hat that reads diagnoses and fills in fields
#   - No event bus — to_ralph_event produces static JSON, doesn't publish
#   - No iteration — this file simulates 3 steps manually
#
# To make this real, you need:
#   1. ralph-orchestrator binary (Rust) running the event loop
#   2. A hat with instructions to read node.incomplete events and fill fields
#   3. A skill that runs `nickel export` on diagnose output and feeds it back
#
# This example shows what each iteration's data looks like.
let D = import "../lib/diagnose.ncl" in

# --- Iteration 1: user provides just a name ---
let step_1 = { name = "transform" } in
let diag_1 = D.diagnose step_1 in

# --- Iteration 2: "hat" adds lang + code (simulated) ---
let step_2 = step_1 & { lang = 'bash, code = "jq '[.[] | .name]'" } in
let diag_2 = D.diagnose step_2 in

# --- Iteration 3: apply_inferences fills schemas + constraints ---
let step_3 = D.apply_inferences step_2 in
let diag_3 = D.diagnose step_3 in

{
  iterations = [
    { step = 1, node_fields = std.record.fields step_1, diagnosis = { completeness = diag_1.completeness, ready = diag_1.ready, event = D.to_ralph_event "transform" diag_1 } },
    { step = 2, node_fields = std.record.fields step_2, diagnosis = { completeness = diag_2.completeness, ready = diag_2.ready, event = D.to_ralph_event "transform" diag_2 } },
    { step = 3, node_fields = std.record.fields step_3, diagnosis = { completeness = diag_3.completeness, ready = diag_3.ready, event = D.to_ralph_event "transform" diag_3 } },
  ],
  gap = "This is a manual simulation. The ralph runtime (Rust binary) would drive the actual loop.",
}
