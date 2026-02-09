# seatbelt/main.ncl - Seatbelt Sandbox Configuration
#
# macOS Seatbelt sandbox profile definitions.
{
  # Seatbelt-specific profile levels
  ProfileLevels = {
    strict = "strict",
    standard = "standard",
    relaxed = "relaxed",
  },

  # Resource limits for Seatbelt
  ResourceLimits = {
    max_memory_mb = 128,
    max_cpu_seconds = 60,
    max_file_size_mb = 10,
    max_fds = 64,
    max_processes = 8,
  },

  # Network configuration (Seatbelt limited network support)
  NetworkModes = {
    deny = "deny",
    localhost = "localhost",
    container = "container",
  },

  # Filesystem modes
  FsModes = {
    chroot = "chroot",
    ro = "ro",
    whitelist = "whitelist",
  },

  # Default Seatbelt profile
  default_profile = {
    name = "seatbelt-standard",
    level = "standard",
    resources = ResourceLimits,
    network = {
      enabled = false,
      mode = "deny",
      allowed_hosts = [],
    },
    filesystem = {
      mode = "ro",
      mounts = [],
      allowed_paths = [],
    },
  },
}
