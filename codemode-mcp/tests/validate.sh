#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for codemode-mcp Nickel definitions
#
# Run from omnibus-ncl root: bash codemode-mcp/tests/validate.sh

AGENTS_DIR="${AGENTS_DIR:-}"
NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== codemode-mcp validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in demo-tools-export server-config; do
  if nickel export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Structure validation ---
echo "Step 2: Structure validation"

TOOL_COUNT=$(jq 'keys | length' /tmp/ncl-demo-tools-export.json 2>/dev/null || echo 0)
if [ "$TOOL_COUNT" -eq 3 ]; then
  pass "Demo tool count is 3"
else
  fail "Demo tool count is $TOOL_COUNT (expected 3)"
fi

ALL_HAVE_SCHEMA=$(jq '[.[] | has("description") and has("inputSchema")] | all' /tmp/ncl-demo-tools-export.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_SCHEMA" = "true" ]; then
  pass "All tools have description + inputSchema"
else
  fail "Some tools missing description or inputSchema"
fi

ALL_OBJECTS=$(jq '[.[].inputSchema.type] | all(. == "object")' /tmp/ncl-demo-tools-export.json 2>/dev/null || echo false)
if [ "$ALL_OBJECTS" = "true" ]; then
  pass "All inputSchemas are type=object"
else
  fail "Some inputSchemas not type=object"
fi

HAS_SERVER=$(jq 'has("server") and has("tools")' /tmp/ncl-server-config.json 2>/dev/null || echo false)
if [ "$HAS_SERVER" = "true" ]; then
  pass "Server config has server + tools"
else
  fail "Server config missing server or tools"
fi

SERVER_NAME=$(jq -r '.server.name' /tmp/ncl-server-config.json 2>/dev/null || echo "")
if [ "$SERVER_NAME" = "demo-tools" ]; then
  pass "Server name is demo-tools"
else
  fail "Server name is '$SERVER_NAME' (expected demo-tools)"
fi

echo ""

# --- Step 3: Snapshot comparison ---
echo "Step 3: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  jq -S . /tmp/ncl-demo-tools-export.json > /tmp/ncl-mcp-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/snapshot-mcp-normalized.json

  if diff -q /tmp/ncl-mcp-normalized.json /tmp/snapshot-mcp-normalized.json > /dev/null 2>&1; then
    pass "Demo tools export matches committed snapshot"
  else
    fail "Demo tools export differs from committed snapshot"
    echo "    Run: diff <(jq -S . /tmp/ncl-demo-tools-export.json) <(jq -S . $TESTS_DIR/snapshot.json)"
  fi
else
  fail "No snapshot.json found"
fi

echo ""

# --- Step 4: Cross-repo extraction (optional) ---
echo "Step 4: Cross-repo extraction"

if [ -n "$AGENTS_DIR" ] && [ -d "$AGENTS_DIR/node_modules/zod" ]; then
  echo "  Agents repo with dependencies found at $AGENTS_DIR"
  if cd "$AGENTS_DIR" && npx tsx "$TESTS_DIR/extract-schemas.ts" > /tmp/ts-mcp-extracted.json 2>/dev/null; then
    jq -S 'del(.[]."$schema") | del(.[].inputSchema."$schema") | del(.[].inputSchema.additionalProperties)' \
      /tmp/ts-mcp-extracted.json > /tmp/ts-mcp-normalized.json

    if diff -q /tmp/ncl-mcp-normalized.json /tmp/ts-mcp-normalized.json > /dev/null 2>&1; then
      pass "Demo tools export matches TS extraction"
    else
      fail "Demo tools export differs from TS extraction"
      echo "    Run: diff /tmp/ncl-mcp-normalized.json /tmp/ts-mcp-normalized.json"
    fi
  else
    fail "TS extraction script failed"
  fi
else
  echo "  Skipped — agents repo not found or node_modules missing"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
