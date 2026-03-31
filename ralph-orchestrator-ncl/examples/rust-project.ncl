# Ralph config for a Rust project — classic 4-hat pipeline
let B = import "../lib/builders.ncl" in
let H = import "../lib/hat.ncl" in

B.config
  {
    planner = H.default_planner,
    builder =
      H.default_builder
      & { concurrency = 3 },
    reviewer = H.default_reviewer,
    finalizer = H.default_finalizer,
  }
  B.rust_gates
& {
  event_loop = { max_iterations = 100 },
  cli = { backend = 'auto },
}
