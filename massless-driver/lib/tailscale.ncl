# Tailscale mesh networking configuration
#
# When enabled, adds a workflow step that joins the runner to a
# Tailscale tailnet as an ephemeral node, enabling inter-runner
# communication for distributed jobs.
{
  TailscaleConfig
    | doc m%"
      Tailscale mesh networking configuration for ephemeral runners.

      Uses tailscale/github-action to join the runner to a tailnet.
      The auth key must be stored as a GitHub secret.

      # Examples

      ```nickel
      ({ enabled = true } | TailscaleConfig)
      # => { enabled = true, auth_key_secret = "TAILSCALE_AUTHKEY", version = "v2" }
      ```
    "%
    | not_exported
    = {
      enabled
        | doc "Whether to enable Tailscale mesh join"
        | Bool
        | default
        = false,
      auth_key_secret
        | doc "Name of the GitHub secret containing the Tailscale auth key"
        | String
        | default
        = "TAILSCALE_AUTHKEY",
      version
        | doc "Tailscale GitHub Action version tag"
        | String
        | default
        = "v2",
    },
}
