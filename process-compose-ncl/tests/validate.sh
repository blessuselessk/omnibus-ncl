#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for process-compose-ncl
#
# Run from omnibus-ncl root: bash process-compose-ncl/tests/validate.sh

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
NICKEL="${NICKEL:-nickel}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== process-compose-ncl validation ==="
echo ""

# --- Step 1: Export validation ---
echo "Step 1: Export validation"

for f in standalone-export envelope-bridge-export porkg-bridge-export; do
  if $NICKEL export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-pc-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Standalone structure ---
echo "Step 2: Standalone config structure"

HAS_VERSION=$(jq 'has("version")' /tmp/ncl-pc-standalone-export.json 2>/dev/null || echo false)
if [ "$HAS_VERSION" = "true" ]; then
  pass "Has version field"
else
  fail "Missing version field"
fi

HAS_PROCS=$(jq 'has("processes")' /tmp/ncl-pc-standalone-export.json 2>/dev/null || echo false)
if [ "$HAS_PROCS" = "true" ]; then
  pass "Has processes field"
else
  fail "Missing processes field"
fi

PROC_COUNT=$(jq '.processes | keys | length' /tmp/ncl-pc-standalone-export.json 2>/dev/null || echo 0)
if [ "$PROC_COUNT" -eq 3 ]; then
  pass "Standalone has 3 processes"
else
  fail "Standalone has $PROC_COUNT processes (expected 3)"
fi

echo ""

# --- Step 3: Dependencies ---
echo "Step 3: Dependency wiring"

API_DEP=$(jq -r '.processes.api.depends_on.postgres.condition' /tmp/ncl-pc-standalone-export.json 2>/dev/null || echo "")
if [ "$API_DEP" = "process_healthy" ]; then
  pass "API depends on postgres (process_healthy)"
else
  fail "API dependency wrong: $API_DEP"
fi

WORKER_DEP=$(jq -r '.processes.worker.depends_on.api.condition' /tmp/ncl-pc-standalone-export.json 2>/dev/null || echo "")
if [ "$WORKER_DEP" = "process_healthy" ]; then
  pass "Worker depends on API (process_healthy)"
else
  fail "Worker dependency wrong: $WORKER_DEP"
fi

echo ""

# --- Step 4: Health checks ---
echo "Step 4: Health checks"

PG_PROBE=$(jq '.processes.postgres | has("readiness_probe")' /tmp/ncl-pc-standalone-export.json 2>/dev/null || echo false)
if [ "$PG_PROBE" = "true" ]; then
  pass "Postgres has readiness probe"
else
  fail "Postgres missing readiness probe"
fi

API_HTTP=$(jq '.processes.api.readiness_probe | has("http_get")' /tmp/ncl-pc-standalone-export.json 2>/dev/null || echo false)
if [ "$API_HTTP" = "true" ]; then
  pass "API has HTTP health check"
else
  fail "API missing HTTP health check"
fi

echo ""

# --- Step 5: Envelope bridge ---
echo "Step 5: Envelope bridge"

ENV_PROCS=$(jq '.processes | keys | length' /tmp/ncl-pc-envelope-bridge-export.json 2>/dev/null || echo 0)
if [ "$ENV_PROCS" -eq 3 ]; then
  pass "Envelope bridge produces 3 processes"
else
  fail "Envelope bridge produces $ENV_PROCS processes (expected 3)"
fi

JQ_NS=$(jq -r '.processes.jq.namespace' /tmp/ncl-pc-envelope-bridge-export.json 2>/dev/null || echo "")
if [ "$JQ_NS" = "sandboxed" ]; then
  pass "Sandboxed process has 'sandboxed' namespace"
else
  fail "Sandboxed namespace wrong: $JQ_NS"
fi

WF_NS=$(jq -r '.processes["sandboxed-jq"].namespace' /tmp/ncl-pc-envelope-bridge-export.json 2>/dev/null || echo "")
if [ "$WF_NS" = "workflow" ]; then
  pass "Workflow process has 'workflow' namespace"
else
  fail "Workflow namespace wrong: $WF_NS"
fi

echo ""

# --- Step 6: porkg bridge ---
echo "Step 6: porkg bridge"

PORKG_PROCS=$(jq '.processes | keys | length' /tmp/ncl-pc-porkg-bridge-export.json 2>/dev/null || echo 0)
if [ "$PORKG_PROCS" -eq 4 ]; then
  pass "porkg bridge produces 4 processes (1 worker + 3 jobs)"
else
  fail "porkg bridge produces $PORKG_PROCS processes (expected 4)"
fi

WORKER_DAEMON=$(jq '.processes["nix-builder"].is_daemon' /tmp/ncl-pc-porkg-bridge-export.json 2>/dev/null || echo false)
if [ "$WORKER_DAEMON" = "true" ]; then
  pass "Worker is a daemon"
else
  fail "Worker should be a daemon"
fi

JOB_DEP=$(jq -r '.processes["build-cli"].depends_on["nix-builder"].condition' /tmp/ncl-pc-porkg-bridge-export.json 2>/dev/null || echo "")
if [ "$JOB_DEP" = "process_started" ]; then
  pass "Jobs depend on worker (process_started)"
else
  fail "Job dependency wrong: $JOB_DEP"
fi

echo ""

# --- Step 7: Snapshot comparison ---
echo "Step 7: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  jq -S . /tmp/ncl-pc-standalone-export.json > /tmp/pc-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/pc-snapshot-normalized.json

  if diff -q /tmp/pc-normalized.json /tmp/pc-snapshot-normalized.json > /dev/null 2>&1; then
    pass "Standalone export matches committed snapshot"
  else
    fail "Standalone export differs from committed snapshot"
    echo "    Update: just pc-snapshot"
  fi
else
  fail "No snapshot.json found — run: just pc-snapshot"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
