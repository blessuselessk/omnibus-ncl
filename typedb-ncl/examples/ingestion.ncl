# TypeQL insert templates for Algora API → TypeDB ingestion
#
# Shows how Algora API responses map to TypeDB entities/relations.
# Placeholders use $var syntax matching TypeDB insert patterns.
#
# Usage: nickel export --format text typedb-ncl/examples/ingestion.ncl
let B = import "../lib/builders.ncl" in
let S = import "../lib/schema.ncl" in

let templates = [
  B.query_commented
    "insert-bounty"
    "Create a bounty from Algora API response (POST /api/bounties)"
    "insert\n    $bounty isa bounty,\n        has bounty-id $bounty_id,\n        has amount-cents $amount,\n        has currency $currency,\n        has bounty-status \"active\";",
  B.query_commented
    "insert-bounty-placement"
    "Link bounty to placer (org) and target issue"
    "match\n    $placer isa github-user, has login $org_login;\n    $issue isa issue, has url $issue_url;\n    $bounty isa bounty, has bounty-id $bounty_id;\ninsert\n    (placer: $placer, placed-bounty: $bounty, target-issue: $issue) isa bounty-placement,\n        has created-at $now;",
  B.query_commented
    "insert-bounty-claim"
    "Record that a user claimed a bounty"
    "match\n    $claimant isa github-user, has login $solver_login;\n    $bounty isa bounty, has bounty-id $bounty_id;\ninsert\n    (claimant: $claimant, claimed-bounty: $bounty) isa bounty-claim,\n        has claimed-at $now;",
  B.query_commented
    "insert-bounty-completion"
    "Record bounty solved via merged PR"
    "match\n    $solver isa github-user, has login $solver_login;\n    $bounty isa bounty, has bounty-id $bounty_id;\n    $pr isa pull-request, has url $pr_url;\ninsert\n    (solver: $solver, completed-bounty: $bounty, solving-pr: $pr) isa bounty-completion,\n        has completed-at $now;\n    $bounty has bounty-status \"completed\";",
  B.query_commented
    "insert-payout"
    "Record payment for a completed bounty"
    "match\n    $solver isa github-user, has login $solver_login;\n    $bounty isa bounty, has bounty-id $bounty_id;\ninsert\n    $payout isa payout,\n        has amount-cents $amount,\n        has currency $currency,\n        has payout-status \"paid\",\n        has paid-at $now;\n    (paid-bounty: $bounty, payout-record: $payout, payee: $solver) isa bounty-payout,\n        has paid-at $now;",
]
in

S.render_queries templates
