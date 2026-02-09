# skill/main.ncl - Skill Sandbox Configuration
#
# Skill execution sandbox profiles and type definitions.
{
  # Skill execution modes
  ExecutionModes = {
    sandboxed = "sandboxed",
    restricted = "restricted",
    unrestricted = "unrestricted",
  },

  # Skill resource defaults
  ResourceLimits = {
    max_memory_mb = 256,
    max_cpu_seconds = 60,
    max_file_size_mb = 50,
    max_fds = 32,
    max_processes = 10,
  },

  # Skill-specific profile
  skill_profile = {
    name = "skill-sandbox",
    description = "Sandbox for skill execution",
    resources = ResourceLimits,
    network = {
      enabled = false,
      mode = "deny",
    },
    filesystem = {
      mode = "ro",
      mounts = [],
      allowed_paths = ["/tmp"],
    },
  },

  # Allowed operations in sandbox
  AllowedOperations = {
    read = true,
    write = false,
    network = false,
    env = ["PATH", "HOME", "LANG"],
  },
}
