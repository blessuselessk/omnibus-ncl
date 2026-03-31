# Ralph config for developing omnibus-ncl itself
#
# Four hats: planner, builder, reviewer, finalizer.
# Nickel-specific quality gates. Skills for nickel tooling.
let B = import "../lib/builders.ncl" in
let H = import "../lib/hat.ncl" in

B.config
  {
    planner =
      H.default_planner
      & {
        instructions = m%"
          You're working on omnibus-ncl, a Nickel configuration repo.
          Read the nickel-*.md guides before planning. Break work into
          subproject-scoped tasks. Each task = one lib/ file or one example.
        "%,
      },
    builder =
      H.default_builder
      & {
        instructions = m%"
          Follow nickel-best-practices.md strictly. Use contracts (|) not
          types (:). Prefix builder params with _. Run `just test-examples`
          after every change. Emit build.blocked if nickel export fails.
        "%,
      },
    reviewer = H.default_reviewer,
    finalizer = H.default_finalizer,
  }
  B.nickel_gates
& {
  event_loop = {
    max_iterations = 50,
    max_runtime_secs = 7200,
  },
  cli = { backend = 'claude },
  skills = [
    B.skill
      "nickel-conventions"
      "Nickel coding conventions for this repo"
      m%"
        ## Nickel Conventions
        - Contracts (|) over bare types (:)
        - Enum tags ('deny, 'seatbelt) over strings
        - Record merge (&) for composition
        - Schema-config separation
        - Clean export: separate data from functions (not_exported)
        - snake_case vars, PascalCase types, 'lowercase tags
      "%
    & { tags = ["nickel", "style"] },
    B.skill
      "subproject-structure"
      "Standard subproject layout"
      m%"
        ## Subproject Structure
        ```
        name/
        ├── main.ncl           (top-level re-export)
        ├── lib/
        │   ├── main.ncl       (re-exports all modules)
        │   ├── contracts.ncl  (domain types)
        │   └── builders.ncl   (convenience constructors)
        ├── examples/
        │   ├── example.ncl    (concrete configs)
        │   └── *-export.ncl   (validated export wrappers)
        └── tests/
            ├── validate.sh    (test harness)
            └── snapshot.json  (committed baseline)
        ```
      "%
    & { tags = ["structure", "patterns"] },
  ],
}
