#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for tooling-ncl preload/cache layer
#
# Run from omnibus-ncl root: bash tooling-ncl/tests/validate.sh

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
NICKEL="${NICKEL:-nickel}"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== tooling-ncl validation ==="
echo ""

# --- Step 1: Export validation ---
echo "Step 1: Export validation"

for f in preload-basic preload-compose preload-blocked preload-incremental; do
  if $NICKEL export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-tn-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

# Also validate existing examples still work
for f in diagnose-apply diagnose-loop diagnose-partial diagnose-with-code diagnose-ralph-event fetch-compose pipeline-export markdown-script; do
  if $NICKEL export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-tn-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Lifecycle states ---
echo "Step 2: Lifecycle states"

# preload-incremental has 3 iterations: bare → partial/inferred → ready
STEP1_STATE=$(jq -r '.iterations[0].result.state' /tmp/ncl-tn-preload-incremental.json 2>/dev/null || echo "")
STEP1_COMP=$(jq -r '.iterations[0].result.completeness' /tmp/ncl-tn-preload-incremental.json 2>/dev/null || echo "0")
if [ "$STEP1_STATE" = "bare" ] && [ "$STEP1_COMP" -eq 10 ]; then
  pass "Step 1 (name only): state=bare, completeness=10"
else
  fail "Step 1 wrong: state=$STEP1_STATE, completeness=$STEP1_COMP (expected bare/10)"
fi

STEP2_STATE=$(jq -r '.iterations[1].result.state' /tmp/ncl-tn-preload-incremental.json 2>/dev/null || echo "")
STEP2_READY=$(jq -r '.iterations[1].result.ready' /tmp/ncl-tn-preload-incremental.json 2>/dev/null || echo "false")
if [ "$STEP2_STATE" = "ready" ] && [ "$STEP2_READY" = "true" ]; then
  pass "Step 2 (code+lang+inferred): state=ready"
else
  fail "Step 2 wrong: state=$STEP2_STATE, ready=$STEP2_READY (expected ready/true)"
fi

STEP3_COMPOSABLE=$(jq -r '.iterations[2].result.composable' /tmp/ncl-tn-preload-incremental.json 2>/dev/null || echo "false")
if [ "$STEP3_COMPOSABLE" = "true" ]; then
  pass "Step 3 (with schemas): composable=true"
else
  fail "Step 3 not composable (expected true)"
fi

echo ""

# --- Step 3: Composable vs ready distinction ---
echo "Step 3: Composable vs ready"

# preload-blocked has nodes that are neither ready nor composable
BARE_READY=$(jq -r '.node_states[0].ready' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "true")
BARE_COMP=$(jq -r '.node_states[0].composable' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "true")
if [ "$BARE_READY" = "false" ] && [ "$BARE_COMP" = "false" ]; then
  pass "Bare node: ready=false, composable=false"
else
  fail "Bare node: ready=$BARE_READY, composable=$BARE_COMP (expected false/false)"
fi

# preload-basic has nodes that are both ready AND composable
NODE0_READY=$(jq -r '.nodes[0].ready' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "false")
NODE0_COMP=$(jq -r '.nodes[0].composable' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "false")
if [ "$NODE0_READY" = "true" ] && [ "$NODE0_COMP" = "true" ]; then
  pass "Complete node: ready=true, composable=true"
else
  fail "Complete node: ready=$NODE0_READY, composable=$NODE0_COMP (expected true/true)"
fi

echo ""

# --- Step 4: Manifest stats ---
echo "Step 4: Manifest stats"

# preload-basic: 2 nodes, both ready and composable
TOTAL=$(jq -r '.stats.total' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "0")
READY_COUNT=$(jq -r '.stats.ready_count' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "0")
COMP_COUNT=$(jq -r '.stats.composable_count' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "0")
ALL_READY=$(jq -r '.stats.all_ready' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "false")
ALL_COMP=$(jq -r '.stats.all_composable' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "false")
if [ "$TOTAL" -eq 2 ] && [ "$READY_COUNT" -eq 2 ] && [ "$COMP_COUNT" -eq 2 ]; then
  pass "Basic manifest: total=2, ready=2, composable=2"
else
  fail "Basic manifest counts wrong: total=$TOTAL, ready=$READY_COUNT, composable=$COMP_COUNT"
fi

if [ "$ALL_READY" = "true" ] && [ "$ALL_COMP" = "true" ]; then
  pass "Basic manifest: all_ready=true, all_composable=true"
else
  fail "Basic manifest flags wrong: all_ready=$ALL_READY, all_composable=$ALL_COMP"
fi

# preload-blocked: 2 nodes, none ready
BLOCKED_TOTAL=$(jq -r '.stats.total' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "0")
BLOCKED_COUNT=$(jq -r '.stats.blocked_count' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "0")
BLOCKERS=$(jq -r '.stats.blockers | length' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "0")
if [ "$BLOCKED_TOTAL" -eq 2 ] && [ "$BLOCKED_COUNT" -eq 2 ] && [ "$BLOCKERS" -eq 2 ]; then
  pass "Blocked manifest: total=2, blocked=2, blockers=2"
else
  fail "Blocked manifest: total=$BLOCKED_TOTAL, blocked=$BLOCKED_COUNT, blockers=$BLOCKERS"
fi

echo ""

# --- Step 5: Inference enrichment ---
echo "Step 5: Inference enrichment"

# preload-basic fetch node: curl code should infer network=full
FETCH_NET=$(jq -r '.nodes[0].enriched.constraints.network.mode' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "")
if [ "$FETCH_NET" = "full" ]; then
  pass "curl code → network.mode=full"
else
  fail "curl code inference: network.mode=$FETCH_NET (expected full)"
fi

# preload-basic transform node: jq code should infer object schemas
TRANSFORM_INPUT=$(jq -r '.nodes[1].diagnosis.inferred.input_schema.type' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "")
TRANSFORM_OUTPUT=$(jq -r '.nodes[1].diagnosis.inferred.output_schema.type' /tmp/ncl-tn-preload-basic.json 2>/dev/null || echo "")
if [ "$TRANSFORM_INPUT" = "object" ] && [ "$TRANSFORM_OUTPUT" = "object" ]; then
  pass "jq code → inferred object input/output schemas"
else
  fail "jq inference: input=$TRANSFORM_INPUT, output=$TRANSFORM_OUTPUT (expected object/object)"
fi

echo ""

# --- Step 6: Ralph events ---
echo "Step 6: Ralph events"

EVENT_COUNT=$(jq '.ralph_events | length' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "0")
if [ "$EVENT_COUNT" -eq 2 ]; then
  pass "2 ralph events for 2 non-ready nodes"
else
  fail "Expected 2 ralph events, got $EVENT_COUNT"
fi

EVENT_TOPIC=$(jq -r '.ralph_events[0].topic' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "")
if [ "$EVENT_TOPIC" = "node.preload" ]; then
  pass "Ralph events use topic 'node.preload'"
else
  fail "Ralph event topic: $EVENT_TOPIC (expected node.preload)"
fi

# Verify events have payload content
HAS_PAYLOAD=$(jq -r '.ralph_events[0].payload' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "")
if [ -n "$HAS_PAYLOAD" ] && [ "$HAS_PAYLOAD" != "null" ]; then
  pass "Ralph events contain payload text"
else
  fail "Ralph events missing payload"
fi

echo ""

# --- Step 7: Fingerprint structure ---
echo "Step 7: Fingerprint stability"

# preload-blocked fingerprint should have both node names as keys
FP_KEYS=$(jq -r '.fingerprint | keys | join(",")' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "")
if echo "$FP_KEYS" | grep -q "bare-node" && echo "$FP_KEYS" | grep -q "partial-node"; then
  pass "Fingerprint keys match node names"
else
  fail "Fingerprint keys: $FP_KEYS (expected bare-node,partial-node)"
fi

# Fingerprint entries should have expected fields
FP_FIELDS=$(jq -r '.fingerprint["bare-node"] | keys | join(",")' /tmp/ncl-tn-preload-blocked.json 2>/dev/null || echo "")
if echo "$FP_FIELDS" | grep -q "state" && echo "$FP_FIELDS" | grep -q "composable" && echo "$FP_FIELDS" | grep -q "completeness"; then
  pass "Fingerprint entries have state, composable, completeness"
else
  fail "Fingerprint entry fields: $FP_FIELDS"
fi

# Incremental fingerprints should show progression
SNAP1_READY=$(jq -r '.fingerprints.snap_1.transform.ready' /tmp/ncl-tn-preload-incremental.json 2>/dev/null || echo "")
SNAP3_READY=$(jq -r '.fingerprints.snap_3.transform.ready' /tmp/ncl-tn-preload-incremental.json 2>/dev/null || echo "")
if [ "$SNAP1_READY" = "false" ] && [ "$SNAP3_READY" = "true" ]; then
  pass "Fingerprint progression: snap_1 not ready → snap_3 ready"
else
  fail "Fingerprint progression: snap_1=$SNAP1_READY, snap_3=$SNAP3_READY"
fi

echo ""

# --- Step 8: ValidChain integration ---
echo "Step 8: ValidChain integration"

# preload-compose exports a Pipeline — verify it has name and nodes
PIPE_NAME=$(jq -r '.name' /tmp/ncl-tn-preload-compose.json 2>/dev/null || echo "")
PIPE_NODES=$(jq '.nodes | length' /tmp/ncl-tn-preload-compose.json 2>/dev/null || echo "0")
if [ "$PIPE_NAME" = "fetch-transform" ] && [ "$PIPE_NODES" -eq 2 ]; then
  pass "compose_validated produces Pipeline: name=fetch-transform, nodes=2"
else
  fail "Pipeline: name=$PIPE_NAME, nodes=$PIPE_NODES (expected fetch-transform/2)"
fi

# Verify adjacent schemas are compatible (object → object)
OUT_TYPE=$(jq -r '.nodes[0].output_schema.type' /tmp/ncl-tn-preload-compose.json 2>/dev/null || echo "")
IN_TYPE=$(jq -r '.nodes[1].input_schema.type' /tmp/ncl-tn-preload-compose.json 2>/dev/null || echo "")
if [ "$OUT_TYPE" = "$IN_TYPE" ]; then
  pass "ValidChain: node[0].output ($OUT_TYPE) matches node[1].input ($IN_TYPE)"
else
  fail "ValidChain mismatch: output=$OUT_TYPE, input=$IN_TYPE"
fi

echo ""

# --- Step 9: Snapshot comparison ---
echo "Step 9: Snapshot comparison"

for snap in preload-basic preload-blocked preload-incremental; do
  if [ -f "$TESTS_DIR/snapshot-$snap.json" ]; then
    jq -S . "/tmp/ncl-tn-$snap.json" > "/tmp/tn-$snap-normalized.json"
    jq -S . "$TESTS_DIR/snapshot-$snap.json" > "/tmp/tn-$snap-snapshot-normalized.json"

    if diff -q "/tmp/tn-$snap-normalized.json" "/tmp/tn-$snap-snapshot-normalized.json" > /dev/null 2>&1; then
      pass "$snap matches committed snapshot"
    else
      fail "$snap differs from committed snapshot"
      echo "    Update: just tn-snapshot"
    fi
  else
    fail "No snapshot-$snap.json found — run: just tn-snapshot"
  fi
done

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
