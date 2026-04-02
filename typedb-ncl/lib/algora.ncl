# Algora Bounty layer — extends git-metrics/schema.tql
#
# Adds bounty tracking on top of the git-metrics knowledge graph.
# References existing entities (github-user, issue, pull-request) by name.
# TypeDB define is additive — load git-metrics schema first, then this.
#
# Follows git-metrics naming conventions:
#   - Hyphens in names (bounty-status, not bounty_status)
#   - Timestamps as sub-attributes of abstract `timestamp`
#   - Relations own temporal attributes
let B = import "builders.ncl" in

{
  # New attributes not in git-metrics
  algora_attributes = [
    B.attr "bounty-id" 'string,
    B.attr "amount-cents" 'long,
    B.attr "currency" 'string,
    B.attr "bounty-status" 'string,
    B.attr "payout-status" 'string,
    # New timestamps following git-metrics convention (sub timestamp)
    B.attr_sub "claimed-at" "timestamp",
    B.attr_sub "paid-at" "timestamp",
  ],

  # New entities
  algora_entities = [
    B.entity
      "bounty"
      [
        B.owns_key "bounty-id",
        B.owns "amount-cents",
        B.owns "currency",
        B.owns "bounty-status",
      ]
      [
        B.plays "bounty-placement" "placed-bounty",
        B.plays "bounty-claim" "claimed-bounty",
        B.plays "bounty-completion" "completed-bounty",
        B.plays "bounty-payout" "paid-bounty",
      ],
    B.entity
      "payout"
      [
        B.owns "amount-cents",
        B.owns "currency",
        B.owns "payout-status",
        B.owns "paid-at",
      ]
      [B.plays "bounty-payout" "payout-record"],
  ],

  # Wiring: add bounty roles to existing git-metrics entities.
  # TypeDB define is additive — these extend, not redefine.
  wiring_entities = [
    # github-user can place, claim, solve, and receive bounties
    B.entity
      "github-user"
      []
      [
        B.plays "bounty-placement" "placer",
        B.plays "bounty-claim" "claimant",
        B.plays "bounty-completion" "solver",
        B.plays "bounty-payout" "payee",
      ],

    # issues can be bounty targets
    B.entity
      "issue"
      []
      [B.plays "bounty-placement" "target-issue"],

    # PRs can solve bounties
    B.entity
      "pull-request"
      []
      [B.plays "bounty-completion" "solving-pr"],
  ],

  # New relations
  algora_relations = [
    # who placed it, on what issue
    B.relation
      "bounty-placement"
      [B.relates "placer", B.relates "placed-bounty", B.relates "target-issue"]
      [B.owns "created-at"]
      [],

    # who is working on it
    B.relation
      "bounty-claim"
      [B.relates "claimant", B.relates "claimed-bounty"]
      [B.owns "claimed-at"]
      [],

    # who solved it, via what PR
    B.relation
      "bounty-completion"
      [B.relates "solver", B.relates "completed-bounty", B.relates "solving-pr"]
      [B.owns "completed-at"]
      [],

    # payment tracking
    B.relation
      "bounty-payout"
      [B.relates "paid-bounty", B.relates "payout-record", B.relates "payee"]
      [B.owns "paid-at"]
      [],
  ],

  # Inference rules — bridge bounty layer to git-metrics knowledge
  algora_rules = [
    B.rule_commented
      "infer-bounty-contributor"
      "A bounty solver contributed to the repository hosting the issue"
      "    $solver isa github-user;\n    (solver: $solver, completed-bounty: $bounty) isa bounty-completion;\n    (placer: $placer, placed-bounty: $bounty, target-issue: $issue) isa bounty-placement;\n    (host-repo: $repo, hosted-branch: $branch) isa hosting;\n    (branch-ref: $branch, branch-commit: $commit) isa branching;\n    (resolving-pr: $pr, resolved-issue: $issue) isa pr-resolution;"
      "    (contributor: $solver, contributed-to: $repo) isa contribution;",
    B.rule_commented
      "infer-funded-pr"
      "A PR resolving an issue with a bounty is bounty-funded"
      "    $pr isa pull-request;\n    (resolving-pr: $pr, resolved-issue: $issue) isa pr-resolution;\n    (placed-bounty: $bounty, target-issue: $issue) isa bounty-placement;\n    $bounty has bounty-status \"active\";"
      "    (solver: $author, completed-bounty: $bounty, solving-pr: $pr) isa bounty-completion;",
  ],

  # Assembled as a SchemaDef for the meta layer
  algora_schema = {
    attributes = algora_attributes,
    entities = algora_entities @ wiring_entities,
    relations = algora_relations,
    rules = algora_rules,
  },
}
