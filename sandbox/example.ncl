# sandbox.ncl - Example Sandbox Configuration
let Interface = import "interface.ncl" in
{
  my_sandbox | Interface.SandboxConfig = {
    id = "sandbox-001",
    backend = "nsjail",
    cmd = ["echo", "hello"],
    env = { HOME = "/tmp", PATH = "/bin" },
    cwd = "/tmp",
    resources = {
      max_memory_mb = 512,
      max_cpu_seconds = 30,
      max_file_size_mb = 100,
      max_fds = 64,
      max_processes = 10,
    },
    network = {
      enabled = true,
      mode = "localhost",
      allowed_hosts = [],
    },
    filesystem = {
      mode = "ro",
      mounts = [],
      allowed_paths = [],
    },
    seccomp = "standard",
    timeout_seconds = 60,
  },
  strict_profile | Interface.Profile = {
    name = "strict",
    level = "strict",
    resources = {
      max_memory_mb = 256,
      max_cpu_seconds = 10,
      max_file_size_mb = 10,
      max_fds = 32,
      max_processes = 5,
    },
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
    seccomp = "strict",
  },
}
