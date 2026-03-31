# Reusable workflow step definitions
#
# Each step is either a plain record (for static steps) or a function
# that takes config and returns a record (for parameterized steps).
# Replaces the three Go template files: workflow.yaml, workflow-nix.yaml,
# and tailscale-step.yaml.
{
  checkout
    | doc "Standard repo checkout step"
    | not_exported
    = {
      name = "Checkout",
      uses = "actions/checkout@v4",
    },

  nix_installer
    | doc "DeterminateSystems Nix installer step"
    | not_exported
    = fun _version =>
      {
        name = "Install Nix",
        uses = "DeterminateSystems/nix-installer-action@%{_version}",
      },

  nix_cache
    | doc "DeterminateSystems magic Nix cache step"
    | not_exported
    = fun _version =>
      {
        name = "Setup Nix Cache",
        uses = "DeterminateSystems/magic-nix-cache-action@%{_version}",
      },

  tailscale_join
    | doc "Tailscale mesh join step using tailscale/github-action"
    | not_exported
    = fun _config =>
      {
        name = "Join Tailscale",
        uses = "tailscale/github-action@%{_config.version}",
        with = {
          authkey = "${{ secrets.%{_config.auth_key_secret} }}",
        },
      },

  run_script
    | doc "Execute job.sh with secret environment variables"
    | not_exported
    = fun _secrets_env =>
      {
        name = "Run Job",
        run = "chmod +x job.sh && ./job.sh",
      }
      & (
        if _secrets_env != {} then
          { env = _secrets_env }
        else
          {}
      ),

  run_nix_flake
    | doc "Execute nix run with a flake reference"
    | not_exported
    = fun _flake_ref =>
      {
        name = "Run Nix Job",
        run = "nix run %{_flake_ref}",
      },

  check_uploads
    | doc "Check for uploads directory existence"
    | not_exported
    = {
      name = "Check for uploads",
      id = "check_uploads",
      run = "test -d ./uploads && echo 'has_uploads=true' >> $GITHUB_OUTPUT || echo 'has_uploads=false' >> $GITHUB_OUTPUT",
    },

  upload_artifact
    | doc "Upload artifact with configurable name and retention"
    | not_exported
    = fun _name =>
      fun _config =>
        {
          name = "Upload artifact",
          uses = "actions/upload-artifact@v4",
          "if" = "steps.check_uploads.outputs.has_uploads == 'true'",
          with = {
            name = _name,
            path = _config.upload_path,
            "retention-days" = _config.retention_days,
            "compression-level" = 1,
          },
        },
}
