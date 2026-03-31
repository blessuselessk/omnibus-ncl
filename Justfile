# Justfile for NCL Sandbox Testing
# https://github.com/casey/just

set dotenv-load := false
set shell := ["bash", "-uc"]
set positional-arguments := true

# ==============================================================================
# NCL Sandbox Commands
# ==============================================================================

default:
    @echo "NCL Sandbox Commands"
    @echo "===================="
    @just --list

# ==============================================================================
# Seatbelt (macOS Only)
# ==============================================================================

# Generate and run minimal seatbelt profile (macOS only)
sb-minimal profile="minimal" skill="test":
    @echo "=== Seatbelt Minimal Profile ==="
    @nickel export --format text sandbox/examples/seatbelt-{{profile}}.ncl > /tmp/sb_{{profile}}.sb
    @cat /tmp/sb_{{profile}}.sb
    @echo ""
    @echo "=== Testing: /bin/pwd ==="
    @sandbox-exec -f /tmp/sb_{{profile}}.sb /bin/pwd

# Generate and run standard seatbelt profile (macOS only)
sb-standard profile="standard" skill="test":
    @echo "=== Seatbelt Standard Profile ==="
    @nickel export --format text sandbox/examples/seatbelt-{{profile}}.ncl > /tmp/sb_{{profile}}.sb
    @cat /tmp/sb_{{profile}}.sb
    @echo ""
    @echo "=== Testing: /bin/pwd ==="
    @sandbox-exec -f /tmp/sb_{{profile}}.sb /bin/pwd
    @echo "=== Testing: /bin/ls /tmp ==="
    @sandbox-exec -f /tmp/sb_{{profile}}.sb /bin/ls /tmp

# Generate and run development seatbelt profile (macOS only)
sb-dev profile="development" skill="test":
    @echo "=== Seatbelt Development Profile ==="
    @nickel export --format text sandbox/examples/seatbelt-{{profile}}.ncl > /tmp/sb_{{profile}}.sb
    @cat /tmp/sb_{{profile}}.sb
    @echo ""
    @echo "=== Testing: /bin/bash -c ==="
    @sandbox-exec -f /tmp/sb_{{profile}}.sb /bin/bash -c "echo hello"

# Export seatbelt profile to custom path (macOS only)
sb-export profile="standard" output="/tmp/custom.sb":
    @echo "Exporting {{profile}} profile to {{output}}"
    @nickel export --format text sandbox/examples/seatbelt-{{profile}}.ncl > {{output}}
    @echo "Done: {{output}}"

# Run custom command in seatbelt sandbox (macOS only)
sb-run profile="minimal" *cmd:
    @nickel export --format text sandbox/examples/seatbelt-{{profile}}.ncl > /tmp/sb_{{profile}}.sb
    @sandbox-exec -f /tmp/sb_{{profile}}.sb {{cmd}}

# ==============================================================================
# NCL Validation (Cross-platform)
# ==============================================================================

# Validate NCL files in directory
validate directory=".":
    @echo "=== Validating NCL files in {{directory}} ==="
    @nickel export --format json {{directory}}/main.ncl 2>&1 | head -20

# Check syntax of all NCL files
fmt-check:
    @echo "=== Checking NCL format ==="
    @fd -e ncl -x sh -c 'nickel format --check "$1"' _ 2>&1 | grep -v "format error" || true

# Format all NCL files
fmt:
    @echo "=== Formatting NCL files ==="
    @fd -e ncl -x sh -c 'nickel format "$1" && echo "Formatted: $1"' _

# ==============================================================================
# Sandbox Examples (Cross-platform)
# ==============================================================================

# Test data-processor example
test-data-processor:
    @echo "=== Testing data-processor.ncl ==="
    @nickel export --format json sandbox/examples/data-processor.ncl
    @echo ""
    @echo "=== Structure Check ==="
    @nickel export --format json sandbox/examples/data-processor.ncl | python3 scripts/print_skill_summary.py

# Test web-scraper example
test-web-scraper:
    @echo "=== Testing web-scraper.ncl ==="
    @nickel export --format json sandbox/examples/web-scraper.ncl

# Test all sandbox examples
test-examples:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== Testing All Sandbox Examples ==="
    echo ""
    echo "1. data-processor.ncl"
    nickel export --format json sandbox/examples/data-processor.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "2. web-scraper.ncl"
    nickel export --format json sandbox/examples/web-scraper.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    if [ "$$(uname -s)" = "Darwin" ]; then
        echo "3. seatbelt-minimal.ncl"
        nickel export --format text sandbox/examples/seatbelt-minimal.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
        echo "4. seatbelt-standard.ncl"
        nickel export --format text sandbox/examples/seatbelt-standard.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
        echo "5. seatbelt-development.ncl"
        nickel export --format text sandbox/examples/seatbelt-development.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    else
        echo "3-5. seatbelt profiles (SKIPPED - not macOS)"
    fi
    echo "6. codemode/pm-tools-export.ncl"
    nickel export --format json codemode/examples/pm-tools-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "7. codemode/single-tool.ncl"
    nickel export --format json codemode/examples/single-tool.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "8. codemode-mcp/demo-tools-export.ncl"
    nickel export --format json codemode-mcp/examples/demo-tools-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "9. codemode-mcp/server-config.ncl"
    nickel export --format json codemode-mcp/examples/server-config.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "10. codemode-mcp-openapi/mcp-tools-export.ncl"
    nickel export --format json codemode-mcp-openapi/examples/mcp-tools-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "9. codemode-mcp-openapi/mcp-server.ncl"
    nickel export --format json codemode-mcp-openapi/examples/mcp-server.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "10. codemode-mcp-openapi/openapi-server.ncl"
    nickel export --format json codemode-mcp-openapi/examples/openapi-server.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "11. codemode-mcp-openapi/request-examples.ncl"
    nickel export --format json codemode-mcp-openapi/examples/request-examples.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "12. codemode-nix/nix-tools-export.ncl"
    nickel export --format json codemode-nix/examples/nix-tools-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "13. codemode-nix/nix-registry.ncl"
    nickel export --format json codemode-nix/examples/nix-registry.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "14. apm-ncl/manifest-export.ncl"
    nickel export --format json apm-ncl/examples/manifest-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "15. apm-ncl/simple-manifest.ncl"
    nickel export --format json apm-ncl/examples/simple-manifest.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "16. apm-ncl/lockfile-example.ncl"
    nickel export --format json apm-ncl/examples/lockfile-example.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "17. prose-ncl/workspace-export.ncl"
    nickel export --format json prose-ncl/examples/workspace-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "18. prose-ncl/single-skill.ncl"
    nickel export --format json prose-ncl/examples/single-skill.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "19. massless-driver/workflow-export.ncl"
    nickel export --format json massless-driver/examples/workflow-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "20. massless-driver/nix-workflow-export.ncl"
    nickel export --format json massless-driver/examples/nix-workflow-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "21. massless-driver/manifest-export.ncl"
    nickel export --format json massless-driver/examples/manifest-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "22. envelope-ncl/tool-in-sandbox.ncl"
    nickel export --format json envelope-ncl/examples/tool-in-sandbox.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "23. envelope-ncl/three-layer.ncl"
    nickel export --format json envelope-ncl/examples/three-layer.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "24. envelope-ncl/flatten-export.ncl"
    nickel export --format json envelope-ncl/examples/flatten-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "25. porkg-ncl/config-export.ncl"
    nickel export --format json porkg-ncl/examples/config-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "26. porkg-ncl/pipeline-export.ncl"
    nickel export --format json porkg-ncl/examples/pipeline-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "27. porkg-ncl/proto-export.ncl"
    nickel export --format json porkg-ncl/examples/proto-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "28. process-compose-ncl/standalone-export.ncl"
    nickel export --format json process-compose-ncl/examples/standalone-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "29. process-compose-ncl/envelope-bridge-export.ncl"
    nickel export --format json process-compose-ncl/examples/envelope-bridge-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"
    echo "30. process-compose-ncl/porkg-bridge-export.ncl"
    nickel export --format json process-compose-ncl/examples/porkg-bridge-export.ncl > /dev/null 2>&1 && echo "   OK" || echo "   FAILED"

# ==============================================================================
# Codemode
# ==============================================================================

# Export PM tools as JSON Schema (JsonSchemaToolDescriptors)
cm-export:
    @nickel export --format json codemode/examples/pm-tools-export.ncl

# Export single-tool example
cm-single:
    @nickel export --format json codemode/examples/single-tool.ncl

# Validate all codemode .ncl files export cleanly
cm-validate:
    @echo "=== Validating codemode ==="
    @nickel export --format json codemode/examples/pm-tools-export.ncl > /dev/null && echo "PM tools: OK"
    @nickel export --format json codemode/examples/single-tool.ncl > /dev/null && echo "Single tool: OK"

# Run codemode cross-repo tests (compares Nickel vs TS snapshots)
cm-test:
    @bash codemode/tests/validate.sh

# Update snapshot.json from current Nickel export
cm-snapshot:
    @nickel export --format json codemode/examples/pm-tools-export.ncl > codemode/tests/snapshot.json
    @echo "Snapshot updated: codemode/tests/snapshot.json"

# ==============================================================================
# Codemode MCP
# ==============================================================================

# Export MCP demo tools as JSON
cmcp-export:
    @nickel export --format json codemode-mcp/examples/demo-tools-export.ncl

# Export MCP server config
cmcp-server:
    @nickel export --format json codemode-mcp/examples/server-config.ncl

# Validate all codemode-mcp .ncl files
cmcp-validate:
    @echo "=== Validating codemode-mcp ==="
    @nickel export --format json codemode-mcp/examples/demo-tools-export.ncl > /dev/null && echo "Demo tools: OK"
    @nickel export --format json codemode-mcp/examples/server-config.ncl > /dev/null && echo "Server config: OK"

# Run codemode-mcp cross-repo tests
cmcp-test:
    @bash codemode-mcp/tests/validate.sh

# Update snapshot from current Nickel export
cmcp-snapshot:
    @nickel export --format json codemode-mcp/examples/demo-tools-export.ncl > codemode-mcp/tests/snapshot.json
    @echo "Snapshot updated: codemode-mcp/tests/snapshot.json"

# ==============================================================================
# Codemode MCP + OpenAPI
# ==============================================================================

# Export MCP demo tools as JSON
cmo-export:
    @nickel export --format json codemode-mcp-openapi/examples/mcp-tools-export.ncl

# Export MCP server config
cmo-server:
    @nickel export --format json codemode-mcp-openapi/examples/mcp-server.ncl

# Export OpenAPI server config
cmo-openapi:
    @nickel export --format json codemode-mcp-openapi/examples/openapi-server.ncl

# Export request examples
cmo-requests:
    @nickel export --format json codemode-mcp-openapi/examples/request-examples.ncl

# Validate all codemode-mcp-openapi .ncl files
cmo-validate:
    @echo "=== Validating codemode-mcp-openapi ==="
    @nickel export --format json codemode-mcp-openapi/examples/mcp-tools-export.ncl > /dev/null && echo "MCP tools: OK"
    @nickel export --format json codemode-mcp-openapi/examples/mcp-server.ncl > /dev/null && echo "MCP server: OK"
    @nickel export --format json codemode-mcp-openapi/examples/openapi-server.ncl > /dev/null && echo "OpenAPI server: OK"
    @nickel export --format json codemode-mcp-openapi/examples/request-examples.ncl > /dev/null && echo "Request examples: OK"

# Run codemode-mcp-openapi cross-repo tests
cmo-test:
    @bash codemode-mcp-openapi/tests/validate.sh

# Update snapshot from current Nickel export
cmo-snapshot:
    @nickel export --format json codemode-mcp-openapi/examples/mcp-tools-export.ncl > codemode-mcp-openapi/tests/snapshot.json
    @echo "Snapshot updated: codemode-mcp-openapi/tests/snapshot.json"

# ==============================================================================
# Codemode Nix
# ==============================================================================

# Export Nix tools as LLM-facing JSON Schema
cnix-export:
    @nickel export --format json codemode-nix/examples/nix-tools-export.ncl

# Export full Nix tool registry with sandbox config
cnix-registry:
    @nickel export --format json codemode-nix/examples/nix-registry.ncl

# Validate all codemode-nix .ncl files
cnix-validate:
    @echo "=== Validating codemode-nix ==="
    @nickel export --format json codemode-nix/examples/nix-tools-export.ncl > /dev/null && echo "Nix tools: OK"
    @nickel export --format json codemode-nix/examples/nix-registry.ncl > /dev/null && echo "Registry: OK"
    @nickel export --format json codemode-nix/examples/provider-config.ncl > /dev/null && echo "Provider config: OK"

# Run codemode-nix tests
cnix-test:
    @bash codemode-nix/tests/validate.sh

# Update snapshots from current Nickel export
cnix-snapshot:
    @nickel export --format json codemode-nix/examples/nix-tools-export.ncl | jq -S . > codemode-nix/tests/snapshot.json
    @nickel export --format json codemode-nix/examples/nix-registry.ncl | jq -S . > codemode-nix/tests/snapshot-registry.json
    @echo "Snapshots updated"

# Run a Nix tool inside sandbox
cnix-run tool *args:
    @nickel export --format json codemode-nix/examples/nix-registry.ncl > /tmp/nix-tool-registry.json
    @bash codemode-nix/scripts/nix-tool-runner.sh /tmp/nix-tool-registry.json {{tool}} {{args}}

# ==============================================================================
# APM (Agent Package Manager)
# ==============================================================================

# Export APM manifest as JSON
apm-export:
    @nickel export --format json apm-ncl/examples/manifest-export.ncl

# Export simple APM manifest
apm-simple:
    @nickel export --format json apm-ncl/examples/simple-manifest.ncl

# Export APM lockfile as JSON
apm-lockfile:
    @nickel export --format json apm-ncl/examples/lockfile-example.ncl

# Validate all apm-ncl .ncl files
apm-validate:
    @echo "=== Validating apm-ncl ==="
    @nickel export --format json apm-ncl/examples/manifest-export.ncl > /dev/null && echo "Full manifest: OK"
    @nickel export --format json apm-ncl/examples/simple-manifest.ncl > /dev/null && echo "Simple manifest: OK"
    @nickel export --format json apm-ncl/examples/lockfile-example.ncl > /dev/null && echo "Lockfile: OK"

# Run apm-ncl tests
apm-test:
    @bash apm-ncl/tests/validate.sh

# Update snapshot from current Nickel export
apm-snapshot:
    @nickel export --format json apm-ncl/examples/manifest-export.ncl | jq -S . > apm-ncl/tests/snapshot.json
    @echo "Snapshot updated: apm-ncl/tests/snapshot.json"

# ==============================================================================
# PROSE (AI-Native Primitives)
# ==============================================================================

# Export PROSE workspace as JSON
prose-export:
    @nickel export --format json prose-ncl/examples/workspace-export.ncl

# Export single skill example
prose-skill:
    @nickel export --format json prose-ncl/examples/single-skill.ncl

# Export composability graph as JSON
prose-graph:
    @nickel export --format json prose-ncl/examples/graph-export.ncl

# Validate all prose-ncl .ncl files
prose-validate:
    @echo "=== Validating prose-ncl ==="
    @nickel export --format json prose-ncl/examples/workspace-export.ncl > /dev/null && echo "Workspace: OK"
    @nickel export --format json prose-ncl/examples/single-skill.ncl > /dev/null && echo "Single skill: OK"
    @nickel export --format json prose-ncl/examples/graph-export.ncl > /dev/null && echo "Graph: OK"

# Run prose-ncl tests
prose-test:
    @bash prose-ncl/tests/validate.sh

# Update snapshot from current Nickel export
prose-snapshot:
    @nickel export --format json prose-ncl/examples/workspace-export.ncl | jq -S . > prose-ncl/tests/snapshot.json
    @echo "Snapshot updated: prose-ncl/tests/snapshot.json"

# ==============================================================================
# Massless Driver (GitHub Actions as Compute)
# ==============================================================================

# Export workflow as GitHub Actions JSON
md-export:
    @nickel export --format json massless-driver/examples/workflow-export.ncl

# Export nix workflow variant
md-nix:
    @nickel export --format json massless-driver/examples/nix-workflow-export.ncl

# Export job manifest
md-manifest:
    @nickel export --format json massless-driver/examples/manifest-export.ncl

# Validate all massless-driver .ncl files
md-validate:
    @echo "=== Validating massless-driver ==="
    @nickel export --format json massless-driver/examples/workflow-export.ncl > /dev/null && echo "Workflow: OK"
    @nickel export --format json massless-driver/examples/nix-workflow-export.ncl > /dev/null && echo "Nix workflow: OK"
    @nickel export --format json massless-driver/examples/manifest-export.ncl > /dev/null && echo "Manifest: OK"

# Run massless-driver tests
md-test:
    @bash massless-driver/tests/validate.sh

# Update snapshots from current Nickel export
md-snapshot:
    @nickel export --format json massless-driver/examples/workflow-export.ncl | jq -S . > massless-driver/tests/snapshot-workflow.json
    @nickel export --format json massless-driver/examples/manifest-export.ncl | jq -S . > massless-driver/tests/snapshot-manifest.json
    @echo "Snapshots updated"

# ==============================================================================
# Process Compose
# ==============================================================================

# Export standalone process-compose config
pc-export:
    @nickel export --format json process-compose-ncl/examples/standalone-export.ncl

# Export envelope bridge (nested envelopes → process-compose)
pc-envelope:
    @nickel export --format json process-compose-ncl/examples/envelope-bridge-export.ncl

# Export porkg bridge (porkg config → process-compose)
pc-porkg:
    @nickel export --format json process-compose-ncl/examples/porkg-bridge-export.ncl

# Validate all process-compose-ncl .ncl files
pc-validate:
    @echo "=== Validating process-compose-ncl ==="
    @nickel export --format json process-compose-ncl/examples/standalone-export.ncl > /dev/null && echo "Standalone: OK"
    @nickel export --format json process-compose-ncl/examples/envelope-bridge-export.ncl > /dev/null && echo "Envelope bridge: OK"
    @nickel export --format json process-compose-ncl/examples/porkg-bridge-export.ncl > /dev/null && echo "porkg bridge: OK"

# Run process-compose-ncl tests
pc-test:
    @bash process-compose-ncl/tests/validate.sh

# Update snapshot
pc-snapshot:
    @nickel export --format json process-compose-ncl/examples/standalone-export.ncl | jq -S . > process-compose-ncl/tests/snapshot.json
    @echo "Snapshot updated"

# ==============================================================================
# porkg (Process Hierarchy)
# ==============================================================================

# Export porkg nix pipeline config
porkg-export:
    @nickel export --format json porkg-ncl/examples/config-export.ncl

# Export locked-down pipeline
porkg-locked:
    @nickel export --format json porkg-ncl/examples/pipeline-export.ncl

# Export protocol tag map
porkg-proto:
    @nickel export --format json porkg-ncl/examples/proto-export.ncl

# Validate all porkg-ncl .ncl files
porkg-validate:
    @echo "=== Validating porkg-ncl ==="
    @nickel export --format json porkg-ncl/examples/config-export.ncl > /dev/null && echo "Config: OK"
    @nickel export --format json porkg-ncl/examples/pipeline-export.ncl > /dev/null && echo "Pipeline: OK"
    @nickel export --format json porkg-ncl/examples/proto-export.ncl > /dev/null && echo "Proto: OK"

# Run porkg-ncl tests
porkg-test:
    @bash porkg-ncl/tests/validate.sh

# Update snapshot
porkg-snapshot:
    @nickel export --format json porkg-ncl/examples/config-export.ncl | jq -S . > porkg-ncl/tests/snapshot.json
    @echo "Snapshot updated"

# ==============================================================================
# Envelope (Composable Runtime Envelopes)
# ==============================================================================

# Export tool-in-sandbox nesting
env-tool:
    @nickel export --format json envelope-ncl/examples/tool-in-sandbox.ncl

# Export sandbox-in-workflow nesting
env-sandbox:
    @nickel export --format json envelope-ncl/examples/sandbox-in-workflow.ncl

# Export three-layer nesting (tool → sandbox → workflow)
env-three:
    @nickel export --format json envelope-ncl/examples/three-layer.ncl

# Flatten nested envelope to array
env-flatten:
    @nickel export --format json envelope-ncl/examples/flatten-export.ncl

# Validate all envelope-ncl .ncl files
env-validate:
    @echo "=== Validating envelope-ncl ==="
    @nickel export --format json envelope-ncl/examples/tool-in-sandbox.ncl > /dev/null && echo "Tool-in-sandbox: OK"
    @nickel export --format json envelope-ncl/examples/sandbox-in-workflow.ncl > /dev/null && echo "Sandbox-in-workflow: OK"
    @nickel export --format json envelope-ncl/examples/three-layer.ncl > /dev/null && echo "Three-layer: OK"
    @nickel export --format json envelope-ncl/examples/flatten-export.ncl > /dev/null && echo "Flatten: OK"

# Run envelope-ncl tests
env-test:
    @bash envelope-ncl/tests/validate.sh

# Update snapshot from current Nickel export
env-snapshot:
    @nickel export --format json envelope-ncl/examples/three-layer.ncl | jq -S . > envelope-ncl/tests/snapshot-three-layer.json
    @echo "Snapshots updated"

# ==============================================================================
# Pytest
# ==============================================================================

# Run sandbox pytest tests
test:
    @echo "=== Running Sandbox Tests ==="
    @cd $(dirname $(dirname $(pwd))) && uv run pytest packages/sandbox/examples/tests/ -v

# ==============================================================================
# Help
# ==============================================================================

help:
    @echo ""
    @echo "NCL Sandbox Just Commands"
    @echo ""
    @echo "Seatbelt (macOS Only):"
    @echo "  just sb-minimal          # Generate and test minimal profile"
    @echo "  just sb-standard         # Generate and test standard profile"
    @echo "  just sb-dev              # Generate and test development profile"
    @echo "  just sb-export [profile]  # Export profile to file"
    @echo "  just sb-run [profile] [cmd]  # Run command in sandbox"
    @echo ""
    @echo "NCL Validation:"
    @echo "  just validate [dir]      # Validate NCL files"
    @echo "  just fmt-check           # Check NCL format"
    @echo "  just fmt                 # Format NCL files"
    @echo ""
    @echo "Codemode:"
    @echo "  just cm-export           # Export PM tools as JSON Schema"
    @echo "  just cm-single           # Export single-tool example"
    @echo "  just cm-validate         # Validate codemode NCL files"
    @echo "  just cm-test             # Run cross-repo tests"
    @echo "  just cm-snapshot         # Update snapshot from Nickel export"
    @echo ""
    @echo "Codemode MCP:"
    @echo "  just cmcp-export         # Export MCP demo tools"
    @echo "  just cmcp-server         # Export MCP server config"
    @echo "  just cmcp-validate       # Validate codemode-mcp NCL files"
    @echo "  just cmcp-test           # Run cross-repo tests"
    @echo ""
    @echo "Codemode MCP + OpenAPI:"
    @echo "  just cmo-export          # Export MCP demo tools"
    @echo "  just cmo-server          # Export MCP server config"
    @echo "  just cmo-openapi         # Export OpenAPI server config"
    @echo "  just cmo-requests        # Export request examples"
    @echo "  just cmo-validate        # Validate all cmo NCL files"
    @echo "  just cmo-test            # Run cross-repo tests"
    @echo ""
    @echo "Codemode Nix:"
    @echo "  just cnix-export         # Export Nix tools as LLM-facing JSON"
    @echo "  just cnix-registry       # Export full registry with sandbox config"
    @echo "  just cnix-validate       # Validate codemode-nix NCL files"
    @echo "  just cnix-test           # Run tests"
    @echo "  just cnix-snapshot       # Update test snapshots"
    @echo "  just cnix-run <tool>     # Run a Nix tool inside sandbox"
    @echo ""
    @echo "APM (Agent Package Manager):"
    @echo "  just apm-export          # Export full manifest as JSON"
    @echo "  just apm-simple          # Export simple manifest"
    @echo "  just apm-lockfile        # Export lockfile as JSON"
    @echo "  just apm-validate        # Validate apm-ncl NCL files"
    @echo "  just apm-test            # Run tests"
    @echo "  just apm-snapshot        # Update test snapshot"
    @echo ""
    @echo "PROSE (AI-Native Primitives):"
    @echo "  just prose-export        # Export workspace as JSON"
    @echo "  just prose-skill         # Export single skill example"
    @echo "  just prose-graph         # Export composability graph"
    @echo "  just prose-validate      # Validate prose-ncl NCL files"
    @echo "  just prose-test          # Run tests"
    @echo "  just prose-snapshot      # Update test snapshot"
    @echo ""
    @echo "Process Compose:"
    @echo "  just pc-export           # Export standalone config"
    @echo "  just pc-envelope         # Export envelope bridge"
    @echo "  just pc-porkg            # Export porkg bridge"
    @echo "  just pc-validate         # Validate process-compose-ncl NCL files"
    @echo "  just pc-test             # Run tests"
    @echo "  just pc-snapshot         # Update test snapshot"
    @echo ""
    @echo "porkg (Process Hierarchy):"
    @echo "  just porkg-export        # Export nix pipeline config"
    @echo "  just porkg-locked        # Export locked-down pipeline"
    @echo "  just porkg-proto         # Export protocol tag map"
    @echo "  just porkg-validate      # Validate porkg-ncl NCL files"
    @echo "  just porkg-test          # Run tests"
    @echo "  just porkg-snapshot      # Update test snapshot"
    @echo ""
    @echo "Envelope (Composable Runtime Envelopes):"
    @echo "  just env-tool            # Export tool-in-sandbox nesting"
    @echo "  just env-sandbox         # Export sandbox-in-workflow nesting"
    @echo "  just env-three           # Export three-layer nesting"
    @echo "  just env-flatten         # Flatten nested envelope to array"
    @echo "  just env-validate        # Validate envelope-ncl NCL files"
    @echo "  just env-test            # Run tests"
    @echo "  just env-snapshot        # Update test snapshots"
    @echo ""
    @echo "Massless Driver (GitHub Actions as Compute):"
    @echo "  just md-export           # Export workflow as JSON"
    @echo "  just md-nix              # Export nix workflow variant"
    @echo "  just md-manifest         # Export job manifest"
    @echo "  just md-validate         # Validate massless-driver NCL files"
    @echo "  just md-test             # Run tests"
    @echo "  just md-snapshot         # Update test snapshots"
    @echo ""
    @echo "Examples:"
    @echo "  just test-data-processor # Test data-processor example"
    @echo "  just test-examples       # Test all examples"
    @echo "  just test                # Run pytest"
    @echo ""
