# main.ncl - Library Main Configuration
#
# Central export point for all sandbox libraries.
let base = import "base.ncl" in
let mounts = import "mounts.ncl" in
let network = import "network.ncl" in
let seccomp = import "seccomp.ncl" in
let type_defs = import "types.ncl" in
let limits = import "rlimits.ncl" in

# Export all modules
{
  base = base.config,
  mounts = mounts.config,
  network = network,
  seccomp = seccomp,
  types = type_defs,
  rlimits = limits,
}
