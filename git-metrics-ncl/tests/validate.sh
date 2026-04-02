#!/usr/bin/env bash
set -euo pipefail

# validate.sh — Tests for git-metrics-ncl Nickel definitions
#
# Run from omnibus-ncl root: bash git-metrics-ncl/tests/validate.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Fall back to nix run if nickel/jq not on PATH
if command -v nickel > /dev/null 2>&1; then
  NICKEL="nickel"
else
  NICKEL="nix run nixpkgs#nickel --"
fi
if command -v jq > /dev/null 2>&1; then
  JQ="jq"
else
  JQ="nix run nixpkgs#jq --"
fi

PASS=0
FAIL=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

echo "=== git-metrics-ncl validation ==="

# Step 1: Export schema as JSON
echo ""
echo "Step 1: JSON export"
if $NICKEL export --format json "$PROJECT_DIR/examples/schema-json.ncl" > /tmp/ncl-gm-schema.json 2>/tmp/ncl-gm-err.txt; then
  pass "schema JSON export"
else
  fail "schema JSON export: $(cat /tmp/ncl-gm-err.txt)"
fi

# Step 2: Export schema as TypeQL
echo ""
echo "Step 2: TypeQL export"
if $NICKEL export --format text "$PROJECT_DIR/examples/schema-export.ncl" > /tmp/ncl-gm-schema.tql 2>/tmp/ncl-gm-err.txt; then
  pass "schema TypeQL export"
else
  fail "schema TypeQL export: $(cat /tmp/ncl-gm-err.txt)"
fi

# Step 3: Export full (base + algora)
echo ""
echo "Step 3: Full export (base + algora)"
if $NICKEL export --format text "$PROJECT_DIR/examples/full-export.ncl" > /tmp/ncl-gm-full.tql 2>/tmp/ncl-gm-err.txt; then
  pass "full export"
else
  fail "full export: $(cat /tmp/ncl-gm-err.txt)"
fi

# Step 4: Validate counts
echo ""
echo "Step 4: Schema counts"

ATTR_COUNT=$($JQ '.attributes | length' /tmp/ncl-gm-schema.json)
ENTITY_COUNT=$($JQ '.entities | length' /tmp/ncl-gm-schema.json)
REL_COUNT=$($JQ '.relations | length' /tmp/ncl-gm-schema.json)
RULE_COUNT=$($JQ '.rules | length' /tmp/ncl-gm-schema.json)

[ "$ATTR_COUNT" -ge 160 ] && pass "attributes: $ATTR_COUNT (>= 160)" || fail "attributes: $ATTR_COUNT (expected >= 160)"
[ "$ENTITY_COUNT" -ge 70 ] && pass "entities: $ENTITY_COUNT (>= 70)" || fail "entities: $ENTITY_COUNT (expected >= 70)"
[ "$REL_COUNT" -ge 60 ] && pass "relations: $REL_COUNT (>= 60)" || fail "relations: $REL_COUNT (expected >= 60)"
[ "$RULE_COUNT" -eq 4 ] && pass "rules: $RULE_COUNT (== 4)" || fail "rules: $RULE_COUNT (expected 4)"

# Step 5: Check key entities exist
echo ""
echo "Step 5: Key entities"
for ent in commit repository pull-request contributor github-user gitlab-pipeline; do
  if $JQ -e ".entities[] | select(.name == \"$ent\")" /tmp/ncl-gm-schema.json > /dev/null 2>&1; then
    pass "entity '$ent' exists"
  else
    fail "entity '$ent' missing"
  fi
done

# Step 6: Check key relations exist
echo ""
echo "Step 6: Key relations"
for rel in parentage authoring hosting diffing blaming reviewing; do
  if $JQ -e ".relations[] | select(.name == \"$rel\")" /tmp/ncl-gm-schema.json > /dev/null 2>&1; then
    pass "relation '$rel' exists"
  else
    fail "relation '$rel' missing"
  fi
done

# Step 7: Check abstract entities
echo ""
echo "Step 7: Abstract entities"
for ent in git-object identity platform-user trackable; do
  if $JQ -e ".entities[] | select(.name == \"$ent\") | select(.annotations | index(\"abstract\"))" /tmp/ncl-gm-schema.json > /dev/null 2>&1; then
    pass "entity '$ent' is abstract"
  else
    fail "entity '$ent' not abstract"
  fi
done

# Step 8: Check full export includes Algora extension
echo ""
echo "Step 8: Full export includes Algora"
if grep -q "bounty-placement" /tmp/ncl-gm-full.tql; then
  pass "full export contains Algora bounty relations"
else
  fail "full export missing Algora bounty relations"
fi

# Step 9: Ingestion template exports
echo ""
echo "Step 9: Ingestion templates"
for tpl in ingest-git ingest-github ingest-gitlab ingest-all; do
  if $NICKEL export --format text "$PROJECT_DIR/examples/$tpl.ncl" > /dev/null 2>/tmp/ncl-gm-err.txt; then
    pass "$tpl export"
  else
    fail "$tpl export: $(cat /tmp/ncl-gm-err.txt)"
  fi
done

INGEST_COUNT=$($NICKEL export --format text "$PROJECT_DIR/examples/ingest-all.ncl" 2>/dev/null | grep -c "^# Query:")
[ "$INGEST_COUNT" -ge 40 ] && pass "ingestion templates: $INGEST_COUNT (>= 40)" || fail "ingestion templates: $INGEST_COUNT (expected >= 40)"

# Step 10: Snapshot comparison
echo ""
echo "Step 10: Snapshot comparison"
SNAPSHOT="$PROJECT_DIR/tests/snapshot.json"
if [ -f "$SNAPSHOT" ]; then
  $JQ -S . /tmp/ncl-gm-schema.json > /tmp/ncl-gm-normalized.json
  if diff -q /tmp/ncl-gm-normalized.json "$SNAPSHOT" > /dev/null 2>&1; then
    pass "snapshot matches"
  else
    fail "snapshot differs (run: just gm-snapshot)"
  fi
else
  fail "snapshot file not found (run: just gm-snapshot)"
fi

# Summary
echo ""
TOTAL=$((PASS + FAIL))
echo "=== Results: $PASS/$TOTAL passed ==="
[ $FAIL -eq 0 ] || exit 1
