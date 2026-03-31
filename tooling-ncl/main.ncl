# tooling-ncl — typed code nodes with composable pipelines
#
# A CodeNode is a typed box: code goes in, schema defines boundaries,
# constraints define what it can touch. Nodes compose into pipelines
# that export as shell scripts or process-compose configs.
{
  lib = import "lib/main.ncl",
}
