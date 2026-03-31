# Simple porkg config — one worker, two jobs
let B = import "../lib/builders.ncl" in

B.config
  "builder"
  [
    B.job "build" ["make", "all"],
    B.job "test" ["make", "test"],
  ]
