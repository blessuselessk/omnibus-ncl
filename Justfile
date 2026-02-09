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
    @nickel export --format json sandbox/examples/data-processor.ncl | python3 -c "import sys,json;d=json.load(sys.stdin);print('skill_id:',d.get('skill_id'));print('resources:',d.get('resources'))"

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
    @echo "Examples:"
    @echo "  just test-data-processor # Test data-processor example"
    @echo "  just test-examples       # Test all examples"
    @echo "  just test                # Run pytest"
    @echo ""
