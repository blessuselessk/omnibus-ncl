# Deploy — bridge ralph configs to massless-driver workflow jobs
#
# A ralph loop becomes a GHA job: the runner provides compute,
# secrets provide API keys, artifacts capture the results.
let { RalphConfig, .. } = import "config.ncl" in

let get_field = fun _rec =>
  fun _field =>
    fun _default =>
      if std.record.has_field _field _rec then
        std.record.get _field _rec
      else
        _default
in

{
  to_job
    | doc m%"
      Convert a RalphConfig into a massless-driver Job.

      Maps ralph loop config → timeout, hats → description,
      backpressure gates → the script that runs them,
      and backend → required secrets.

      # Examples

      ```nickel
      to_job "my-loop" "myorg" ralph_config
      ```
    "%
    | not_exported
    = fun _name =>
      fun _owner =>
        fun _ralph =>
          let loop_cfg = get_field _ralph "event_loop" {} in
          let timeout = get_field loop_cfg "max_runtime_secs" 28800 in
          let cli = get_field _ralph "cli" {} in
          let backend = get_field cli "backend" 'claude in
          let backend_str =
            backend
            |> match {
              'claude => "claude",
              'gemini => "gemini",
              'codex => "codex",
              'auto => "auto",
              _ => "auto",
            }
          in
          let hat_names =
            if std.record.has_field "hats" _ralph then
              std.record.fields _ralph.hats
            else
              []
          in
          let secret_entries =
            # Backend API keys
            (
              if backend_str == "claude" || backend_str == "auto" then
                [{ name = "ANTHROPIC_API_KEY" }]
              else if backend_str == "gemini" then
                [{ name = "GOOGLE_API_KEY" }]
              else if backend_str == "codex" then
                [{ name = "OPENAI_API_KEY" }]
              else
                [{ name = "ANTHROPIC_API_KEY" }]
            )
            # GitHub token for worktree/merge operations
            @ [{ name = "GITHUB_TOKEN" }]
          in
          {
            name = _name,
            owner = _owner,
            script_inline =
              std.string.join
                "\n"
                [
                  "#!/usr/bin/env bash",
                  "set -euo pipefail",
                  "",
                  "# Install ralph-orchestrator",
                  "cargo install ralph-orchestrator || nix run github:mikeyobrien/ralph-orchestrator",
                  "",
                  "# Write ralph.yml from environment",
                  "echo \"$RALPH_CONFIG\" > ralph.yml",
                  "",
                  "# Start the loop",
                  "ralph start --config ralph.yml --backend %{backend_str}",
                ],
            runner = { label = "ubuntu-latest" },
            timeout_seconds = timeout + 300,
            artifacts = {
              enabled = true,
              path = ".ralph/agent",
              retention_days = 7,
            },
            secrets = { entries = secret_entries },
          },

  to_workflow
    | doc m%"
      Convert a RalphConfig directly to a GHA workflow.

      Combines to_job with massless-driver's to_workflow builder.

      # Examples

      ```nickel
      to_workflow "my-loop" "myorg" ralph_config
      ```
    "%
    | not_exported
    = fun _name =>
      fun _owner =>
        fun _ralph =>
          let MD = import "../../massless-driver/lib/builders.ncl" in
          let { Job, .. } = import "../../massless-driver/lib/job.ncl" in
          let { Workflow, .. } = import "../../massless-driver/lib/workflow.ncl" in
          let job = to_job _name _owner _ralph | Job in
          MD.to_workflow job | Workflow,
}
