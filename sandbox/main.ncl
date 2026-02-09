# main.ncl - Sandbox Main Configuration
#
# Central entry point for sandbox configuration.
# Import interface and compose profiles here.
{
  # Re-export type definitions for validation
  Backends = {
    nsjail = "nsjail",
    seatbelt = "seatbelt",
    hyperlight = "hyperlight",
  },
  BackendStates = {
    created = "created",
    running = "running",
    stopped = "stopped",
    error = "error",
  },
  ResourceLimits = {
    max_memory_mb = 128,
    max_cpu_seconds = 60,
    max_file_size_mb = 10,
    max_fds = 64,
    max_processes = 8,
  },
  NetworkModes = {
    deny = "deny",
    localhost = "localhost",
    container = "container",
    full = "full",
  },
  FsModes = {
    chroot = "chroot",
    ro = "ro",
    whitelist = "whitelist",
  },
  SeccompLevels = {
    disabled = "disabled",
    basic = "basic",
    standard = "standard",
    strict = "strict",
  },
  ProfileLevels = {
    strict = "strict",
    standard = "standard",
    relaxed = "relaxed",
  },
}
