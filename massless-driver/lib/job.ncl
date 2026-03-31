# Core Job contract — the central type
#
# A Job is everything needed to generate a GitHub Actions workflow
# and run it on an ephemeral repo. Maps to the full CLI flag surface
# of the Go massless-driver.
let { Runner, .. } = import "runner.ncl" in
let { SecretsConfig, .. } = import "secrets.ncl" in
let { ArtifactConfig, ReleaseConfig, .. } = import "artifacts.ncl" in
let { TailscaleConfig, .. } = import "tailscale.ncl" in
let { NixConfig, .. } = import "nix.ncl" in

{
  Job
    | doc m%"
      Core job configuration — the central type.

      Represents everything needed to generate a workflow and execute it
      on an ephemeral GitHub repository. Maps 1:1 with the Go CLI's flag surface.

      # Examples

      ```nickel
      ({ name = "hello", owner = "myorg", script = "hello.sh" } | Job)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Job name (used in workflow name and ephemeral repo)"
        | String,
      owner
        | doc "GitHub owner or org for the ephemeral repo"
        | String,
      script
        | doc "Path to the shell script to execute"
        | String
        | optional,
      script_inline
        | doc "Inline script content (alternative to file path)"
        | String
        | optional,
      variant
        | doc "Workflow variant: bash (default) or nix"
        | [| 'bash, 'nix |]
        | default
        = 'bash,
      runner
        | doc "Runner specification"
        | Runner
        | default
        = {},
      visibility
        | doc "Ephemeral repo visibility"
        | [| 'private, 'public |]
        | default
        = 'private,
      secrets
        | doc "Secrets to inject into the workflow"
        | SecretsConfig
        | default
        = {},
      artifacts
        | doc "Artifact collection configuration"
        | ArtifactConfig
        | default
        = {},
      release
        | doc "Release persistence configuration"
        | ReleaseConfig
        | default
        = {},
      tailscale
        | doc "Tailscale mesh networking"
        | TailscaleConfig
        | default
        = {},
      nix
        | doc "Nix flake configuration (required when variant = 'nix)"
        | NixConfig
        | optional,
      timeout_seconds
        | doc "Maximum wait time for job completion in seconds"
        | Number
        | default
        = 360,
      auto_delete
        | doc "Automatically delete ephemeral repo after completion"
        | Bool
        | default
        = true,
    },
}
