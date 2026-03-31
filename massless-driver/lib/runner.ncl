# Runner specification for GitHub Actions jobs
#
# Runner labels are plain strings — GitHub Actions supports arbitrary
# labels for self-hosted and custom runners (actuated, buildjet, etc.).
# Presets provide typed shortcuts for common GitHub-hosted runners.
{
  Runner
    | doc m%"
      GitHub Actions runner specification.

      The label field maps directly to `runs-on` in the workflow YAML.
      Use any string — GitHub-hosted ("ubuntu-latest"), self-hosted,
      or third-party runner labels.

      # Examples

      ```nickel
      ({} | Runner)
      # => { label = "ubuntu-latest" }

      ({ label = "macos-14" } | Runner)
      # => { label = "macos-14" }
      ```
    "%
    | not_exported
    = {
      label
        | doc "Runner label string passed to runs-on"
        | String
        | default
        = "ubuntu-latest",
    },

  # -- GitHub-hosted runner presets --

  ubuntu_latest
    | doc "Ubuntu latest (x64)"
    = { label = "ubuntu-latest" },

  ubuntu_24_04
    | doc "Ubuntu 24.04 LTS (x64)"
    = { label = "ubuntu-24.04" },

  ubuntu_22_04
    | doc "Ubuntu 22.04 LTS (x64)"
    = { label = "ubuntu-22.04" },

  macos_latest
    | doc "macOS latest (Apple Silicon)"
    = { label = "macos-latest" },

  macos_15
    | doc "macOS 15 Sequoia (Apple Silicon)"
    = { label = "macos-15" },

  macos_14
    | doc "macOS 14 Sonoma (Apple Silicon)"
    = { label = "macos-14" },

  macos_13
    | doc "macOS 13 Ventura (Intel x64)"
    = { label = "macos-13" },

  macos_15_large
    | doc "macOS 15 large runner (Intel x64, 12 cores)"
    = { label = "macos-15-large" },

  macos_14_large
    | doc "macOS 14 large runner (Intel x64, 12 cores)"
    = { label = "macos-14-large" },

  macos_13_xlarge
    | doc "macOS 13 xlarge runner (Apple Silicon, M1, 6 cores)"
    = { label = "macos-13-xlarge" },

  windows_latest
    | doc "Windows Server latest (x64)"
    = { label = "windows-latest" },

  windows_2022
    | doc "Windows Server 2022 (x64)"
    = { label = "windows-2022" },
}
