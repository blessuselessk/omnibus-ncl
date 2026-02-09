# profiles/relaxed.ncl - Relaxed Profile
#
# Less restrictive profile for development/testing.
{
  name = "relaxed",
  description = "Relaxed sandbox for development",
  resources = {
    max_memory_mb = 1024,
    max_cpu_seconds = 120,
    max_file_size_mb = 500,
    max_fds = 256,
    max_processes = 50,
  },
  seccomp = 'basic,
  network = {
    enabled = true,
    mode = 'full,
  },
}
