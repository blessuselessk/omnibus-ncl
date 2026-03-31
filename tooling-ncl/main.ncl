# tooling-ncl — typed code nodes with composable pipelines
#
# A CodeNode is a typed box: code goes in, schema defines boundaries,
# constraints define what it can touch. Nodes compose into pipelines
# that export as shell scripts or process-compose configs.
#
# What works:
#   - CodeNode contract (progressive — start with just a name)
#   - Pipeline composition with ValidChain schema checking
#   - Export to bash scripts and process-compose configs
#   - diagnose: inspects partial nodes, reports completeness
#   - apply_inferences: auto-fills from code analysis
#   - to_ralph_event: formats diagnosis as event data
#
# What doesn't work yet:
#   - No runtime loop — diagnose produces data, doesn't drive iteration
#   - Ralph integration is config-only — needs the Rust binary to run
#   - Schema checking is type-level only, no runtime validation of actual output
{
  lib = import "lib/main.ncl",
}
