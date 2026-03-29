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
    @echo "Examples:"
    @echo "  just test-data-processor # Test data-processor example"
    @echo "  just test-examples       # Test all examples"
    @echo "  just test                # Run pytest"
    @echo ""
