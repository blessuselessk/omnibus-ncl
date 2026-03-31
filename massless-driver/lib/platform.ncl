# Build platform matrix (os/arch pairs)
#
# Models the cross-compilation targets from the Go Makefile.
# The default_matrix is exported data — usable for build matrix generation.
{
  PlatformOs
    | doc "Target operating system"
    | not_exported
    = [| 'linux, 'darwin, 'windows |],

  PlatformArch
    | doc "Target CPU architecture"
    | not_exported
    = [| 'amd64, 'arm64, 'armhf |],

  Platform
    | doc m%"
      A single OS + architecture platform target.

      # Examples

      ```nickel
      ({ os = 'linux, arch = 'amd64 } | Platform)
      # => { os = "linux", arch = "amd64" }
      ```
    "%
    | not_exported
    = {
      os | PlatformOs,
      arch | PlatformArch,
    },

  default_matrix
    | doc "Default platform matrix matching the Go Makefile dist targets"
    = [
      { os = 'linux, arch = 'amd64 },
      { os = 'linux, arch = 'arm64 },
      { os = 'linux, arch = 'armhf },
      { os = 'darwin, arch = 'amd64 },
      { os = 'darwin, arch = 'arm64 },
      { os = 'windows, arch = 'amd64 },
    ],
}
