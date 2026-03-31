# porkg-ncl — Nickel contracts for porkg process hierarchy
#
# Models porkg's parent → worker → job architecture:
# namespace isolation, MessagePack IPC protocol, privilege
# escalation, and job specifications.
#
# Usage:
#   nickel export --format json porkg-ncl/examples/config-export.ncl
#   nickel export --format json porkg-ncl/examples/pipeline-export.ncl
{
  lib = import "lib/main.ncl",
}
