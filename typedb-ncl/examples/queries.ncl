# Common TypeQL queries for the bounty knowledge graph
#
# Usage: nickel export --format text typedb-ncl/examples/queries.ncl
let B = import "../lib/builders.ncl" in
let S = import "../lib/schema.ncl" in

let queries = [
  B.query_commented
    "active-bounties"
    "All active bounties with their target issues and amounts"
    "match\n    $bounty isa bounty, has bounty-id $id, has amount-cents $amount, has currency $cur, has bounty-status \"active\";\n    (placed-bounty: $bounty, target-issue: $issue) isa bounty-placement;\n    $issue has title $title, has url $url;\nfetch\n    $id; $amount; $cur; $title; $url;",
  B.query_commented
    "solver-leaderboard"
    "Users ranked by number of bounties completed"
    "match\n    $solver isa github-user, has login $login;\n    (solver: $solver, completed-bounty: $bounty) isa bounty-completion;\n    $bounty has amount-cents $amount;\nget $login, $amount;\ngroup $login;\naggregate count;",
  B.query_commented
    "bounty-resolution-chain"
    "Full chain: bounty → issue → PR → solver → payout"
    "match\n    $bounty isa bounty, has bounty-id $bid, has amount-cents $amount;\n    (placed-bounty: $bounty, target-issue: $issue) isa bounty-placement;\n    $issue has title $issue_title, has url $issue_url;\n    (solver: $solver, completed-bounty: $bounty, solving-pr: $pr) isa bounty-completion;\n    $solver has login $login;\n    $pr has url $pr_url;\nfetch\n    $bid; $amount; $issue_title; $issue_url; $login; $pr_url;",
  B.query_commented
    "repo-bounty-stats"
    "Total bounty value per repository"
    "match\n    $repo isa repository, has name $repo_name;\n    (host-repo: $repo, hosted-branch: $branch) isa hosting;\n    (branch-ref: $branch) isa branching;\n    (placed-bounty: $bounty, target-issue: $issue) isa bounty-placement;\n    $bounty has amount-cents $amount, has bounty-status \"active\";\n    (tracked-issue: $issue, repo: $repo) isa issue-tracking;\nget $repo_name, $amount;\ngroup $repo_name;\naggregate sum($amount);",
  B.query_commented
    "unclaimed-bounties"
    "Active bounties with no claim"
    "match\n    $bounty isa bounty, has bounty-id $id, has amount-cents $amount, has bounty-status \"active\";\n    (placed-bounty: $bounty, target-issue: $issue) isa bounty-placement;\n    $issue has title $title, has url $url;\n    not { (claimed-bounty: $bounty) isa bounty-claim; };\nfetch\n    $id; $amount; $title; $url;",
  B.query_commented
    "solver-earnings"
    "Total earnings per solver from completed payouts"
    "match\n    $solver isa github-user, has login $login;\n    (payee: $solver, paid-bounty: $bounty, payout-record: $payout) isa bounty-payout;\n    $payout has amount-cents $amount, has payout-status \"paid\";\nget $login, $amount;\ngroup $login;\naggregate sum($amount);",
]
in

S.render_queries queries
