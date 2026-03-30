#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for apm-ncl Nickel definitions
#
# Run from omnibus-ncl root: bash apm-ncl/tests/validate.sh

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== apm-ncl validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in manifest-export simple-manifest lockfile-example; do
  if nickel export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-apm-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Manifest structure validation ---
echo "Step 2: Manifest structure validation"

HAS_NAME=$(jq 'has("name")' /tmp/ncl-apm-manifest-export.json 2>/dev/null || echo false)
if [ "$HAS_NAME" = "true" ]; then
  pass "Manifest has name"
else
  fail "Manifest missing name"
fi

HAS_VERSION=$(jq 'has("version")' /tmp/ncl-apm-manifest-export.json 2>/dev/null || echo false)
if [ "$HAS_VERSION" = "true" ]; then
  pass "Manifest has version"
else
  fail "Manifest missing version"
fi

HAS_DEPS=$(jq 'has("dependencies")' /tmp/ncl-apm-manifest-export.json 2>/dev/null || echo false)
if [ "$HAS_DEPS" = "true" ]; then
  pass "Manifest has dependencies"
else
  fail "Manifest missing dependencies"
fi

HAS_COMPILATION=$(jq 'has("compilation")' /tmp/ncl-apm-manifest-export.json 2>/dev/null || echo false)
if [ "$HAS_COMPILATION" = "true" ]; then
  pass "Manifest has compilation"
else
  fail "Manifest missing compilation"
fi

APM_DEP_COUNT=$(jq '.dependencies.apm | length' /tmp/ncl-apm-manifest-export.json 2>/dev/null || echo 0)
if [ "$APM_DEP_COUNT" -eq 3 ]; then
  pass "APM dependency count is 3"
else
  fail "APM dependency count is $APM_DEP_COUNT (expected 3)"
fi

MCP_DEP_COUNT=$(jq '.dependencies.mcp | length' /tmp/ncl-apm-manifest-export.json 2>/dev/null || echo 0)
if [ "$MCP_DEP_COUNT" -eq 3 ]; then
  pass "MCP dependency count is 3"
else
  fail "MCP dependency count is $MCP_DEP_COUNT (expected 3)"
fi

TARGET=$(jq -r '.target' /tmp/ncl-apm-manifest-export.json 2>/dev/null || echo "")
if [ "$TARGET" = "claude" ]; then
  pass "Target is claude"
else
  fail "Target is '$TARGET' (expected claude)"
fi

echo ""

# --- Step 3: Lockfile structure validation ---
echo "Step 3: Lockfile structure validation"

HAS_LOCKVER=$(jq 'has("lockfile_version")' /tmp/ncl-apm-lockfile-example.json 2>/dev/null || echo false)
if [ "$HAS_LOCKVER" = "true" ]; then
  pass "Lockfile has lockfile_version"
else
  fail "Lockfile missing lockfile_version"
fi

LOCK_DEP_COUNT=$(jq '.dependencies | length' /tmp/ncl-apm-lockfile-example.json 2>/dev/null || echo 0)
if [ "$LOCK_DEP_COUNT" -eq 2 ]; then
  pass "Lockfile dependency count is 2"
else
  fail "Lockfile dependency count is $LOCK_DEP_COUNT (expected 2)"
fi

ALL_HAVE_HASH=$(jq '[.dependencies[] | has("content_hash")] | all' /tmp/ncl-apm-lockfile-example.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_HASH" = "true" ]; then
  pass "All lock entries have content_hash"
else
  fail "Some lock entries missing content_hash"
fi

ALL_HAVE_COMMIT=$(jq '[.dependencies[] | has("resolved_commit")] | all' /tmp/ncl-apm-lockfile-example.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_COMMIT" = "true" ]; then
  pass "All lock entries have resolved_commit"
else
  fail "Some lock entries missing resolved_commit"
fi

echo ""

# --- Step 4: Snapshot comparison ---
echo "Step 4: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  jq -S . /tmp/ncl-apm-manifest-export.json > /tmp/ncl-apm-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/snapshot-apm-normalized.json

  if diff -q /tmp/ncl-apm-normalized.json /tmp/snapshot-apm-normalized.json > /dev/null 2>&1; then
    pass "Manifest export matches committed snapshot"
  else
    fail "Manifest export differs from committed snapshot"
    echo "    Run: diff <(jq -S . /tmp/ncl-apm-manifest-export.json) <(jq -S . $TESTS_DIR/snapshot.json)"
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
