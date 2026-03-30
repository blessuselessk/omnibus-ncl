# APM lockfile contracts — models apm.lock.yaml
#
# The lockfile pins exact versions and commits for reproducible installs.
{
  LockEntry
    | doc m%"
      A single resolved dependency in the lockfile.
      Captures the exact commit, version, and content hash.
    "%
    | not_exported
    = {
      repo_url | String,
      host | String | optional,
      resolved_commit | String,
      resolved_ref | String,
      version | String,
      virtual_path | String | optional,
      is_virtual | Bool,
      depth | Number,
      resolved_by | String | optional,
      package_type | String,
      content_hash | String,
      is_dev | Bool,
      deployed_files | Array String,
      ..
    },

  ApmLockfile
    | doc m%"
      Top-level APM lockfile (apm.lock.yaml).
      Pins every dependency to a specific commit and content hash.
    "%
    | not_exported
    = {
      lockfile_version | String,
      generated_at | String,
      apm_version | String,
      dependencies | Array LockEntry,
      mcp_servers | Array String | optional,
      ..
    },
}
