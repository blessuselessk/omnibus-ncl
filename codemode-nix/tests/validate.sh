#!/usr/bin/env bash
set -euo pipefail

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
NICKEL="${NICKEL:-nickel}"
JQ="${JQ:-jq}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== codemode-nix validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in nix-tools-export nix-registry provider-config; do
  if $NICKEL export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-cnix-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Structure validation ---
echo "Step 2: Structure validation"

TOOL_COUNT=$($JQ 'keys | length' /tmp/ncl-cnix-nix-tools-export.json 2>/dev/null || echo 0)
if [ "$TOOL_COUNT" -eq 5 ]; then
  pass "Nix tool count is 5"
else
  fail "Nix tool count is $TOOL_COUNT (expected 5)"
fi

ALL_HAVE_SCHEMA=$($JQ '[.[] | has("description") and has("inputSchema")] | all' /tmp/ncl-cnix-nix-tools-export.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_SCHEMA" = "true" ]; then
  pass "All LLM-facing tools have description + inputSchema"
else
  fail "Some tools missing description or inputSchema"
fi

ALL_HAVE_SANDBOX=$($JQ '[.[] | has("sandbox") and has("flakeRef")] | all' /tmp/ncl-cnix-nix-registry.json 2>/dev/null || echo false)
if [ "$ALL_HAVE_SANDBOX" = "true" ]; then
  pass "All registry entries have sandbox + flakeRef"
else
  fail "Some registry entries missing sandbox or flakeRef"
fi

VALID_LEVELS=$($JQ '[.[].securityLevel] | all(. == "strict" or . == "network" or . == "io" or . == "full")' /tmp/ncl-cnix-nix-registry.json 2>/dev/null || echo false)
if [ "$VALID_LEVELS" = "true" ]; then
  pass "All security levels are valid"
else
  fail "Some security levels are invalid"
fi

ASPECT_COUNT=$($JQ '.aspects | length' /tmp/ncl-cnix-provider-config.json 2>/dev/null || echo 0)
if [ "$ASPECT_COUNT" -eq 3 ]; then
  pass "Aspect config has 3 aspects"
else
  fail "Aspect config has $ASPECT_COUNT aspects (expected 3)"
fi

echo ""

# --- Step 3: Snapshot comparison ---
echo "Step 3: Snapshot comparison"

for pair in "nix-tools-export:snapshot.json" "nix-registry:snapshot-registry.json"; do
  name="${pair%%:*}"
  snap_file="${pair##*:}"
  snap="$TESTS_DIR/$snap_file"
  tmp="/tmp/ncl-cnix-$name.json"

  if [ -f "$snap" ]; then
    if diff -q <($JQ -S . "$tmp") <($JQ -S . "$snap") > /dev/null 2>&1; then
      pass "$name matches committed snapshot"
    else
      fail "$name differs from committed snapshot"
    fi
  else
    fail "No $snap_file found"
  fi
done

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
