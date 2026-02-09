# lib/types.ncl - Sandbox Type Definitions
#
# Core type contracts for sandbox configuration validation.
#
# Usage:
#   let types = import "lib/types.ncl" in
#   { port | types.PortNumber }

# ============================================
# Type Definitions (serializable)
# ============================================
{
  # Port number validation
  PortNumber
    | doc m%"
        A valid port number (1-65535).

        # Examples

        ```nickel
        (8080 | PortNumber)
        # => 8080

        (0 | PortNumber)
        # => error: contract broken by a value
        ```
      "%
    = { port | Number | default = 0 },

  # Resource limits
  ResourceLimits
    | doc m%"
        Resource constraints for sandbox execution.

        # Examples

        ```nickel
        ({ max_memory_mb = 512 } | ResourceLimits)
        # => { max_memory_mb = 512 }
        ```
      "%
    = {
      max_memory_mb | Number | default = 128,
      max_cpu_seconds | Number | default = 60,
      max_file_size_mb | Number | default = 100,
      max_fds | Number | default = 64,
      max_processes | Number | default = 8,
    },

  # Network configuration
  NetworkConfig
    | doc m%"
        Network configuration with isolation settings.

        # Examples

        ```nickel
        ({ enabled = true, mode = "localhost" } | NetworkConfig)
        # => { enabled = true, mode = "localhost" }
        ```
      "%
    = {
      enabled | Bool | default = false,
      mode | String | default = "deny",
      allowed_hosts | Array String | default = [],
    },

  # ============================================
  # Enum Definitions (not_exported - tags not serializable)
  # ============================================

  # Platform enumeration
  Platform | not_exported = [| 'linux, 'darwin, 'freebsd |],

  # Seccomp level
  SeccompLevel | not_exported = [| 'disabled, 'basic, 'standard, 'strict |],

  # Network policy
  NetworkPolicy | not_exported = [| 'deny, 'localhost, 'container, 'full |],

  # Filesystem policy
  FsPolicy | not_exported = [| 'ro, 'rw, 'chroot |],

  # ============================================
  # String Arrays (for JSON export)
  # ============================================

  platform_list = ["linux", "darwin", "freebsd"],
  seccomp_level_list = ["disabled", "basic", "standard", "strict"],
  network_policy_list = ["deny", "localhost", "container", "full"],
  fs_policy_list = ["ro", "rw", "chroot"],
}
