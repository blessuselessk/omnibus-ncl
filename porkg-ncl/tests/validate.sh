#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for porkg-ncl Nickel definitions
#
# Run from omnibus-ncl root: bash porkg-ncl/tests/validate.sh

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
NICKEL="${NICKEL:-nickel}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== porkg-ncl validation ==="
echo ""

# --- Step 1: Export validation ---
echo "Step 1: Export validation"

for f in config-export pipeline-export proto-export; do
  if $NICKEL export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-porkg-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Config structure ---
echo "Step 2: Config structure"

for field in worker jobs log_level tag_map; do
  HAS=$(jq "has(\"$field\")" /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
  if [ "$HAS" = "true" ]; then
    pass "Config has '$field'"
  else
    fail "Config missing '$field'"
  fi
done

echo ""

# --- Step 3: Worker fields ---
echo "Step 3: Worker fields"

for field in name namespaces privilege proto shutdown_timeout_seconds max_jobs; do
  HAS=$(jq ".worker | has(\"$field\")" /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
  if [ "$HAS" = "true" ]; then
    pass "Worker has '$field'"
  else
    fail "Worker missing '$field'"
  fi
done

echo ""

# --- Step 4: Namespace isolation ---
echo "Step 4: Namespace isolation"

PID_NS=$(jq '.worker.namespaces.pid' /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
MOUNT_NS=$(jq '.worker.namespaces.mount' /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
USER_NS=$(jq '.worker.namespaces.user' /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
NET_NS=$(jq '.worker.namespaces.net' /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
if [ "$PID_NS" = "true" ] && [ "$MOUNT_NS" = "true" ] && [ "$USER_NS" = "true" ] && [ "$NET_NS" = "true" ]; then
  pass "Network-isolated preset has pid+mount+user+net"
else
  fail "Namespace flags incorrect"
fi

# Locked-down should have full isolation
ALL_NS=$(jq '[.worker.namespaces | to_entries[] | .value] | all' /tmp/ncl-porkg-pipeline-export.json 2>/dev/null || echo false)
if [ "$ALL_NS" = "true" ]; then
  pass "Full isolation has all namespaces enabled"
else
  fail "Full isolation missing some namespaces"
fi

echo ""

# --- Step 5: Privilege escalation ---
echo "Step 5: Privilege escalation"

ESCALATION=$(jq '.worker.privilege.allow_escalation' /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
if [ "$ESCALATION" = "true" ]; then
  pass "Nix pipeline allows escalation"
else
  fail "Nix pipeline should allow escalation"
fi

NO_ESCALATION=$(jq '.worker.privilege.allow_escalation' /tmp/ncl-porkg-pipeline-export.json 2>/dev/null || echo true)
if [ "$NO_ESCALATION" = "false" ]; then
  pass "Locked-down disables escalation"
else
  fail "Locked-down should disable escalation"
fi

echo ""

# --- Step 6: Protocol ---
echo "Step 6: Protocol"

MSG_COUNT=$(jq '.messages | length' /tmp/ncl-porkg-proto-export.json 2>/dev/null || echo 0)
if [ "$MSG_COUNT" -eq 3 ]; then
  pass "Protocol has 3 message types"
else
  fail "Protocol has $MSG_COUNT messages (expected 3)"
fi

TAGS=$(jq -r '[.messages[].tag] | sort | join(",")' /tmp/ncl-porkg-proto-export.json 2>/dev/null || echo "")
if [ "$TAGS" = "begin,quit,start" ]; then
  pass "Message tags: begin, quit, start"
else
  fail "Unexpected tags: $TAGS"
fi

BYTE_ORDER=$(jq -r '.proto.byte_order' /tmp/ncl-porkg-proto-export.json 2>/dev/null || echo "")
if [ "$BYTE_ORDER" = "big_endian" ]; then
  pass "Wire byte order is big-endian"
else
  fail "Wire byte order is '$BYTE_ORDER' (expected big_endian)"
fi

echo ""

# --- Step 7: Job specs ---
echo "Step 7: Job specs"

JOB_COUNT=$(jq '.jobs | length' /tmp/ncl-porkg-config-export.json 2>/dev/null || echo 0)
if [ "$JOB_COUNT" -eq 3 ]; then
  pass "Nix pipeline has 3 jobs"
else
  fail "Nix pipeline has $JOB_COUNT jobs (expected 3)"
fi

ALL_JOBS_HAVE_CMD=$(jq '[.jobs[] | has("command") and (.command | length > 0)] | all' /tmp/ncl-porkg-config-export.json 2>/dev/null || echo false)
if [ "$ALL_JOBS_HAVE_CMD" = "true" ]; then
  pass "All jobs have non-empty commands"
else
  fail "Some jobs missing commands"
fi

# Locked-down jobs should have allowed_paths
HAS_PATHS=$(jq '[.jobs[] | .allowed_paths | length > 0] | all' /tmp/ncl-porkg-pipeline-export.json 2>/dev/null || echo false)
if [ "$HAS_PATHS" = "true" ]; then
  pass "Locked-down jobs have allowed_paths"
else
  fail "Locked-down jobs missing allowed_paths"
fi

echo ""

# --- Step 8: Snapshot comparison ---
echo "Step 8: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  jq -S . /tmp/ncl-porkg-config-export.json > /tmp/porkg-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/porkg-snapshot-normalized.json

  if diff -q /tmp/porkg-normalized.json /tmp/porkg-snapshot-normalized.json > /dev/null 2>&1; then
    pass "Config export matches committed snapshot"
  else
    fail "Config export differs from committed snapshot"
    echo "    Update: just porkg-snapshot"
  fi
else
  fail "No snapshot.json found — run: just porkg-snapshot"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
