# Envelope — the composable runtime boundary
#
# An Envelope wraps a payload with constraints and a target.
# Envelopes nest: an inner envelope runs inside an outer one,
# with the invariant that inner constraints never exceed outer.
let { Payload, .. } = import "payload.ncl" in
let { Constraints, .. } = import "constraints.ncl" in
let { Target, .. } = import "target.ncl" in

{
  Envelope
    | doc m%"
      A composable runtime envelope.

      Wraps a payload (what to run) with constraints (what's allowed)
      and a target (where it runs). Envelopes can nest — the `inner`
      field holds another Envelope that runs inside this one.

      Invariant: inner constraints must not exceed outer constraints.
      Use the `nest` builder to enforce this at composition time.

      # Examples

      ```nickel
      ({
        name = "sandboxed-jq",
        payload = { kind = 'nix_flake, flake_ref = "nixpkgs#jq" },
        constraints = { network = { mode = 'deny }, fs = { mode = 'ro } },
        target = { kind = 'sandbox, sandbox_backend = 'nsjail },
      } | Envelope)
      ```
    "%
    | not_exported
    = {
      name
        | doc "Human-readable envelope name"
        | String,
      payload
        | doc "What this envelope executes"
        | Payload,
      constraints
        | doc "Permission and resource boundaries"
        | Constraints
        | default
        = {},
      target
        | doc "Where this envelope runs"
        | Target,
      inner
        | doc "Nested envelope (runs inside this one)"
        | Envelope
        | optional,
      metadata
        | doc "Arbitrary key-value metadata"
        | { .. }
        | optional,
    },
}
