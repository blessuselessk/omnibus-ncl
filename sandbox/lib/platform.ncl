# platform.ncl - Platform Detection
#
# Detect and configure based on the current platform.
{
  linux = {
    name = "linux",
    seccomp_available = true,
    cgroups_available = true,
    namespaces_available = true,
  },
  macos = {
    name = "macos",
    seccomp_available = false,
    cgroups_available = false,
    namespaces_available = false,
  },
  windows = {
    name = "windows",
    seccomp_available = false,
    cgroups_available = false,
    namespaces_available = false,
  },
}
