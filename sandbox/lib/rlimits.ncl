# lib/rlimits.ncl - Resource limit configurations
#
# Pre-defined resource limits for different sandbox profiles.
{
  minimal = {
    rlimit_as = 64 * 1024 * 1024,
    rlimit_cpu = 10,
    rlimit_cpu_type = "SOFT",
    rlimit_fsize = 1 * 1024 * 1024,
    rlimit_nofile = 32,
    rlimit_nproc = 8,
    rlimit_core = 0,
    rlimit_stack = 4 * 1024 * 1024,
  },

  small = {
    rlimit_as = 128 * 1024 * 1024,
    rlimit_cpu = 30,
    rlimit_cpu_type = "SOFT",
    rlimit_fsize = 5 * 1024 * 1024,
    rlimit_nofile = 64,
    rlimit_nproc = 16,
    rlimit_core = 0,
    rlimit_stack = 8 * 1024 * 1024,
  },

  medium = {
    rlimit_as = 256 * 1024 * 1024,
    rlimit_cpu = 60,
    rlimit_cpu_type = "SOFT",
    rlimit_fsize = 10 * 1024 * 1024,
    rlimit_nofile = 128,
    rlimit_nproc = 32,
    rlimit_core = 0,
    rlimit_stack = 8 * 1024 * 1024,
  },

  large = {
    rlimit_as = 512 * 1024 * 1024,
    rlimit_cpu = 300,
    rlimit_cpu_type = "SOFT",
    rlimit_fsize = 50 * 1024 * 1024,
    rlimit_nofile = 256,
    rlimit_nproc = 64,
    rlimit_core = 10 * 1024 * 1024,
    rlimit_stack = 16 * 1024 * 1024,
  },
}
