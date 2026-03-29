#!/usr/bin/env bash
set -euo pipefail

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== codemode-shell validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in state-tools git-tools workspace-config multi-provider; do
  if nickel export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Structure validation ---
echo "Step 2: Structure validation"

STATE_COUNT=$(jq 'keys | length' /tmp/ncl-state-tools.json 2>/dev/null || echo 0)
if [ "$STATE_COUNT" -eq 46 ]; then
  pass "State tool count is 46"
else
  fail "State tool count is $STATE_COUNT (expected 46)"
fi

GIT_COUNT=$(jq 'keys | length' /tmp/ncl-git-tools.json 2>/dev/null || echo 0)
if [ "$GIT_COUNT" -eq 14 ]; then
  pass "Git tool count is 14"
else
  fail "Git tool count is $GIT_COUNT (expected 14)"
fi

ALL_STATE_DESC=$(jq '[.[] | has("description")] | all' /tmp/ncl-state-tools.json 2>/dev/null || echo false)
if [ "$ALL_STATE_DESC" = "true" ]; then
  pass "All state tools have description"
else
  fail "Some state tools missing description"
fi

ALL_GIT_DESC=$(jq '[.[] | has("description")] | all' /tmp/ncl-git-tools.json 2>/dev/null || echo false)
if [ "$ALL_GIT_DESC" = "true" ]; then
  pass "All git tools have description"
else
  fail "Some git tools missing description"
fi

PROVIDER_COUNT=$(jq '.providers | length' /tmp/ncl-multi-provider.json 2>/dev/null || echo 0)
if [ "$PROVIDER_COUNT" -eq 3 ]; then
  pass "Multi-provider has 3 providers"
else
  fail "Multi-provider has $PROVIDER_COUNT providers (expected 3)"
fi

# Check state has positionalArgs providers
STATE_POS=$(jq '.providers[] | select(.name == "state") | .positionalArgs' /tmp/ncl-multi-provider.json 2>/dev/null || echo false)
if [ "$STATE_POS" = "true" ]; then
  pass "State provider uses positionalArgs"
else
  fail "State provider positionalArgs is not true"
fi

echo ""

# --- Step 3: Snapshot comparison ---
echo "Step 3: Snapshot comparison"

for name in state git; do
  snap="$TESTS_DIR/snapshot-$name.json"
  tmp="/tmp/ncl-${name}-tools.json"
  if [ -f "$snap" ]; then
    if diff -q <(jq -S . "$tmp") <(jq -S . "$snap") > /dev/null 2>&1; then
      pass "${name} tools match committed snapshot"
    else
      fail "${name} tools differ from committed snapshot"
    fi
  else
    fail "No snapshot-$name.json found"
  fi
done

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
