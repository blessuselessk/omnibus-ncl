# Linux namespace isolation contracts
#
# Models the clone flags used by porkg for process isolation.
# porkg uses CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWUSER by default.
# This contract extends to the full set of Linux namespaces.
{
  NamespaceFlag
    | doc "Individual Linux namespace flag"
    | not_exported
    = [| 'pid, 'mount, 'user, 'net, 'ipc, 'uts, 'cgroup |],

  NamespaceConfig
    | doc m%"
      Linux namespace isolation configuration.

      Each flag controls whether that namespace is unshared (isolated)
      for the process. porkg defaults to pid + mount + user.

      # Examples

      ```nickel
      ({ pid = true, mount = true, user = true } | NamespaceConfig)
      ```
    "%
    | not_exported
    = {
      pid
        | doc "Isolate PID namespace (CLONE_NEWPID)"
        | Bool
        | default
        = true,
      mount
        | doc "Isolate mount namespace (CLONE_NEWNS)"
        | Bool
        | default
        = true,
      user
        | doc "Isolate user namespace (CLONE_NEWUSER)"
        | Bool
        | default
        = true,
      net
        | doc "Isolate network namespace (CLONE_NEWNET)"
        | Bool
        | default
        = false,
      ipc
        | doc "Isolate IPC namespace (CLONE_NEWIPC)"
        | Bool
        | default
        = false,
      uts
        | doc "Isolate UTS namespace (CLONE_NEWUTS)"
        | Bool
        | default
        = false,
      cgroup
        | doc "Isolate cgroup namespace (CLONE_NEWCGROUP)"
        | Bool
        | default
        = false,
    },

  # -- Presets matching common isolation patterns --

  porkg_default
    | doc "porkg's default: PID + mount + user isolation"
    = { pid = true, mount = true, user = true },

  full_isolation
    | doc "All namespaces isolated"
    = {
      pid = true,
      mount = true,
      user = true,
      net = true,
      ipc = true,
      uts = true,
      cgroup = true,
    },

  minimal
    | doc "Minimal isolation — PID namespace only"
    = { pid = true },

  network_isolated
    | doc "PID + mount + user + network isolation"
    = { pid = true, mount = true, user = true, net = true },
}
