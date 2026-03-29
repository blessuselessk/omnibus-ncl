#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Cross-repo test for codemode-ncl
#
# Compares Nickel-exported tool schemas against the TypeScript ground truth.
# Run from omnibus-ncl root: bash codemode/tests/validate.sh
#
# Set AGENTS_DIR to override the agents repo path.
# When AGENTS_DIR is unset or node_modules missing, falls back to committed snapshot.

AGENTS_DIR="${AGENTS_DIR:-}"
NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== codemode-ncl validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

if nickel export --format json "$NCL_DIR/examples/pm-tools-export.ncl" > /tmp/ncl-pm-tools.json 2>/dev/null; then
  pass "pm-tools-export.ncl exports as JSON"
else
  fail "pm-tools-export.ncl export failed"
fi

if nickel export --format json "$NCL_DIR/examples/single-tool.ncl" > /dev/null 2>&1; then
  pass "single-tool.ncl exports as JSON"
else
  fail "single-tool.ncl export failed"
fi

echo ""

# --- Step 2: Structure validation ---
echo "Step 2: Structure validation (tool count, required fields)"

TOOL_COUNT=$(jq 'keys | length' /tmp/ncl-pm-tools.json 2>/dev/null || echo 0)
if [ "$TOOL_COUNT" -eq 10 ]; then
  pass "PM tools count is 10"
else
  fail "PM tools count is $TOOL_COUNT (expected 10)"
fi

# Check every tool has description + inputSchema
ALL_HAVE_SCHEMA=$(jq '[.[] | has("description", "inputSchema")] | all' /tmp/ncl-pm-tools.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_SCHEMA" = "true" ]; then
  pass "All tools have description + inputSchema"
else
  fail "Some tools missing description or inputSchema"
fi

# Check all inputSchemas have type = "object"
ALL_OBJECTS=$(jq '[.[].inputSchema.type] | all(. == "object")' /tmp/ncl-pm-tools.json 2>/dev/null || echo false)
if [ "$ALL_OBJECTS" = "true" ]; then
  pass "All inputSchemas are type=object"
else
  fail "Some inputSchemas not type=object"
fi

echo ""

# --- Step 3: Snapshot comparison ---
echo "Step 3: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  # Normalize both (sort keys) and compare
  jq -S . /tmp/ncl-pm-tools.json > /tmp/ncl-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/snapshot-normalized.json

  if diff -q /tmp/ncl-normalized.json /tmp/snapshot-normalized.json > /dev/null 2>&1; then
    pass "Nickel export matches committed snapshot"
  else
    fail "Nickel export differs from committed snapshot"
    echo "    Run: diff <(jq -S . /tmp/ncl-pm-tools.json) <(jq -S . $TESTS_DIR/snapshot.json)"
  fi
else
  fail "No snapshot.json found — run cm-snapshot to generate"
fi

echo ""

# --- Step 4: Cross-repo extraction (optional) ---
echo "Step 4: Cross-repo extraction"

if [ -n "$AGENTS_DIR" ] && [ -d "$AGENTS_DIR/node_modules/zod" ]; then
  echo "  Agents repo with dependencies found at $AGENTS_DIR"
  if cd "$AGENTS_DIR" && npx tsx "$TESTS_DIR/extract-schemas.ts" > /tmp/ts-extracted.json 2>/dev/null; then
    # Normalize TS output (strip $schema, additionalProperties, sort keys)
    jq -S 'del(.[]."$schema") | del(.[].inputSchema."$schema") | del(.[].inputSchema.additionalProperties)' \
      /tmp/ts-extracted.json > /tmp/ts-normalized.json

    if diff -q /tmp/ncl-normalized.json /tmp/ts-normalized.json > /dev/null 2>&1; then
      pass "Nickel export matches TS extraction"
    else
      fail "Nickel export differs from TS extraction"
      echo "    Run: diff /tmp/ncl-normalized.json /tmp/ts-normalized.json"
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
