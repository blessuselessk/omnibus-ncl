# Secret definition contracts
#
# Secrets are name-only in the Nickel layer — actual values exist only
# at runtime (NaCL-encrypted via the Go CLI). The workflow references
# them as ${{ secrets.NAME }}.
{
  Secret
    | doc m%"
      A single secret to inject into the workflow environment.

      Only the name is modeled — values are injected at runtime
      via the GitHub Secrets API with NaCL encryption.

      # Examples

      ```nickel
      ({ name = "API_KEY" } | Secret)
      # => { name = "API_KEY" }
      ```
    "%
    | not_exported
    = {
      name
        | doc "Secret name (becomes env var and GitHub secret key)"
        | String,
    },

  SecretsConfig
    | doc m%"
      Secrets configuration for a job.

      # Examples

      ```nickel
      ({ entries = [{ name = "TOKEN" }] } | SecretsConfig)
      # => { entries = [{ name = "TOKEN" }] }
      ```
    "%
    | not_exported
    = {
      entries
        | doc "List of secrets to inject"
        | Array Secret
        | default
        = [],
    },
}
