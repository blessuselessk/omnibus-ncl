# Security level contracts for Nix package tools
#
# Maps tool security requirements to sandbox profile parameters.
# Four levels: strict, network, io, full.
let rlimits = import "../../sandbox/lib/rlimits.ncl" in

{
  SecurityLevel
    | doc "Security level for a Nix tool — determines sandbox restrictions"
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.array.elem val ["strict", "network", "io", "full"]
      ),

  profiles = {
    strict = {
      description = "Read-only, no network, minimal resources",
      network = { enabled = false, mode = 'deny },
      fs = { mode = 'ro, allowed_paths = ["/tmp"] },
      resources = rlimits.small,
    },

    network = {
      description = "Allows outbound network, read-only filesystem",
      network = { enabled = true, mode = 'full },
      fs = { mode = 'ro, allowed_paths = ["/tmp"] },
      resources = rlimits.medium,
    },

    io = {
      description = "Allows filesystem writes to specified dirs, no network",
      network = { enabled = false, mode = 'deny },
      fs = { mode = 'whitelist, allowed_paths = ["/tmp"] },
      resources = rlimits.large,
    },

    full = {
      description = "Full access — development tools",
      network = { enabled = true, mode = 'full },
      fs = { mode = 'whitelist, allowed_paths = ["/tmp"] },
      resources = rlimits.large,
    },
  },
}
