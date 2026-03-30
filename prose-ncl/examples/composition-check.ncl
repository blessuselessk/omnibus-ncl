# Composition validation — demonstrates the enforcement contracts.
#
# Each edge is validated against the composability graph at export time.
# Invalid compositions (e.g. spec invoking agent) would fail the contract.
#
# Usage: nickel export --format json prose-ncl/examples/composition-check.ncl
let G = import "../lib/graph.ncl" in

# All of these are valid — they'll pass the ValidComposition contract.
# Try changing one (e.g. from = 'spec, direction = 'invoke) to see it fail.
{
  edges = [
    # agent hands off to another agent
    { from = 'agent, to = 'agent, direction = 'invoke, verb = "hands-off-to" }
      | G.ValidComposition,

    # agent auto-loads matching instructions
    { from = 'agent, to = 'instruction, direction = 'auto_load, verb = "auto-loads" }
      | G.ValidComposition,

    # agent reads memory
    { from = 'agent, to = 'memory, direction = 'reference, verb = "reads" }
      | G.ValidComposition,

    # agent writes memory
    { from = 'agent, to = 'memory, direction = 'produce, verb = "updates" }
      | G.ValidComposition,

    # prompt activates an agent
    { from = 'prompt, to = 'agent, direction = 'invoke, verb = "activates" }
      | G.ValidComposition,

    # prompt consumes a spec
    { from = 'prompt, to = 'spec, direction = 'reference, verb = "consumes" }
      | G.ValidComposition,

    # prompt produces a spec
    { from = 'prompt, to = 'spec, direction = 'produce, verb = "produces" }
      | G.ValidComposition,

    # instruction references context
    { from = 'instruction, to = 'context, direction = 'reference, verb = "references" }
      | G.ValidComposition,

    # context cross-references context
    { from = 'context, to = 'context, direction = 'reference, verb = "references" }
      | G.ValidComposition,

    # skill references its bundled docs
    { from = 'skill, to = 'context, direction = 'reference, verb = "references" }
      | G.ValidComposition,
  ],
}
