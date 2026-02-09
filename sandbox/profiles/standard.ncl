# profiles/standard.ncl - Standard Profile
#
# Balanced security profile for general use.
{
  name = "standard",
  description = "Standard sandbox profile",
  resources = {
    max_memory_mb = 512,
    max_cpu_seconds = 60,
    max_file_size_mb = 100,
    max_fds = 128,
    max_processes = 32,
  },
  seccomp = 'standard,
  network = {
    enabled = true,
    mode = 'localhost,
  },
}
