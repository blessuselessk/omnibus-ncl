# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

omnibus-ncl is a comprehensive collection of **Nickel** (`.ncl`) configurations covering:

- **Sandbox security** — process isolation profiles for macOS Seatbelt and Linux nsjail (plus experimental Hyperlight)
- **AWS Infrastructure-as-Code** — VPC, EC2, S3, IAM via Terraform+Nickel (`tf-ncl`)
- **GitHub Actions** — CI/CD workflows and Dependabot config expressed in Nickel
- **AI assistant skills** — structured skill definitions for seatbelt, nsjail, and tf-ncl code generation
- **Codemode tool definitions** — Nickel contracts and builders for `@cloudflare/codemode` JsonSchemaToolDescriptors

## Commands

All task automation uses **Just** (Justfile at repo root).

```bash
just                        # List all commands
just fmt                    # Format all .ncl files (uses fd + nickel format)
just fmt-check              # Check formatting without modifying
just validate [dir]         # Export dir/main.ncl as JSON to validate
just test-examples          # Validate all sandbox examples (seatbelt profiles macOS-only)
just test-data-processor    # Validate data-processor example
just test-web-scraper       # Validate web-scraper example
```

**Seatbelt sandbox commands (macOS only):**
```bash
just sb-minimal             # Generate + run minimal seatbelt profile
just sb-standard            # Generate + run standard profile
just sb-dev                 # Generate + run development profile
just sb-export [profile] [output]  # Export profile to file
just sb-run [profile] [cmd]        # Run command inside sandbox
```

**Direct Nickel usage:**
```bash
nickel export --format json path/to/file.ncl        # Export as JSON
nickel export --format text path/to/file.ncl         # Export as text (seatbelt profiles)
nickel format file.ncl                                # Format single file
nickel format --check file.ncl                        # Check single file
```

## Architecture

### Sandbox (`sandbox/`)

The core domain. Three layers:

1. **`lib/`** — shared primitives (mounts, network policies, seccomp filters, resource limits, type definitions). `lib/main.ncl` re-exports everything.
2. **`seatbelt/interface.ncl`** — builder pattern: `Sandbox.build { config } |> Sandbox.to_profile` produces macOS sandbox-exec profile text.
3. **`backends/`**, **`nsjail/`**, **`profiles/`** — backend-specific configs and reusable profile presets.

`sandbox/examples/` contains concrete configurations (seatbelt-minimal, seatbelt-standard, seatbelt-development, data-processor, web-scraper, python-script-runner).

`sandbox/skill/main.ncl` defines execution modes and resource limits for skill-based sandbox invocations.

### AWS (`aws/`)

Terraform infrastructure defined in Nickel using `tf-ncl`. `aws/modules/` has VPC, EC2, S3, provider, and availability zone modules. `aws/flake.nix` provides a Nix dev shell with tf-ncl tooling.

### GitHub Actions (`github/`)

CI/CD as Nickel. `github/nix/ci.ncl` defines the CI workflow (Ubuntu + macOS runners, `nix flake check`). `github/github-workflow.schema.ncl` is an auto-generated schema (~130K lines) from GitHub's workflow JSON schema — don't edit it by hand.

### Skills (`skills/`)

Structured skill packages for AI code generation, each with `SKILL.md` metadata, `commands/`, `references/`, and `scripts/`. Three skills: seatbelt, nsjail, tf-ncl.

### Codemode (`codemode/`)

Nickel contracts and builders that model `@cloudflare/codemode`'s `JsonSchemaToolDescriptors` surface. `lib/` has contracts (`schema.ncl`, `tool.ncl`) and builder functions (`builders.ncl`). `examples/pm-tools.ncl` replicates the 10 PM tools from the Cloudflare Agents codemode example. Export as JSON to feed directly into `generateTypesFromJsonSchema()`.

```bash
just cm-export              # Export PM tools as JSON Schema
just cm-validate            # Validate all codemode NCL files
just cm-test                # Cross-repo tests (Nickel vs TS snapshots)
just cm-snapshot            # Update snapshot from Nickel export
```

Testing compares Nickel exports against committed snapshots. When the agents repo (`../agents`) has `node_modules` installed, `cm-test` also extracts Zod→JSON Schema from the TS tools and compares.

### Codemode MCP (`codemode-mcp/`)

Nickel contracts for the `codeMcpServer()` pattern — wrapping an MCP server's tools with a single `code` tool for LLM code execution. Models `McpToolDescriptor`, `McpToolSet`, `McpServerConfig`, and `CodeMcpServerConfig`. Includes the 3 demo tools (add, greet, list_items) from `examples/codemode-mcp`.

```bash
just cmcp-export            # Export demo tools as JSON
just cmcp-server            # Export server config
just cmcp-validate          # Validate all codemode-mcp NCL files
just cmcp-test              # Cross-repo tests
```

### Codemode MCP + OpenAPI (`codemode-mcp-openapi/`)

Nickel contracts for the two MCP transformation patterns from `@cloudflare/codemode/mcp`: `codeMcpServer()` (wrap MCP tools with a code tool) and `openApiMcpServer()` (wrap OpenAPI specs as search+execute). Models MCP tool registration, server config, OpenAPI server config, and `RequestOptions` for sandbox API calls.

```bash
just cmo-export             # Export MCP demo tools as JSON
just cmo-server             # Export MCP server config
just cmo-openapi            # Export OpenAPI server config
just cmo-requests           # Export request examples
just cmo-validate           # Validate all cmo NCL files
just cmo-test               # Cross-repo tests
```

### Process Compose (`process-compose-ncl/`)

Nickel contracts for [Process Compose](https://github.com/F1bonacc1/process-compose) — docker-compose for bare processes. Models the full `process-compose.yaml` surface: processes, dependencies, health probes, restart policies, namespaces, and scheduling. Includes bridge adapters from `envelope-ncl` and `porkg-ncl` — nested envelopes become Process Compose processes with dependency ordering, porkg worker/job hierarchies become daemon + dependent processes.

```bash
just pc-export              # Export standalone config as JSON
just pc-envelope            # Export envelope bridge
just pc-porkg               # Export porkg bridge
just pc-validate            # Validate all process-compose-ncl NCL files
just pc-test                # Run tests
just pc-snapshot            # Update test snapshot
```

### porkg (`porkg-ncl/`)

Nickel contracts for [porkg](https://github.com/porkg/porkg)'s process hierarchy — a Nix-like package manager with parent → worker → job architecture. Models Linux namespace isolation (PID, mount, user, net, IPC, UTS, cgroup), MessagePack IPC protocol (5-byte header + msgpack body), privilege escalation rules, worker configuration, and job specifications.

```bash
just porkg-export           # Export nix pipeline config as JSON
just porkg-locked           # Export locked-down pipeline
just porkg-proto            # Export protocol tag map
just porkg-validate         # Validate all porkg-ncl NCL files
just porkg-test             # Run tests
just porkg-snapshot         # Update test snapshot
```

### Envelope (`envelope-ncl/`)

Composable, nestable runtime envelopes — a shared composition layer for all omnibus-ncl subprojects. Every runtime boundary (sandbox, workflow, MCP server, tool) can be expressed as an Envelope and nested with monotonic constraint restriction (inner envelopes can never exceed outer envelope permissions).

Adapters lift existing configs (`from_sandbox`, `from_workflow`, `from_tool`, `from_nix_tool`, `from_mcp_server`) into the common Envelope shape. The `nest` function composes envelopes, clamping inner constraints. The `flatten` function exports nested envelopes as a flat array of layers.

```bash
just env-tool               # Export tool-in-sandbox nesting
just env-three              # Export three-layer nesting
just env-flatten            # Flatten to array of layers
just env-validate           # Validate all envelope-ncl NCL files
just env-test               # Run tests
just env-snapshot           # Update test snapshots
```

### Massless Driver (`massless-driver/`)

Nickel configuration surface for massless-driver (actions-batch) — turns GitHub Actions into a compute platform. Models jobs, workflows, runners, secrets, artifacts, Tailscale mesh, Nix flake configs, and platform targets. One composable `to_workflow` builder replaces the Go project's two duplicate text/templates.

```bash
just md-export              # Export workflow as GitHub Actions JSON
just md-nix                 # Export nix workflow variant
just md-manifest            # Export job manifest
just md-validate            # Validate all massless-driver NCL files
just md-test                # Run tests
just md-snapshot            # Update test snapshots
```

## Nickel Conventions

The repo root has authoritative Nickel style guides — read these before writing .ncl code:

- `nickel-best-practices.md` — code style, common pitfalls
- `nickel-interface-style.md` — user interface design patterns
- `nickel-modules.md` — module system architecture
- `nickel-type-validation-guide.md` — contracts and type validation
- `nickel-language-handbook-llm.md` — language basics (LLM-optimized)

Key patterns used throughout:
- **Contracts (`|`) over bare types (`:`)** for domain validation
- **Enum tags** (`'deny`, `'seatbelt`) instead of strings for modes/variants
- **Record merge (`&`)** for composing configs — Nickel is lazy, merging is the primary composition mechanism
- **Schema-config separation** — interfaces define contracts, configs provide values
- **Clean export pattern** — separate serializable data from helper functions

## Dependencies

Managed through Nix flakes. No npm/cargo/pip — all tooling comes from Nix.

Required tools: `nickel`, `just`, `fd` (for fmt commands). Use `nix run nixpkgs#<tool>` if not installed.
