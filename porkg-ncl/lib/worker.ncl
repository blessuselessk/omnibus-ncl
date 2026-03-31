# Worker process contracts
#
# A Worker is the middle layer in porkg's process hierarchy:
# parent → worker → job. Workers manage namespace isolation,
# privilege escalation, and job spawning.
let { NamespaceConfig, .. } = import "namespace.ncl" in
let { PrivilegeConfig, .. } = import "privilege.ncl" in
let { ProtoConfig, .. } = import "proto.ncl" in

{
  WorkerConfig
    | doc m%"
      Worker process configuration.

      Controls namespace isolation, privilege model, protocol settings,
      and shutdown behavior.

      # Examples

      ```nickel
      ({ name = "build-worker" } | WorkerConfig)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Worker identifier"
        | String
        | default
        = "worker",
      namespaces
        | doc "Linux namespace isolation flags"
        | NamespaceConfig
        | default
        = {},
      privilege
        | doc "Privilege escalation configuration"
        | PrivilegeConfig
        | default
        = {},
      proto
        | doc "IPC protocol configuration"
        | ProtoConfig
        | default
        = {},
      shutdown_timeout_seconds
        | doc "Graceful shutdown timeout"
        | Number
        | default
        = 5,
      max_jobs
        | doc "Maximum concurrent jobs (0 = unlimited)"
        | Number
        | default
        = 0,
      reenter_binary
        | doc "Binary path for process reentry (self by default)"
        | String
        | optional,
    },
}
