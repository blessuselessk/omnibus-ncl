#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for massless-driver Nickel definitions
#
# Run from omnibus-ncl root: bash massless-driver/tests/validate.sh

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
NICKEL="${NICKEL:-nickel}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== massless-driver validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in workflow-export nix-workflow-export manifest-export; do
  if $NICKEL export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-md-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Workflow structure validation ---
echo "Step 2: Workflow structure validation"

for field in name on permissions jobs; do
  HAS=$(jq "has(\"$field\")" /tmp/ncl-md-workflow-export.json 2>/dev/null || echo false)
  if [ "$HAS" = "true" ]; then
    pass "Workflow has '$field'"
  else
    fail "Workflow missing '$field'"
  fi
done

HAS_BUILD=$(jq '.jobs | has("build")' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo false)
if [ "$HAS_BUILD" = "true" ]; then
  pass "Workflow has jobs.build"
else
  fail "Workflow missing jobs.build"
fi

HAS_RUNS_ON=$(jq '.jobs.build | has("runs-on")' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo false)
if [ "$HAS_RUNS_ON" = "true" ]; then
  pass "jobs.build has runs-on"
else
  fail "jobs.build missing runs-on"
fi

STEP_COUNT=$(jq '.jobs.build.steps | length' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo 0)
if [ "$STEP_COUNT" -ge 2 ]; then
  pass "jobs.build has $STEP_COUNT steps"
else
  fail "jobs.build has too few steps ($STEP_COUNT)"
fi

echo ""

# --- Step 3: Variant validation ---
echo "Step 3: Variant validation (bash vs nix)"

BASH_RUN=$(jq -r '.jobs.build.steps[] | select(.name == "Run Job") | .run' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo "")
if echo "$BASH_RUN" | grep -q "job.sh"; then
  pass "Bash workflow runs job.sh"
else
  fail "Bash workflow missing job.sh execution"
fi

NIX_INSTALLER=$(jq -r '[.jobs.build.steps[].uses // empty] | map(select(contains("nix-installer"))) | length' /tmp/ncl-md-nix-workflow-export.json 2>/dev/null || echo 0)
if [ "$NIX_INSTALLER" -ge 1 ]; then
  pass "Nix workflow has nix-installer-action"
else
  fail "Nix workflow missing nix-installer-action"
fi

NIX_RUN=$(jq -r '.jobs.build.steps[] | select(.name == "Run Nix Job") | .run' /tmp/ncl-md-nix-workflow-export.json 2>/dev/null || echo "")
if echo "$NIX_RUN" | grep -q "nix run"; then
  pass "Nix workflow runs nix run"
else
  fail "Nix workflow missing nix run"
fi

echo ""

# --- Step 4: Secrets injection validation ---
echo "Step 4: Secrets injection"

SECRET_KEYS=$(jq '[.jobs.build.steps[] | select(has("env")) | .env | keys[]] | sort' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo "[]")
for secret in API_KEY DB_PASSWORD DOCKER_TOKEN; do
  if echo "$SECRET_KEYS" | jq -e "index(\"$secret\")" > /dev/null 2>&1; then
    pass "Secret $secret injected"
  else
    fail "Secret $secret missing"
  fi
done

SECRET_REF=$(jq -r '.jobs.build.steps[] | select(has("env")) | .env.API_KEY' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo "")
if echo "$SECRET_REF" | grep -q 'secrets.API_KEY'; then
  pass "Secret refs use \${{ secrets.NAME }} format"
else
  fail "Secret refs wrong format: $SECRET_REF"
fi

echo ""

# --- Step 5: Conditional steps validation ---
echo "Step 5: Conditional steps"

TS_STEP=$(jq '[.jobs.build.steps[] | select(.name == "Join Tailscale")] | length' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo 0)
if [ "$TS_STEP" -ge 1 ]; then
  pass "Tailscale step present (enabled=true)"
else
  fail "Tailscale step missing despite enabled=true"
fi

TS_STEP_NIX=$(jq '[.jobs.build.steps[] | select(.name == "Join Tailscale")] | length' /tmp/ncl-md-nix-workflow-export.json 2>/dev/null || echo 0)
if [ "$TS_STEP_NIX" -eq 0 ]; then
  pass "Tailscale step absent in nix job (enabled=false)"
else
  fail "Tailscale step present in nix job despite enabled=false"
fi

ARTIFACT_STEP=$(jq '[.jobs.build.steps[] | select(.name == "Upload artifact")] | length' /tmp/ncl-md-workflow-export.json 2>/dev/null || echo 0)
if [ "$ARTIFACT_STEP" -ge 1 ]; then
  pass "Artifact upload step present (enabled=true)"
else
  fail "Artifact upload step missing despite enabled=true"
fi

echo ""

# --- Step 6: Manifest validation ---
echo "Step 6: Manifest fields"

for field in name owner variant runner timeout_seconds auto_delete visibility artifacts_enabled release_enabled tailscale_enabled secret_count; do
  HAS=$(jq "has(\"$field\")" /tmp/ncl-md-manifest-export.json 2>/dev/null || echo false)
  if [ "$HAS" = "true" ]; then
    pass "Manifest has '$field'"
  else
    fail "Manifest missing '$field'"
  fi
done

VARIANT=$(jq -r '.variant' /tmp/ncl-md-manifest-export.json 2>/dev/null || echo "")
if [ "$VARIANT" = "bash" ]; then
  pass "Manifest variant serialized as string"
else
  fail "Manifest variant is '$VARIANT' (expected 'bash')"
fi

echo ""

# --- Step 7: Snapshot comparison ---
echo "Step 7: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot-workflow.json" ]; then
  jq -S . /tmp/ncl-md-workflow-export.json > /tmp/md-workflow-normalized.json
  jq -S . "$TESTS_DIR/snapshot-workflow.json" > /tmp/md-snapshot-workflow-normalized.json

  if diff -q /tmp/md-workflow-normalized.json /tmp/md-snapshot-workflow-normalized.json > /dev/null 2>&1; then
    pass "Workflow export matches committed snapshot"
  else
    fail "Workflow export differs from committed snapshot"
    echo "    Run: diff <(jq -S . /tmp/ncl-md-workflow-export.json) <(jq -S . $TESTS_DIR/snapshot-workflow.json)"
    echo "    Update: just md-snapshot"
  fi
else
  fail "No snapshot-workflow.json found — run: just md-snapshot"
fi

if [ -f "$TESTS_DIR/snapshot-manifest.json" ]; then
  jq -S . /tmp/ncl-md-manifest-export.json > /tmp/md-manifest-normalized.json
  jq -S . "$TESTS_DIR/snapshot-manifest.json" > /tmp/md-snapshot-manifest-normalized.json

  if diff -q /tmp/md-manifest-normalized.json /tmp/md-snapshot-manifest-normalized.json > /dev/null 2>&1; then
    pass "Manifest export matches committed snapshot"
  else
    fail "Manifest export differs from committed snapshot"
    echo "    Run: diff <(jq -S . /tmp/ncl-md-manifest-export.json) <(jq -S . $TESTS_DIR/snapshot-manifest.json)"
    echo "    Update: just md-snapshot"
  fi
else
  fail "No snapshot-manifest.json found — run: just md-snapshot"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
