# ralph-orchestrator-ncl — Nickel contracts for ralph-orchestrator
#
# Models the ralph.yml configuration surface: event-driven pub/sub
# between specialized AI agent "hats", quality gates (backpressure),
# iterative loops, skills, and lifecycle hooks.
#
# This is CONFIG ONLY — produces ralph.yml JSON. The actual loop
# is driven by the ralph-orchestrator Rust binary:
#   https://github.com/mikeyobrien/ralph-orchestrator
#
# deploy.ncl bridges to massless-driver for running loops on GHA,
# but that also just produces workflow JSON — doesn't execute it.
{
  lib = import "lib/main.ncl",
}
