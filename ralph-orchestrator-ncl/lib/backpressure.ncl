# Backpressure — quality gates that block iteration until satisfied
#
# Each gate is a command that must pass before the next iteration.
# Failed gates force the agent to fix the issue before proceeding.
{
  GateFailureMode
    | doc "What happens when a gate fails"
    | not_exported
    = [| 'strict, 'warn, 'skip |],

  Gate
    | doc m%"
      A quality gate that must pass for iteration to proceed.

      # Examples

      ```nickel
      ({ name = "tests", cmd = "cargo test", on_failure = 'strict } | Gate)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Gate identifier"
        | String,
      cmd
        | doc "Command to run"
        | String,
      on_failure
        | doc "strict = block iteration, warn = log and continue, skip = ignore"
        | GateFailureMode
        | default
        = 'strict,
      timeout_secs
        | doc "Gate timeout"
        | Number
        | optional,
    },

  BackpressureConfig
    | doc m%"
      Full backpressure configuration — ordered list of quality gates.

      Gates run in order. Strict gates block; warn gates log.
    "%
    | not_exported
    = {
      gates
        | Array Gate
        | default
        = [],
      max_consecutive_failures
        | doc "Abort after this many consecutive gate failures"
        | Number
        | default
        = 3,
    },

  # -- Presets --

  rust_gates
    | doc "Standard Rust quality gates"
    = {
      gates = [
        { name = "check", cmd = "cargo check --all-targets", on_failure = 'strict },
        { name = "clippy", cmd = "cargo clippy --all-targets -- -D warnings", on_failure = 'strict },
        { name = "test", cmd = "cargo test", on_failure = 'strict },
        { name = "fmt", cmd = "cargo fmt --check", on_failure = 'warn },
      ],
    },

  nix_gates
    | doc "Standard Nix quality gates"
    = {
      gates = [
        { name = "check", cmd = "nix flake check", on_failure = 'strict },
        { name = "fmt", cmd = "nix fmt -- --check", on_failure = 'warn },
      ],
    },

  nickel_gates
    | doc "Nickel quality gates for omnibus-ncl"
    = {
      gates = [
        { name = "examples", cmd = "just test-examples", on_failure = 'strict },
        { name = "fmt", cmd = "nix fmt -- --check", on_failure = 'warn },
      ],
    },
}
