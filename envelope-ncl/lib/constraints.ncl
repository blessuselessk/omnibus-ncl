# Constraints — the permission/resource boundary of a runtime envelope
#
# Models what an envelope is ALLOWED to do: network access, filesystem
# access, resource limits, and environment. Each field is a capability
# that outer envelopes grant and inner envelopes can only restrict.
{
  NetworkMode
    | doc "Network access level — ordered from most to least restrictive"
    | not_exported
    = [| 'deny, 'localhost, 'whitelist, 'full |],

  NetworkConstraint
    | doc m%"
      Network access boundary.

      Modes are ordered: deny < localhost < whitelist < full.
      An inner envelope's mode cannot exceed the outer's.
    "%
    | not_exported
    = {
      mode
        | doc "Network access level"
        | NetworkMode
        | default
        = 'deny,
      allowed_hosts
        | doc "Host whitelist (only meaningful when mode = 'whitelist)"
        | Array String
        | default
        = [],
    },

  FsMode
    | doc "Filesystem access level"
    | not_exported
    = [| 'none, 'ro, 'whitelist, 'rw |],

  FsConstraint
    | doc m%"
      Filesystem access boundary.

      Modes are ordered: none < ro < whitelist < rw.
      Allowed paths in an inner envelope must be a subset of the outer's.
    "%
    | not_exported
    = {
      mode
        | doc "Filesystem access level"
        | FsMode
        | default
        = 'ro,
      allowed_paths
        | doc "Path whitelist (meaningful for 'whitelist and 'rw modes)"
        | Array String
        | default
        = [],
    },

  ResourceLimits
    | doc m%"
      Resource ceilings — CPU, memory, file descriptors, timeout.

      Inner envelope limits must be <= outer envelope limits.
    "%
    | not_exported
    = {
      max_memory_mb
        | doc "Maximum memory in megabytes"
        | Number
        | default
        = 256,
      max_cpu_seconds
        | doc "Maximum CPU time in seconds"
        | Number
        | default
        = 60,
      max_file_descriptors
        | doc "Maximum open file descriptors"
        | Number
        | default
        = 128,
      timeout_seconds
        | doc "Hard wall-clock timeout"
        | Number
        | default
        = 300,
    },

  Constraints
    | doc m%"
      Complete constraint set for a runtime envelope.

      Defines what the envelope is allowed to do — network, filesystem,
      resources, and environment variables. Each field represents a
      capability boundary that inner envelopes can only narrow.

      # Examples

      ```nickel
      ({ network = { mode = 'deny }, fs = { mode = 'ro } } | Constraints)
      ```
    "%
    | not_exported
    = {
      network
        | doc "Network access boundary"
        | NetworkConstraint
        | default
        = {},
      fs
        | doc "Filesystem access boundary"
        | FsConstraint
        | default
        = {},
      resources
        | doc "Resource ceilings"
        | ResourceLimits
        | default
        = {},
      env
        | doc "Allowed environment variable names (empty = all allowed)"
        | Array String
        | default
        = [],
      secrets
        | doc "Named secrets to inject"
        | Array String
        | default
        = [],
    },

  # -- Constraint presets --

  strict
    | doc "Maximum restriction — no network, read-only fs, minimal resources"
    = {
      network = { mode = 'deny },
      fs = { mode = 'ro },
      resources = {
        max_memory_mb = 64,
        max_cpu_seconds = 10,
        max_file_descriptors = 32,
        timeout_seconds = 30,
      },
    },

  standard
    | doc "Moderate restriction — localhost network, read-only fs"
    = {
      network = { mode = 'localhost },
      fs = { mode = 'ro },
      resources = {
        max_memory_mb = 256,
        max_cpu_seconds = 60,
        max_file_descriptors = 128,
        timeout_seconds = 300,
      },
    },

  permissive
    | doc "Light restriction — full network, read-write fs, generous resources"
    = {
      network = { mode = 'full },
      fs = { mode = 'rw },
      resources = {
        max_memory_mb = 1024,
        max_cpu_seconds = 600,
        max_file_descriptors = 1024,
        timeout_seconds = 3600,
      },
    },
}
