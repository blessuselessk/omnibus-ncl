#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for codemode-mcp-openapi Nickel definitions
#
# Run from omnibus-ncl root: bash codemode-mcp-openapi/tests/validate.sh

AGENTS_DIR="${AGENTS_DIR:-}"
NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== codemode-mcp-openapi validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in mcp-tools-export mcp-server openapi-server request-examples; do
  if nickel export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Structure validation ---
echo "Step 2: Structure validation"

# MCP tools: should have 3 tools
TOOL_COUNT=$(jq 'keys | length' /tmp/ncl-mcp-tools-export.json 2>/dev/null || echo 0)
if [ "$TOOL_COUNT" -eq 3 ]; then
  pass "MCP tool count is 3"
else
  fail "MCP tool count is $TOOL_COUNT (expected 3)"
fi

# All MCP tools have description + inputSchema
ALL_HAVE_SCHEMA=$(jq '[.[] | has("description", "inputSchema")] | all' /tmp/ncl-mcp-tools-export.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_SCHEMA" = "true" ]; then
  pass "All MCP tools have description + inputSchema"
else
  fail "Some MCP tools missing description or inputSchema"
fi

# MCP server config has server.name + tools
HAS_SERVER=$(jq 'has("server") and has("tools")' /tmp/ncl-mcp-server.json 2>/dev/null || echo false)
if [ "$HAS_SERVER" = "true" ]; then
  pass "MCP server config has server + tools"
else
  fail "MCP server config missing server or tools"
fi

# OpenAPI server has name + spec_url
HAS_OPENAPI=$(jq 'has("name") and has("spec_url")' /tmp/ncl-openapi-server.json 2>/dev/null || echo false)
if [ "$HAS_OPENAPI" = "true" ]; then
  pass "OpenAPI server config has name + spec_url"
else
  fail "OpenAPI server config missing name or spec_url"
fi

# Request examples: all have method + path
ALL_REQUESTS=$(jq '[.[] | has("method", "path")] | all' /tmp/ncl-request-examples.json 2>/dev/null || echo false)
if [ "$ALL_REQUESTS" = "true" ]; then
  pass "All request examples have method + path"
else
  fail "Some request examples missing method or path"
fi

# Request examples: 4 examples
REQ_COUNT=$(jq 'keys | length' /tmp/ncl-request-examples.json 2>/dev/null || echo 0)
if [ "$REQ_COUNT" -eq 4 ]; then
  pass "Request examples count is 4"
else
  fail "Request examples count is $REQ_COUNT (expected 4)"
fi

echo ""

# --- Step 3: Snapshot comparison ---
echo "Step 3: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  jq -S . /tmp/ncl-mcp-tools-export.json > /tmp/ncl-mcp-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/snapshot-mcp-normalized.json

  if diff -q /tmp/ncl-mcp-normalized.json /tmp/snapshot-mcp-normalized.json > /dev/null 2>&1; then
    pass "MCP tools export matches committed snapshot"
  else
    fail "MCP tools export differs from committed snapshot"
    echo "    Run: diff <(jq -S . /tmp/ncl-mcp-tools-export.json) <(jq -S . $TESTS_DIR/snapshot.json)"
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
      pass "MCP tools export matches TS extraction"
    else
      fail "MCP tools export differs from TS extraction"
      echo "    Run: diff /tmp/ncl-mcp-normalized.json /tmp/ts-mcp-normalized.json"
    fi
  else
    fail "TS extraction script failed"
  fi
else
  echo "  Skipped — agents repo not found or node_modules missing"
  echo "  Set AGENTS_DIR and run npm install in agents repo to enable"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
