# Artifact configuration and tracking contracts
#
# Models both the job-level artifact config (upload/download settings)
# and the persistent artifact manifest (~/.config/actions-batch/artifacts.json).
{
  ArtifactConfig
    | doc m%"
      Artifact upload and download configuration for a job.

      When enabled, the workflow checks for an uploads directory
      and uses actions/upload-artifact to persist files.

      # Examples

      ```nickel
      ({ enabled = true, retention_days = 3 } | ArtifactConfig)
      # => { enabled = true, path = "./uploads", retention_days = 3, upload_path = "./uploads/" }
      ```
    "%
    | not_exported
    = {
      enabled
        | doc "Whether to download artifacts after job completion"
        | Bool
        | default
        = false,
      path
        | doc "Local download path for artifacts"
        | String
        | default
        = "./uploads",
      retention_days
        | doc "Days to retain artifacts on GitHub"
        | Number
        | default
        = 1,
      upload_path
        | doc "In-runner path to upload directory"
        | String
        | default
        = "./uploads/",
    },

  ReleaseConfig
    | doc m%"
      Persist artifacts to a GitHub release after job completion.

      # Examples

      ```nickel
      ({ enabled = true } | ReleaseConfig)
      # => { enabled = true, tag_prefix = "run-" }
      ```
    "%
    | not_exported
    = {
      enabled
        | doc "Whether to persist artifacts to a release"
        | Bool
        | default
        = false,
      tag_prefix
        | doc "Prefix for release tags"
        | String
        | default
        = "run-",
    },

  ArtifactRun
    | doc m%"
      Record of a completed artifact run.

      Stored in the persistent manifest at
      ~/.config/actions-batch/artifacts.json.
    "%
    | not_exported
    = {
      name | String,
      at | String,
      script | String,
      runner | String,
      local_path | String,
      files
        | Array String
        | default
        = [],
      release
        | String
        | optional,
    },

  ArtifactManifest
    | doc "Persistent artifact manifest tracking all runs"
    | not_exported
    = {
      runs
        | Array ArtifactRun
        | default
        = [],
    },
}
