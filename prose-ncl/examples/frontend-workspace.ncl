# Frontend workspace — a realistic PROSE workspace for a React/TypeScript project
#
# Demonstrates all primitive types working together.
# See lib/graph.ncl for the composability rules between these primitives.
let B = import "../lib/builders.ncl" in

{
  root_instructions = ".github/copilot-instructions.md",

  agents = [
    B.agent_with_tools
      "Frontend architect with security review handoff"
      ["codebase", "terminal", "search"]
      ["security-reviewer.agent.md"]
      m%"
        You are a senior frontend architect for a React/TypeScript application.
        You design component hierarchies, manage state architecture, and review
        implementation quality. When you encounter security concerns, hand off
        to the security reviewer agent.
      "%,
    B.agent
      "Documentation writer"
      m%"
        You maintain project documentation. After significant changes,
        update relevant .memory.md files with lessons learned and
        .context.md files with architectural changes.
      "%,
  ],

  instructions = [
    B.instruction
      "**/*.{ts,tsx}"
      "TypeScript strict mode conventions"
      m%"
        - Use `strict: true` in tsconfig
        - Prefer `interface` over `type` for object shapes
        - No `any` — use `unknown` and narrow with type guards
        - All exported functions must have explicit return types
      "%,
    B.instruction
      "**/*.{css,scss}"
      "CSS architecture rules"
      m%"
        - Use CSS modules for component styles
        - No inline styles except for dynamic values
        - Follow BEM naming in global stylesheets
        - Design tokens live in `src/styles/tokens.css`
      "%,
    B.instruction
      "src/components/**/*.tsx"
      "React component patterns"
      m%"
        - Functional components only
        - Props interface named `{ComponentName}Props`
        - Co-locate tests: `Component.test.tsx` next to `Component.tsx`
        - Extract hooks into `use{Name}.ts` when logic exceeds 10 lines
      "%,
  ],

  chatmodes = [
    B.chatmode_with_model
      "Security-focused code review"
      ["codebase", "terminal", "fetch"]
      "Claude Sonnet 4"
      m%"
        You are a security engineer reviewing a frontend application.
        Focus on:
        - XSS vectors in JSX (dangerouslySetInnerHTML, unsanitized user input)
        - Secrets or tokens in client-side code
        - CORS misconfigurations in API calls
        - Dependency vulnerabilities (check package.json)
        Always suggest the fix, not just the problem.
      "%,
    B.chatmode
      "Accessibility auditor"
      ["codebase", "fetch"]
      m%"
        You audit React components for WCAG 2.1 AA compliance.
        Check for:
        - Missing aria labels and roles
        - Keyboard navigation support
        - Color contrast issues
        - Screen reader compatibility
        Provide specific code fixes with before/after examples.
      "%,
  ],

  prompts = [
    B.prompt_with_mode
      "Review a pull request for code quality and conventions"
      'agent
      ["codebase", "terminal"]
      ["branch"]
      m%"
        Review the changes on branch `${input:branch}` against main.

        Check for:
        1. TypeScript strict mode violations
        2. Missing or inadequate tests
        3. Component patterns (see .instructions.md)
        4. Performance anti-patterns (unnecessary re-renders, missing memoization)
        5. Accessibility regressions

        Provide a structured review with severity levels: critical, warning, suggestion.
      "%,
    B.prompt_with_mode
      "Generate a new React component with tests and stories"
      'edit
      ["codebase"]
      ["name", "directory"]
      m%"
        Create a new React component `${input:name}` in `${input:directory}/`:

        Files to create:
        - `${input:name}.tsx` — component implementation
        - `${input:name}.test.tsx` — unit tests with React Testing Library
        - `${input:name}.module.css` — CSS module styles
        - `index.ts` — barrel export

        Follow the project's component conventions from .instructions.md.
      "%,
    B.prompt
      "Explain the architecture of a directory"
      m%"
        Analyze the current project structure and explain:
        - Key modules and their responsibilities
        - Data flow between components
        - External dependencies and integration points
        - Areas of technical debt or complexity

        Keep it concise — aim for a 2-minute read.
      "%,
  ],

  specs = [
    B.spec_with_category
      "Authentication Flow"
      "feature"
      m%"
        ## Problem
        Users need secure authentication with OAuth2 providers (Google, GitHub)
        and optional email/password fallback.

        ## Requirements
        - OAuth2 PKCE flow for SPA security
        - JWT access tokens with 15-minute expiry
        - Refresh token rotation
        - Session persistence across tabs via BroadcastChannel

        ## API Contract
        - `POST /auth/login` — initiate login flow
        - `POST /auth/callback` — exchange code for tokens
        - `POST /auth/refresh` — rotate refresh token
        - `POST /auth/logout` — revoke session

        ## Validation Criteria
        - [ ] OAuth flow completes in under 3 seconds
        - [ ] Tokens never appear in URL or localStorage
        - [ ] Refresh rotation invalidates previous tokens
        - [ ] Concurrent tab sessions stay synchronized
      "%,
  ],

  memories = [
    B.memory
      "Build system quirks"
      m%"
        - Vite HMR breaks with circular imports in `src/utils/` — restart dev server
        - CSS modules require `.module.css` suffix exactly — `.module.scss` works too
        - The `@/` path alias maps to `src/` (configured in tsconfig + vite.config)
        - Playwright tests need `just e2e-setup` before first run on a new machine
      "%,
    B.memory
      "Team conventions learned"
      m%"
        - PRs require at least one approval from `@frontend-team`
        - Feature branches: `feat/TICKET-123-short-description`
        - Commits follow Conventional Commits (enforced by commitlint)
        - No direct pushes to main — CI blocks force-push
      "%,
  ],

  contexts = [
    B.context
      "API documentation"
      m%"
        The backend API runs at `http://localhost:3001` in development.

        Key endpoints:
        - `/api/v1/users` — user CRUD
        - `/api/v1/projects` — project management
        - `/api/v1/projects/:id/tasks` — task management within projects

        Auth: Bearer token in Authorization header.
        Rate limits: 100 req/min per user, 1000 req/min per IP.
        All responses follow `{ data, error, meta }` envelope.
      "%,
    B.context
      "Infrastructure overview"
      m%"
        - Frontend: Vite + React 19, deployed on Cloudflare Pages
        - Backend: Hono on Cloudflare Workers
        - Database: Turso (libSQL) with Drizzle ORM
        - Auth: custom OAuth2 implementation (see specs/auth-flow.spec.md)
        - CI: GitHub Actions, runs on every PR
        - Monitoring: Sentry for errors, Axiom for logs
      "%,
  ],

  skills = [
    B.skill
      "lint-fix"
      "Auto-fix linting and formatting issues across the codebase"
      ["references/eslint-config.md", "references/prettier-config.md"]
      ["scripts/lint-fix.sh"],
    B.skill
      "db-migrate"
      "Generate and run database migrations with Drizzle"
      ["references/drizzle-schema.md"]
      ["scripts/migrate-generate.sh", "scripts/migrate-run.sh"],
  ],

  # Explicit wiring — the DAG between primitives in this workspace.
  # Every populated type must appear here; orphans fail WiredWorkspace.
  compositions = [
    # agents hand off to each other
    { from = 'agent, to = 'agent, direction = 'invoke, verb = "hands-off-to" },
    # agents auto-load matching instructions
    { from = 'agent, to = 'instruction, direction = 'auto_load, verb = "auto-loads" },
    # agents read context and memory
    { from = 'agent, to = 'context, direction = 'reference, verb = "references" },
    { from = 'agent, to = 'memory, direction = 'reference, verb = "reads" },
    # agents update memory after outcomes
    { from = 'agent, to = 'memory, direction = 'produce, verb = "updates" },
    # agents auto-discover skills
    { from = 'agent, to = 'skill, direction = 'auto_load, verb = "auto-discovers" },
    # prompts activate agents
    { from = 'prompt, to = 'agent, direction = 'invoke, verb = "activates" },
    # prompts consume and produce specs
    { from = 'prompt, to = 'spec, direction = 'reference, verb = "consumes" },
    { from = 'prompt, to = 'spec, direction = 'produce, verb = "produces" },
    # prompts reference context
    { from = 'prompt, to = 'context, direction = 'reference, verb = "references" },
  ],
}
