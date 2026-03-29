#!/usr/bin/env bash
set -euo pipefail

# nix-tool-runner.sh — Execute a Nix package tool inside a sandbox
#
# Usage:
#   nix-tool-runner.sh <registry.json> <tool-name> [args...]
#
# The registry JSON is produced by:
#   nickel export --format json codemode-nix/examples/nix-registry.ncl > registry.json
#
# Environment:
#   NIX_TOOL_WORK_DIR     — working directory for IO tools (default: /tmp/nix-tool-work)
#   NIX_TOOL_PROFILE_DIR  — where to write sandbox profiles (default: /tmp/nix-tool-profiles)

REGISTRY="${1:?Usage: nix-tool-runner.sh <registry.json> <tool-name> [args...]}"
TOOL_NAME="${2:?Missing tool name}"
shift 2

WORK_DIR="${NIX_TOOL_WORK_DIR:-/tmp/nix-tool-work}"
PROFILE_DIR="${NIX_TOOL_PROFILE_DIR:-/tmp/nix-tool-profiles}"
mkdir -p "$WORK_DIR" "$PROFILE_DIR"

# Extract tool config from registry
TOOL_JSON=$(jq -r --arg name "$TOOL_NAME" '.[$name]' "$REGISTRY")
if [ "$TOOL_JSON" = "null" ]; then
  echo "error: unknown tool '$TOOL_NAME'" >&2
  echo "available tools: $(jq -r 'keys | join(", ")' "$REGISTRY")" >&2
  exit 1
fi

FLAKE_REF=$(echo "$TOOL_JSON" | jq -r '.flakeRef')
NETWORK_ENABLED=$(echo "$TOOL_JSON" | jq -r '.sandbox.network.enabled')
TIMEOUT=$(echo "$TOOL_JSON" | jq -r '.sandbox.timeout')

case "$(uname -s)" in
  Darwin)
    PROFILE="$PROFILE_DIR/${TOOL_NAME}.sb"

    # Build seatbelt profile
    ALLOWED_PATHS=$(echo "$TOOL_JSON" | jq -r '.sandbox.filesystem.allowed_paths[]')

    {
      echo "(version 1)"
      echo "(allow default)"

      if [ "$NETWORK_ENABLED" = "true" ]; then
        echo "(allow network-outbound)"
        echo "(allow network-inbound)"
      else
        echo "(deny network-outbound)"
        echo "(deny network-inbound)"
      fi

      while IFS= read -r path; do
        echo "(allow file-read-data file-write-data (subpath \"$path\"))"
      done <<< "$ALLOWED_PATHS"
    } > "$PROFILE"

    timeout "${TIMEOUT}s" sandbox-exec -f "$PROFILE" \
      nix run "$FLAKE_REF" -- "$@" 2>&1
    ;;

  Linux)
    if command -v nsjail >/dev/null 2>&1; then
      RLIMIT_AS=$(echo "$TOOL_JSON" | jq -r '.sandbox.resources.rlimit_as // 134217728')
      RLIMIT_CPU=$(echo "$TOOL_JSON" | jq -r '.sandbox.resources.rlimit_cpu // 30')

      nsjail \
        --mode ONCE \
        --time_limit "$TIMEOUT" \
        --rlimit_as "$((RLIMIT_AS / 1024 / 1024))" \
        --rlimit_cpu "$RLIMIT_CPU" \
        $( [ "$NETWORK_ENABLED" = "false" ] && printf '%s' "--disable_clone_newnet" ) \
        -- nix run "$FLAKE_REF" -- "$@" 2>&1
    else
      # Fallback: ulimit-based limits
      (
        RLIMIT_AS=$(echo "$TOOL_JSON" | jq -r '.sandbox.resources.rlimit_as // 134217728')
        ulimit -v "$((RLIMIT_AS / 1024))" 2>/dev/null || true
        ulimit -t "${TIMEOUT}" 2>/dev/null || true
        exec timeout "${TIMEOUT}s" nix run "$FLAKE_REF" -- "$@"
      ) 2>&1
    fi
    ;;

  *)
    echo "error: unsupported platform '$(uname -s)'" >&2
    exit 1
    ;;
esac
