# Builders — convenience constructors for ralph configs
let H = import "hat.ncl" in
let BP = import "backpressure.ncl" in

{
  hat
    | doc "Build a hat from name, description, subscriptions, and publishes"
    | not_exported
    = fun _name =>
      fun _desc =>
        fun _subs =>
          fun _pubs =>
            {
              name = _name,
              description = _desc,
              subscriptions = _subs,
              publishes = _pubs,
            },

  hat_with_instructions
    | doc "Build a hat with custom instructions"
    | not_exported
    = fun _name =>
      fun _desc =>
        fun _subs =>
          fun _pubs =>
            fun _instructions =>
              {
                name = _name,
                description = _desc,
                subscriptions = _subs,
                publishes = _pubs,
                instructions = _instructions,
              },

  skill
    | doc "Build a skill from name, description, and content"
    | not_exported
    = fun _name =>
      fun _desc =>
        fun _content =>
          {
            name = _name,
            description = _desc,
            content = _content,
          },

  gate
    | doc "Build a strict quality gate"
    | not_exported
    = fun _name =>
      fun _cmd =>
        { name = _name, cmd = _cmd, on_failure = 'strict },

  warn_gate
    | doc "Build a warning-only quality gate"
    | not_exported
    = fun _name =>
      fun _cmd =>
        { name = _name, cmd = _cmd, on_failure = 'warn },

  config
    | doc m%"
      Build a ralph config from hats and backpressure gates.

      # Examples

      ```nickel
      config
        { planner = H.default_planner, builder = H.default_builder }
        BP.rust_gates
      ```
    "%
    | not_exported
    = fun _hats =>
      fun _backpressure =>
        {
          hats = _hats,
          core = { guardrails = _backpressure },
        },

  # Re-export hat presets for convenience
  default_planner = H.default_planner,
  default_builder = H.default_builder,
  default_reviewer = H.default_reviewer,
  default_finalizer = H.default_finalizer,

  # Re-export gate presets
  rust_gates = BP.rust_gates,
  nix_gates = BP.nix_gates,
  nickel_gates = BP.nickel_gates,
}
