#!/usr/bin/env bash
set -euo pipefail

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== codemode-nickel validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in nickel-tools-export sample-project provider-config; do
  if nickel export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Structure validation ---
echo "Step 2: Structure validation"

TOOL_COUNT=$(jq 'keys | length' /tmp/ncl-nickel-tools-export.json 2>/dev/null || echo 0)
if [ "$TOOL_COUNT" -eq 6 ]; then
  pass "Nickel tool count is 6"
else
  fail "Nickel tool count is $TOOL_COUNT (expected 6)"
fi

ALL_HAVE_SCHEMA=$(jq '[.[] | has("description") and has("inputSchema")] | all' /tmp/ncl-nickel-tools-export.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_SCHEMA" = "true" ]; then
  pass "All tools have description + inputSchema"
else
  fail "Some tools missing description or inputSchema"
fi

HAS_PROJECT_FIELDS=$(jq 'has("name") and has("description") and has("files")' /tmp/ncl-sample-project.json 2>/dev/null || echo false)
if [ "$HAS_PROJECT_FIELDS" = "true" ]; then
  pass "Sample project has name + description + files"
else
  fail "Sample project missing required fields"
fi

FILE_COUNT=$(jq '.files | length' /tmp/ncl-sample-project.json 2>/dev/null || echo 0)
if [ "$FILE_COUNT" -eq 7 ]; then
  pass "Sample project has 7 files"
else
  fail "Sample project has $FILE_COUNT files (expected 7)"
fi

PROVIDER_COUNT=$(jq '.providers | length' /tmp/ncl-provider-config.json 2>/dev/null || echo 0)
if [ "$PROVIDER_COUNT" -eq 3 ]; then
  pass "Provider config has 3 providers (state, nickel, git)"
else
  fail "Provider config has $PROVIDER_COUNT providers (expected 3)"
fi

echo ""

# --- Step 3: Snapshot comparison ---
echo "Step 3: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  jq -S . /tmp/ncl-nickel-tools-export.json > /tmp/ncl-nickel-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/snapshot-nickel-normalized.json

  if diff -q /tmp/ncl-nickel-normalized.json /tmp/snapshot-nickel-normalized.json > /dev/null 2>&1; then
    pass "Nickel tools export matches committed snapshot"
  else
    fail "Nickel tools export differs from committed snapshot"
  fi
else
  fail "No snapshot.json found"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
