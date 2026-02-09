# profiles/strict.ncl - Strict Profile
#
# Maximum security profile for untrusted code.
{
  name = "strict",
  description = "Maximum security sandbox",
  resources = {
    max_memory_mb = 256,
    max_cpu_seconds = 30,
    max_file_size_mb = 10,
    max_fds = 64,
    max_processes = 16,
  },
  seccomp = 'strict,
  network = {
    enabled = false,
    mode = 'deny,
  },
}
