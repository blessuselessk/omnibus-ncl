#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for envelope-ncl Nickel definitions
#
# Run from omnibus-ncl root: bash envelope-ncl/tests/validate.sh

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
NICKEL="${NICKEL:-nickel}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== envelope-ncl validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Export validation"

for f in tool-in-sandbox sandbox-in-workflow three-layer flatten-export; do
  if $NICKEL export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-env-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Envelope structure ---
echo "Step 2: Envelope structure"

for field in name payload constraints target; do
  HAS=$(jq "has(\"$field\")" /tmp/ncl-env-tool-in-sandbox.json 2>/dev/null || echo false)
  if [ "$HAS" = "true" ]; then
    pass "Envelope has '$field'"
  else
    fail "Envelope missing '$field'"
  fi
done

echo ""

# --- Step 3: Nesting validation ---
echo "Step 3: Nesting"

HAS_INNER=$(jq 'has("inner")' /tmp/ncl-env-tool-in-sandbox.json 2>/dev/null || echo false)
if [ "$HAS_INNER" = "true" ]; then
  pass "tool-in-sandbox has inner envelope"
else
  fail "tool-in-sandbox missing inner envelope"
fi

HAS_INNER_INNER=$(jq '.inner | has("inner")' /tmp/ncl-env-three-layer.json 2>/dev/null || echo false)
if [ "$HAS_INNER_INNER" = "true" ]; then
  pass "three-layer has 3 nesting levels"
else
  fail "three-layer missing third nesting level"
fi

echo ""

# --- Step 4: Monotonic restriction ---
echo "Step 4: Monotonic restriction"

# In sandbox-in-workflow: outer is full network, inner should be clamped to localhost
OUTER_NET=$(jq -r '.constraints.network.mode' /tmp/ncl-env-sandbox-in-workflow.json 2>/dev/null || echo "")
INNER_NET=$(jq -r '.inner.constraints.network.mode' /tmp/ncl-env-sandbox-in-workflow.json 2>/dev/null || echo "")
if [ "$OUTER_NET" = "full" ] && [ "$INNER_NET" = "localhost" ]; then
  pass "Network clamped: full → localhost"
else
  fail "Network not clamped: outer=$OUTER_NET inner=$INNER_NET"
fi

# In three-layer: innermost should have smallest resource limits
OUTER_MEM=$(jq '.constraints.resources.timeout_seconds // 9999' /tmp/ncl-env-three-layer.json 2>/dev/null || echo 9999)
MID_MEM=$(jq '.inner.constraints.resources.max_memory_mb' /tmp/ncl-env-three-layer.json 2>/dev/null || echo 9999)
INNER_MEM=$(jq '.inner.inner.constraints.resources.max_memory_mb' /tmp/ncl-env-three-layer.json 2>/dev/null || echo 9999)
if [ "$INNER_MEM" -le "$MID_MEM" ]; then
  pass "Resources monotonically restricted: mid=${MID_MEM}MB >= inner=${INNER_MEM}MB"
else
  fail "Resources NOT monotonic: mid=${MID_MEM}MB < inner=${INNER_MEM}MB"
fi

echo ""

# --- Step 5: Flatten validation ---
echo "Step 5: Flatten"

LAYER_COUNT=$(jq 'length' /tmp/ncl-env-flatten-export.json 2>/dev/null || echo 0)
if [ "$LAYER_COUNT" -eq 3 ]; then
  pass "Flatten produces 3 layers"
else
  fail "Flatten produces $LAYER_COUNT layers (expected 3)"
fi

FIRST_NAME=$(jq -r '.[0].name' /tmp/ncl-env-flatten-export.json 2>/dev/null || echo "")
LAST_NAME=$(jq -r '.[-1].name' /tmp/ncl-env-flatten-export.json 2>/dev/null || echo "")
if [ "$FIRST_NAME" = "sandboxed-jq" ] && [ "$LAST_NAME" = "jq" ]; then
  pass "Flatten order: outermost first, innermost last"
else
  fail "Flatten order wrong: first=$FIRST_NAME last=$LAST_NAME"
fi

NO_INNER=$(jq '[.[] | has("inner")] | any' /tmp/ncl-env-flatten-export.json 2>/dev/null || echo true)
if [ "$NO_INNER" = "false" ]; then
  pass "Flattened layers have no inner field"
else
  fail "Flattened layers still contain inner field"
fi

echo ""

# --- Step 6: Target variety ---
echo "Step 6: Target types"

TARGETS=$(jq -r '[.[] | .target.kind] | unique | sort | join(",")' /tmp/ncl-env-flatten-export.json 2>/dev/null || echo "")
if echo "$TARGETS" | grep -q "sandbox" && echo "$TARGETS" | grep -q "workflow"; then
  pass "Multiple target types present: $TARGETS"
else
  fail "Expected multiple target types, got: $TARGETS"
fi

echo ""

# --- Step 7: Snapshot comparison ---
echo "Step 7: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot-three-layer.json" ]; then
  jq -S . /tmp/ncl-env-three-layer.json > /tmp/env-three-normalized.json
  jq -S . "$TESTS_DIR/snapshot-three-layer.json" > /tmp/env-snapshot-three-normalized.json

  if diff -q /tmp/env-three-normalized.json /tmp/env-snapshot-three-normalized.json > /dev/null 2>&1; then
    pass "Three-layer export matches committed snapshot"
  else
    fail "Three-layer export differs from committed snapshot"
    echo "    Update: just env-snapshot"
  fi
else
  fail "No snapshot-three-layer.json found — run: just env-snapshot"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
