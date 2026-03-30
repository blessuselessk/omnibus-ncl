# PROSE builder functions
#
# Convenience constructors for PROSE primitives.
# These produce plain records — apply contracts at the export boundary.
#
# Note: parameter names are prefixed to avoid Nickel's self-reference
# detection (field `x = x` triggers infinite recursion).
{
  agent
    | doc m%"
      Build an Agent from description and body.

      Example:
        agent "Backend API expert" "You are a backend engineer..."
    "%
    | not_exported
    = fun _desc =>
      fun _body =>
        {
          description = _desc,
          body = _body,
        },

  agent_with_tools
    | doc m%"
      Build an Agent with tools and optional handoffs.

      Example:
        agent_with_tools "API architect" ["codebase", "terminal"] ["reviewer.agent.md"] "You design APIs..."
    "%
    | not_exported
    = fun _desc =>
      fun _tools =>
        fun _handoffs =>
          fun _body =>
            {
              description = _desc,
              tools = _tools,
              handoffs = _handoffs,
              body = _body,
            },

  instruction
    | doc m%"
      Build an Instruction from apply_to glob, description, and body.

      Example:
        instruction "**/*.ts" "TypeScript style" "Use strict mode..."
    "%
    | not_exported
    = fun _apply_to =>
      fun _desc =>
        fun _body =>
          {
            apply_to = _apply_to,
            description = _desc,
            body = _body,
          },

  chatmode
    | doc m%"
      Build a Chatmode from description, tools list, and body.

      Example:
        chatmode "Security reviewer" ["codebase", "terminal"] "You are a security expert..."
    "%
    | not_exported
    = fun _desc =>
      fun _tools =>
        fun _body =>
          {
            description = _desc,
            tools = _tools,
            body = _body,
          },

  chatmode_with_model
    | doc m%"
      Build a Chatmode with an explicit model override.

      Example:
        chatmode_with_model "Deep analysis" ["codebase"] "Claude Sonnet 4" "You analyze..."
    "%
    | not_exported
    = fun _desc =>
      fun _tools =>
        fun _model =>
          fun _body =>
            {
              description = _desc,
              tools = _tools,
              model = _model,
              body = _body,
            },

  prompt
    | doc m%"
      Build a Prompt from description and body.

      Example:
        prompt "Review code" "Review the following code for..."
    "%
    | not_exported
    = fun _desc =>
      fun _body =>
        {
          description = _desc,
          body = _body,
        },

  prompt_with_mode
    | doc m%"
      Build a Prompt with execution mode, tools, and input parameters.

      Example:
        prompt_with_mode "Refactor" 'edit ["codebase"] ["file", "pattern"] "Refactor..."
    "%
    | not_exported
    = fun _desc =>
      fun _mode =>
        fun _tools =>
          fun _input =>
            fun _body =>
              {
                description = _desc,
                mode = _mode,
                tools = _tools,
                input = _input,
                body = _body,
              },

  spec
    | doc m%"
      Build a Spec from title and body.

      Example:
        spec "Auth System" "## Problem\n..."
    "%
    | not_exported
    = fun _title =>
      fun _body =>
        {
          title = _title,
          body = _body,
        },

  spec_with_category
    | doc m%"
      Build a Spec with category.

      Example:
        spec_with_category "Auth System" "feature" "## Problem\n..."
    "%
    | not_exported
    = fun _title =>
      fun _cat =>
        fun _body =>
          {
            title = _title,
            category = _cat,
            body = _body,
          },

  memory
    | doc m%"
      Build a Memory from title and body.

      Example:
        memory "Project conventions" "We use Prettier with..."
    "%
    | not_exported
    = fun _title =>
      fun _body =>
        {
          title = _title,
          body = _body,
        },

  context
    | doc m%"
      Build a Context from title and body.

      Example:
        context "API endpoints" "The API serves..."
    "%
    | not_exported
    = fun _title =>
      fun _body =>
        {
          title = _title,
          body = _body,
        },

  skill
    | doc m%"
      Build a Skill from name, description, references, and scripts.

      Example:
        skill "lint-fix" "Auto-fix linting issues" ["refs/eslint.md"] ["scripts/lint.sh"]
    "%
    | not_exported
    = fun _name =>
      fun _desc =>
        fun _refs =>
          fun _scripts =>
            {
              name = _name,
              description = _desc,
              references = _refs,
              scripts = _scripts,
            },
}
