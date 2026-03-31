# GitHub Actions workflow output contracts
#
# Models the structure of a GitHub Actions workflow YAML file.
# Open records (..) allow extra fields — actions often have
# action-specific keys (with, env, id, etc.).
{
  WorkflowStep
    | doc m%"
      A single step in a GitHub Actions job.

      Open record — actions use varying fields (uses, run, with, env, id, if).
    "%
    | not_exported
    = {
      name
        | doc "Step display name"
        | String
        | optional,
      uses
        | doc "Action reference (e.g. 'actions/checkout@v4')"
        | String
        | optional,
      run
        | doc "Shell command to execute"
        | String
        | optional,
      ..
    },

  WorkflowJob
    | doc "A single job in a GitHub Actions workflow"
    | not_exported
    = {
      "runs-on"
        | doc "Runner label"
        | String,
      steps
        | doc "Ordered list of workflow steps"
        | Array WorkflowStep,
      ..
    },

  Workflow
    | doc m%"
      Complete GitHub Actions workflow file.

      The primary export target — serializes to the JSON structure
      that represents a .github/workflows/*.yml file.
    "%
    | not_exported
    = {
      name | String,
      on | { .. },
      permissions | { .. } | optional,
      jobs | { _ : WorkflowJob },
    },
}
