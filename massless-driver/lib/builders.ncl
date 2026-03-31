# Builder functions for massless-driver
#
# Replaces Go's templates/render.go — one composable builder handles
# both bash and nix workflow variants via enum dispatch.
#
# Note: parameter names prefixed with _ to avoid Nickel self-reference
# detection (field `x = x` triggers infinite recursion).
let S = import "steps.ncl" in

{
  # -- Job constructors --

  job
    | doc m%"
      Build a minimal bash job from name, owner, and script path.

      # Examples

      ```nickel
      job "hello" "myorg" "hello.sh"
      # => { name = "hello", owner = "myorg", script = "hello.sh" }
      ```
    "%
    | not_exported
    = fun _name =>
      fun _owner =>
        fun _script =>
          {
            name = _name,
            owner = _owner,
            script = _script,
          },

  nix_job
    | doc m%"
      Build a Nix flake job from name, owner, and flake reference.

      # Examples

      ```nickel
      nix_job "build" "myorg" "github:owner/repo#pkg"
      ```
    "%
    | not_exported
    = fun _name =>
      fun _owner =>
        fun _flake_ref =>
          {
            name = _name,
            owner = _owner,
            variant = 'nix,
            nix = { flake_ref = _flake_ref },
          },

  # -- Internal helpers --

  secrets_env
    | doc "Map secret entries to GitHub Actions secret references"
    | not_exported
    = fun _entries =>
      std.array.fold_left
        (fun acc entry => acc & { "%{entry.name}" = "${{ secrets.%{entry.name} }}" })
        {}
        _entries,

  assemble_steps
    | doc "Assemble the ordered steps array for a job"
    | not_exported
    = fun _job =>
      let base = [S.checkout] in
      let ts_steps =
        if _job.tailscale.enabled then
          [S.tailscale_join _job.tailscale]
        else
          []
      in
      let nix_steps =
        if _job.variant == 'nix then
          [S.nix_installer _job.nix.installer_version]
          @ (
            if _job.nix.cache_enabled then
              [S.nix_cache _job.nix.cache_version]
            else
              []
          )
        else
          []
      in
      let run_step =
        if _job.variant == 'nix then
          [S.run_nix_flake _job.nix.flake_ref]
        else
          [S.run_script (secrets_env _job.secrets.entries)]
      in
      let artifact_steps =
        if _job.artifacts.enabled then
          [S.check_uploads, S.upload_artifact _job.name _job.artifacts]
        else
          []
      in
      base @ ts_steps @ nix_steps @ run_step @ artifact_steps,

  # -- Main builders --

  to_workflow
    | doc m%"
      Transform a Job into a complete GitHub Actions Workflow record.

      This is the primary export — produces the structure that serializes
      to workflow YAML. Handles both bash and nix variants in one function,
      replacing the two separate Go text/templates.

      # Examples

      ```nickel
      let j = job "test" "myorg" "test.sh" in
      to_workflow j
      ```
    "%
    | not_exported
    = fun _job =>
      {
        name = _job.name,
        on = {
          pull_request = {},
          push = { branches = ["master", "main"] },
        },
        permissions = {
          "id-token" = "write",
          contents = "write",
          checks = "write",
          actions = "write",
          issues = "write",
          packages = "write",
          statuses = "write",
        },
        jobs = {
          build = {
            "runs-on" = _job.runner.label,
            steps = assemble_steps _job,
          },
        },
      },

  to_manifest
    | doc m%"
      Transform a Job into a flat runtime manifest record.

      Used by the Go CLI to read job configuration from a JSON file
      rather than CLI flags.
    "%
    | not_exported
    = fun _job =>
      {
        name = _job.name,
        owner = _job.owner,
        variant =
          _job.variant
          |> match {
            'bash => "bash",
            'nix => "nix",
          },
        runner = _job.runner.label,
        timeout_seconds = _job.timeout_seconds,
        auto_delete = _job.auto_delete,
        visibility =
          _job.visibility
          |> match {
            'private => "private",
            'public => "public",
          },
        artifacts_enabled = _job.artifacts.enabled,
        release_enabled = _job.release.enabled,
        tailscale_enabled = _job.tailscale.enabled,
        secret_count = std.array.length _job.secrets.entries,
      },
}
