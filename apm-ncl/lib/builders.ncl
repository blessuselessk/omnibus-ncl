# Convenience constructors for APM manifests and dependencies
#
# Builder functions simplify creating well-formed APM configurations.
# These are not exported to JSON — import them in .ncl files that build configs.
#
# Note: parameter names use underscored prefixes to avoid shadowing
# record field names (Nickel's self-reference detection).
let { ApmManifest, .. } = import "manifest.ncl" in
let { CompilationConfig, .. } = import "compilation.ncl" in

{
  manifest
    | doc m%"
      Build a minimal ApmManifest from name and version.

      Example:
        manifest "my-agent" "1.0.0"
    "%
    | not_exported
    = fun _name =>
      fun _version =>
        {
          name = _name,
          version = _version,
        },

  manifest_full
    | doc m%"
      Build an ApmManifest with description, author, and license.

      Example:
        manifest_full "my-agent" "1.0.0" "My agent package" "user" "MIT"
    "%
    | not_exported
    = fun _name =>
      fun _version =>
        fun _description =>
          fun _author =>
            fun _license =>
              {
                name = _name,
                version = _version,
                description = _description,
                author = _author,
                license = _license,
              },

  apm_dep
    | doc m%"
      Build an APM dependency object from a git URL.

      Example:
        apm_dep "https://github.com/anthropics/courses.git"
    "%
    | not_exported
    = fun _git =>
      {
        git = _git,
      },

  apm_dep_ref
    | doc m%"
      Build an APM dependency object with a specific ref.

      Example:
        apm_dep_ref "https://github.com/anthropics/courses.git" "main"
    "%
    | not_exported
    = fun _git =>
      fun _ref =>
        {
          git = _git,
          ref = _ref,
        },

  mcp_dep
    | doc m%"
      Build an MCP dependency object from name and transport.

      Example:
        mcp_dep "my-server" 'stdio
    "%
    | not_exported
    = fun _name =>
      fun _transport =>
        {
          name = _name,
          transport = _transport,
        },

  compilation
    | doc m%"
      Build a CompilationConfig with target and strategy.

      Example:
        compilation 'claude 'single-file
    "%
    | not_exported
    = fun _target =>
      fun _strategy =>
        {
          target = _target,
          strategy = _strategy,
        },

  lock_entry
    | doc m%"
      Build a LockEntry from required fields.

      Example:
        lock_entry "https://github.com/owner/repo" "abc123" "main" "1.0.0" "instructions" "sha256:..." ["AGENTS.md"]
    "%
    | not_exported
    = fun _repo_url =>
      fun _commit =>
        fun _ref =>
          fun _version =>
            fun _pkg_type =>
              fun _hash =>
                fun _files =>
                  {
                    repo_url = _repo_url,
                    resolved_commit = _commit,
                    resolved_ref = _ref,
                    version = _version,
                    is_virtual | default = false,
                    depth | default = 1,
                    package_type = _pkg_type,
                    content_hash = _hash,
                    is_dev | default = false,
                    deployed_files = _files,
                  },
}
