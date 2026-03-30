#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for prose-ncl Nickel definitions
#
# Run from omnibus-ncl root: bash prose-ncl/tests/validate.sh

NCL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TESTS_DIR="$NCL_DIR/tests"
PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== prose-ncl validation ==="
echo ""

# --- Step 1: Nickel export validation ---
echo "Step 1: Nickel export validation"

for f in workspace-export single-skill graph-export; do
  if nickel export --format json "$NCL_DIR/examples/$f.ncl" > "/tmp/ncl-prose-$f.json" 2>/dev/null; then
    pass "$f.ncl exports as JSON"
  else
    fail "$f.ncl export failed"
  fi
done

echo ""

# --- Step 2: Workspace structure validation ---
echo "Step 2: Workspace structure validation"

HAS_ROOT=$(jq 'has("root_instructions")' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo false)
if [ "$HAS_ROOT" = "true" ]; then
  pass "Workspace has root_instructions"
else
  fail "Workspace missing root_instructions"
fi

INSTRUCTION_COUNT=$(jq '.instructions | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$INSTRUCTION_COUNT" -ge 1 ]; then
  pass "Workspace has $INSTRUCTION_COUNT instructions"
else
  fail "Workspace has no instructions"
fi

CHATMODE_COUNT=$(jq '.chatmodes | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$CHATMODE_COUNT" -ge 1 ]; then
  pass "Workspace has $CHATMODE_COUNT chatmodes"
else
  fail "Workspace has no chatmodes"
fi

PROMPT_COUNT=$(jq '.prompts | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$PROMPT_COUNT" -ge 1 ]; then
  pass "Workspace has $PROMPT_COUNT prompts"
else
  fail "Workspace has no prompts"
fi

SPEC_COUNT=$(jq '.specs | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$SPEC_COUNT" -ge 1 ]; then
  pass "Workspace has $SPEC_COUNT specs"
else
  fail "Workspace has no specs"
fi

MEMORY_COUNT=$(jq '.memories | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$MEMORY_COUNT" -ge 1 ]; then
  pass "Workspace has $MEMORY_COUNT memories"
else
  fail "Workspace has no memories"
fi

CONTEXT_COUNT=$(jq '.contexts | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$CONTEXT_COUNT" -ge 1 ]; then
  pass "Workspace has $CONTEXT_COUNT contexts"
else
  fail "Workspace has no contexts"
fi

SKILL_COUNT=$(jq '.skills | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$SKILL_COUNT" -ge 1 ]; then
  pass "Workspace has $SKILL_COUNT skills"
else
  fail "Workspace has no skills"
fi

AGENT_COUNT=$(jq '.agents | length' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo 0)
if [ "$AGENT_COUNT" -ge 1 ]; then
  pass "Workspace has $AGENT_COUNT agents"
else
  fail "Workspace has no agents"
fi

echo ""

# --- Step 3: Primitive field validation ---
echo "Step 3: Primitive field validation"

ALL_INSTRUCTIONS_VALID=$(jq '[.instructions[] | has("apply_to") and has("description") and has("body")] | all' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo false)
if [ "$ALL_INSTRUCTIONS_VALID" = "true" ]; then
  pass "All instructions have required fields"
else
  fail "Some instructions missing required fields"
fi

ALL_CHATMODES_VALID=$(jq '[.chatmodes[] | has("description") and has("tools") and has("body")] | all' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo false)
if [ "$ALL_CHATMODES_VALID" = "true" ]; then
  pass "All chatmodes have required fields"
else
  fail "Some chatmodes missing required fields"
fi

ALL_PROMPTS_VALID=$(jq '[.prompts[] | has("description") and has("body")] | all' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo false)
if [ "$ALL_PROMPTS_VALID" = "true" ]; then
  pass "All prompts have required fields"
else
  fail "Some prompts missing required fields"
fi

ALL_SPECS_VALID=$(jq '[.specs[] | has("title") and has("body")] | all' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo false)
if [ "$ALL_SPECS_VALID" = "true" ]; then
  pass "All specs have required fields"
else
  fail "Some specs missing required fields"
fi

ALL_SKILLS_VALID=$(jq '[.skills[] | has("name") and has("description")] | all' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo false)
if [ "$ALL_SKILLS_VALID" = "true" ]; then
  pass "All skills have required fields"
else
  fail "Some skills missing required fields"
fi

ALL_AGENTS_VALID=$(jq '[.agents[] | has("description") and has("body")] | all' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo false)
if [ "$ALL_AGENTS_VALID" = "true" ]; then
  pass "All agents have required fields"
else
  fail "Some agents missing required fields"
fi

echo ""

# --- Step 4: Skill contract validation ---
echo "Step 4: Skill contract validation"

SKILL_NAME=$(jq -r '.name' /tmp/ncl-prose-single-skill.json 2>/dev/null || echo "")
if [ "$SKILL_NAME" = "deploy-preview" ]; then
  pass "Single skill name is deploy-preview"
else
  fail "Single skill name is '$SKILL_NAME' (expected deploy-preview)"
fi

HAS_REFS=$(jq 'has("references") and (.references | length > 0)' /tmp/ncl-prose-single-skill.json 2>/dev/null || echo false)
if [ "$HAS_REFS" = "true" ]; then
  pass "Single skill has references"
else
  fail "Single skill missing references"
fi

HAS_SCRIPTS=$(jq 'has("scripts") and (.scripts | length > 0)' /tmp/ncl-prose-single-skill.json 2>/dev/null || echo false)
if [ "$HAS_SCRIPTS" = "true" ]; then
  pass "Single skill has scripts"
else
  fail "Single skill missing scripts"
fi

echo ""

# --- Step 5: Enum tag validation ---
echo "Step 5: Enum tag validation"

PROMPT_MODES=$(jq '[.prompts[] | select(has("mode")) | .mode] | unique' /tmp/ncl-prose-workspace-export.json 2>/dev/null || echo "[]")
VALID_MODES=true
for mode in $(echo "$PROMPT_MODES" | jq -r '.[]' 2>/dev/null); do
  case "$mode" in
    agent|ask|edit) ;;
    *) VALID_MODES=false ;;
  esac
done
if [ "$VALID_MODES" = "true" ]; then
  pass "All prompt modes are valid enum tags"
else
  fail "Invalid prompt mode found: $PROMPT_MODES"
fi

echo ""

# --- Step 6: Composability graph validation ---
echo "Step 6: Composability graph validation"

EDGE_COUNT=$(jq '.valid_edges | length' /tmp/ncl-prose-graph-export.json 2>/dev/null || echo 0)
if [ "$EDGE_COUNT" -eq 23 ]; then
  pass "Graph has 23 valid edges"
else
  fail "Graph has $EDGE_COUNT valid edges (expected 23)"
fi

INVALID_COUNT=$(jq '.invalid_edges | length' /tmp/ncl-prose-graph-export.json 2>/dev/null || echo 0)
if [ "$INVALID_COUNT" -eq 7 ]; then
  pass "Graph has 7 invalid edge rules"
else
  fail "Graph has $INVALID_COUNT invalid edge rules (expected 7)"
fi

LOOP_COUNT=$(jq '.feedback_loops | length' /tmp/ncl-prose-graph-export.json 2>/dev/null || echo 0)
if [ "$LOOP_COUNT" -eq 2 ]; then
  pass "Graph has 2 feedback loops"
else
  fail "Graph has $LOOP_COUNT feedback loops (expected 2)"
fi

TIER_COUNT=$(jq '.tiers | keys | length' /tmp/ncl-prose-graph-export.json 2>/dev/null || echo 0)
if [ "$TIER_COUNT" -eq 3 ]; then
  pass "Graph has 3 tiers"
else
  fail "Graph has $TIER_COUNT tiers (expected 3)"
fi

echo ""

# --- Step 7: Snapshot comparison ---
echo "Step 7: Snapshot comparison"

if [ -f "$TESTS_DIR/snapshot.json" ]; then
  jq -S . /tmp/ncl-prose-workspace-export.json > /tmp/prose-ncl-normalized.json
  jq -S . "$TESTS_DIR/snapshot.json" > /tmp/prose-snapshot-normalized.json

  if diff -q /tmp/prose-ncl-normalized.json /tmp/prose-snapshot-normalized.json > /dev/null 2>&1; then
    pass "Workspace export matches committed snapshot"
  else
    fail "Workspace export differs from committed snapshot"
    echo "    Run: diff <(jq -S . /tmp/ncl-prose-workspace-export.json) <(jq -S . $TESTS_DIR/snapshot.json)"
    echo "    Update: just snapshot"
  fi
else
  fail "No snapshot.json found — run: just snapshot"
fi

echo ""

# --- Summary ---
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
