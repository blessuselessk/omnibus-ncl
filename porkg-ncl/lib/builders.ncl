# Builder functions for porkg-ncl
#
# Convenience constructors for porkg configurations.
# Builds are composable via record merge (&).
let { default_messages, .. } = import "proto.ncl" in

{
  worker
    | doc m%"
      Build a worker config from a name.

      # Examples

      ```nickel
      worker "build-worker"
      # => { name = "build-worker" }
      ```
    "%
    | not_exported
    = fun _name =>
      { name = _name },

  job
    | doc m%"
      Build a job spec from name and command.

      # Examples

      ```nickel
      job "build" ["make", "all"]
      # => { name = "build", command = ["make", "all"] }
      ```
    "%
    | not_exported
    = fun _name =>
      fun _command =>
        { name = _name, command = _command },

  job_with_env
    | doc m%"
      Build a job spec with environment variables.

      # Examples

      ```nickel
      job_with_env "build" ["make"] { CC = "gcc" }
      ```
    "%
    | not_exported
    = fun _name =>
      fun _command =>
        fun _env =>
          { name = _name, command = _command, env = _env },

  nix_build_job
    | doc m%"
      Build a Nix build job for a flake output.

      # Examples

      ```nickel
      nix_build_job "build-cli" ".#default"
      ```
    "%
    | not_exported
    = fun _name =>
      fun _flake_output =>
        {
          name = _name,
          command = ["nix", "build", _flake_output],
          env = { NIX_CONFIG = "experimental-features = nix-command flakes" },
        },

  config
    | doc m%"
      Build a complete porkg config from a worker name and list of jobs.

      # Examples

      ```nickel
      config "builder" [
        job "build" ["make", "all"],
        job "test" ["make", "test"],
      ]
      ```
    "%
    | not_exported
    = fun _worker_name =>
      fun _jobs =>
        {
          worker = { name = _worker_name },
          jobs = _jobs,
          tag_map = { messages = default_messages },
        },

  # -- Namespace preset shortcuts --

  with_full_isolation
    | doc "Add full namespace isolation to a worker config"
    | not_exported
    = fun _worker =>
      _worker
      & {
        namespaces = {
          pid = true,
          mount = true,
          user = true,
          net = true,
          ipc = true,
          uts = true,
          cgroup = true,
        },
      },

  with_network_isolation
    | doc "Add network namespace isolation to a worker config"
    | not_exported
    = fun _worker =>
      _worker
      & {
        namespaces = {
          pid = true,
          mount = true,
          user = true,
          net = true,
        },
      },

  without_escalation
    | doc "Disable privilege escalation on a worker config"
    | not_exported
    = fun _worker =>
      _worker
      & {
        privilege = {
          allow_escalation = false,
          rules = [],
        },
      },
}
