# Nix flake configuration for nix-flavored jobs
#
# When a job uses variant = 'nix, this config controls the flake
# reference, Nix installer, and cache setup.
{
  NixConfig
    | doc m%"
      Nix flake configuration for jobs that run `nix run` instead of a shell script.

      Uses DeterminateSystems actions for Nix installation and caching.

      # Examples

      ```nickel
      ({ flake_ref = "github:owner/repo#package" } | NixConfig)
      # => { flake_ref = "github:owner/repo#package", installer_version = "main", cache_enabled = true, cache_version = "main" }
      ```
    "%
    | not_exported
    = {
      flake_ref
        | doc "Nix flake reference (e.g. 'github:owner/repo#package')"
        | String,
      installer_version
        | doc "DeterminateSystems/nix-installer-action version"
        | String
        | default
        = "main",
      cache_enabled
        | doc "Whether to enable magic-nix-cache-action"
        | Bool
        | default
        = true,
      cache_version
        | doc "DeterminateSystems/magic-nix-cache-action version"
        | String
        | default
        = "main",
    },
}
