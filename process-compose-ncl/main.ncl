# process-compose-ncl — Nickel contracts for Process Compose
#
# Models the full process-compose.yaml configuration surface,
# plus bridge adapters from envelope-ncl and porkg-ncl.
#
# Usage:
#   nickel export --format json process-compose-ncl/examples/standalone-export.ncl
#   nickel export --format json process-compose-ncl/examples/envelope-bridge-export.ncl
{
  lib = import "lib/main.ncl",
}
