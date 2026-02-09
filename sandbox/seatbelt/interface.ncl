# interface.ncl - Seatbelt Sandbox Configuration Interface
#
# Usage:
#   let Sandbox = import "interface.ncl" in
#   Sandbox.build {
#     id = "my-app",
#     backend = 'seatbelt,
#     cmd = ["/bin/bash"],
#     network = { enabled = false },
#     fs = { mode = 'ro, allowed_paths = ["/tmp"] },
#   } |> Sandbox.to_profile
#
# macOS Sandbox Profile Language Reference:
# https://developer.apple.com/library/archive/documentation/Security/Reference/SandboxRef/
#
# Profile Syntax:
# - (version 1) - Required header
# - (allow default) - Allow all operations by default
# - (deny network-outbound) - Deny network outbound
# - (allow file-read-data (subpath "/path")) - Allow read from path
{
  # ============================================
  # Network Config
  # ============================================
  NetworkConfig = {
    enabled | Bool,
    mode | [| 'deny, 'full |],
    allowed_hosts,
  },

  # ============================================
  # Filesystem Config
  # ============================================
  FsConfig = {
    mode | [| 'chroot, 'ro, 'whitelist |],
    mounts,
    allowed_paths,
  },

  # ============================================
  # Builder - Validate and merge with defaults
  # ============================================
  build = fun config =>
    {
      id | String,
      backend | [| 'nsjail, 'seatbelt, 'hyperlight |],
      cmd,

      # Network
      network = {
        enabled | Bool | default = false,
        mode | default = 'deny,
        allowed_hosts | default = [],
      },

      # Filesystem
      fs = {
        mode | default = 'ro,
        mounts | default = [],
        allowed_paths | default = [],
      },
    }
    & config,

  # ============================================
  # Generate Seatbelt Profile
  # ============================================
  to_profile = fun config =>
    let cfg = build config in

    # Build filesystem rules - use subpath for directories
    let fs_rules =
      std.array.map
        (fun p =>
          "(allow file-read-data file-write-data (subpath \""
          ++ p
          ++ "\"))"
        )
        cfg.fs.allowed_paths
    in

    # Build network rules - use outbound/inbound (not out/in)
    let network_rules =
      if cfg.network.enabled then
        [
          "(allow network-outbound)",
          "(allow network-inbound)",
        ]
      else
        [
          "(deny network-outbound)",
          "(deny network-inbound)",
        ]
    in

    # Combine all parts - NO comments, no extra newlines
    "(version 1)"
    ++ "\n"
    ++ "(allow default)"
    ++ "\n"
    ++ std.string.join "\n" network_rules
    ++ "\n"
    ++ std.string.join "\n" fs_rules,
}
