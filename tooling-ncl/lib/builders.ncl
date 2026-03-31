# Builders — convenience constructors for CodeNodes
{
  bash
    | doc m%"
      Build a bash CodeNode.

      # Examples

      ```nickel
      bash "filter" "jq '.name'"
      ```
    "%
    | not_exported
    = fun _name =>
      fun _code =>
        {
          name = _name,
          lang = 'bash,
          code = _code,
        },

  nickel
    | doc "Build a nickel CodeNode"
    | not_exported
    = fun _name =>
      fun _code =>
        {
          name = _name,
          lang = 'nickel,
          code = _code,
        },

  nushell
    | doc "Build a nushell CodeNode"
    | not_exported
    = fun _name =>
      fun _code =>
        {
          name = _name,
          lang = 'nushell,
          code = _code,
        },

  python
    | doc "Build a python CodeNode"
    | not_exported
    = fun _name =>
      fun _code =>
        {
          name = _name,
          lang = 'python,
          code = _code,
        },

  with_schemas
    | doc "Set input and output schemas on a node"
    | not_exported
    = fun _in =>
      fun _out =>
        fun _node =>
          _node
          & {
            input_schema = _in,
            output_schema = _out,
          },

  with_constraints
    | doc "Set runtime constraints on a node"
    | not_exported
    = fun _constraints =>
      fun _node =>
        _node & { constraints = _constraints },

  with_env
    | doc "Set environment variables on a node"
    | not_exported
    = fun _env =>
      fun _node =>
        _node & { env = _env },

  sandboxed
    | doc "Apply strict sandbox constraints (no network, read-only fs, 64MB)"
    | not_exported
    = fun _node =>
      _node
      & {
        constraints = {
          network = { mode = 'deny },
          fs = { mode = 'ro },
          resources = { max_memory_mb = 64, max_cpu_seconds = 10, timeout_seconds = 30 },
        },
      },

  networked
    | doc "Allow network access"
    | not_exported
    = fun _node =>
      _node
      & {
        constraints = {
          network = { mode = 'full },
        },
      },
}
