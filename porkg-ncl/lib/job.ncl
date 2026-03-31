# Job process contracts
#
# A Job is the innermost layer in porkg's hierarchy.
# Jobs are spawned by Workers and run in isolated namespaces
# inherited from their parent Worker.
let { NamespaceConfig, .. } = import "namespace.ncl" in

{
  JobSpec
    | doc m%"
      Job specification — what a Worker spawns and runs.

      Jobs inherit namespace isolation from their parent Worker
      and can add further restrictions.

      # Examples

      ```nickel
      ({
        name = "build-package",
        command = ["nix", "build", ".#default"],
        env = { NIX_LOG_DIR = "/tmp/nix-log" },
      } | JobSpec)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Job identifier"
        | String,
      command
        | doc "Command and arguments to execute"
        | Array String,
      env
        | doc "Environment variables to set"
        | { _ : String }
        | default
        = {},
      working_dir
        | doc "Working directory for the job"
        | String
        | optional,
      additional_namespaces
        | doc "Extra namespace isolation beyond the worker's"
        | NamespaceConfig
        | optional,
      timeout_seconds
        | doc "Job-level timeout (overrides worker default)"
        | Number
        | optional,
      allowed_paths
        | doc "Filesystem paths the job can access"
        | Array String
        | default
        = [],
    },

  JobResult
    | doc m%"
      Expected shape of a completed job result.

      Used for manifest tracking and pipeline composition.
    "%
    | not_exported
    = {
      name | String,
      exit_code | Number,
      outputs
        | doc "Paths or artifacts produced"
        | Array String
        | default
        = [],
    },
}
