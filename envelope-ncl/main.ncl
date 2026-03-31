# envelope-ncl — composable, nestable runtime envelopes
#
# A shared composition layer for omnibus-ncl subprojects.
# Every runtime boundary (sandbox, workflow, MCP server, tool)
# can be expressed as an Envelope and nested with monotonic
# constraint restriction.
#
# Usage:
#   nickel export --format json envelope-ncl/examples/tool-in-sandbox.ncl
#   nickel export --format json envelope-ncl/examples/sandbox-in-workflow.ncl
#   nickel export --format json envelope-ncl/examples/three-layer.ncl
{
  lib = import "lib/main.ncl",
}
