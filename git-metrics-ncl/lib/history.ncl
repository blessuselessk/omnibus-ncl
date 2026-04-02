# History operations — merge, rebase, cherry-pick, revert, stash, bisect
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity "merge-operation"
        [
          B.owns "merge-strategy",
          B.owns "is-merged",
          B.owns_opt "message",
        ]
        [B.plays "merging-op" "merge-op"],

      B.entity "merge-conflict"
        [
          B.owns "path",
          B.owns "conflict-type",
          B.owns "is-resolved",
          B.owns_opt "resolution-strategy",
          B.owns_opt "content",
        ]
        [
          B.plays "merging-op" "merge-conflict-item",
          B.plays "rebasing-step" "step-conflict",
          B.plays "cherry-picking" "pick-conflict",
          B.plays "reverting" "revert-conflict",
        ],

      B.entity "rebase-operation"
        [B.owns "is-active", B.owns_opt "step-number"]
        [B.plays "rebasing" "rebase-op"],

      B.entity "rebase-step"
        [B.owns "rebase-action", B.owns "step-number", B.owns_opt "message"]
        [B.plays "rebasing-step" "step"],

      B.entity "cherry-pick-operation"
        [] [B.plays "cherry-picking" "pick-op"],

      B.entity "revert-operation"
        [] [B.plays "reverting" "revert-op"],

      B.entity "stash-entry"
        [B.owns "index", B.owns "message", B.owns "created-at", B.owns_opt "stash-scope"]
        [B.plays "stashing" "stash"],

      B.entity "bisect-session"
        [B.owns "is-active", B.owns_opt "step-number"]
        [B.plays "bisecting" "session"],

      B.entity "bisect-step"
        [B.owns "bisect-verdict", B.owns "created-at"]
        [B.plays "bisecting" "step", B.plays "bisecting" "tested-commit"],
    ],

    relations = [
      # Merge operation
      B.relation "merging-op"
        [B.relates "merge-op", B.relates "merge-conflict-item"]
        [] [],

      # Rebase operation contains steps
      B.relation "rebasing"
        [B.relates "rebase-op", B.relates_sub "onto-commit" "commit"]
        [] [],

      # Rebase step details
      B.relation "rebasing-step"
        [
          B.relates "step",
          B.relates "original-commit",
          B.relates "rewritten-commit",
          B.relates "step-conflict",
        ]
        [] [],

      # Cherry-pick
      B.relation "cherry-picking"
        [
          B.relates "pick-op",
          B.relates "picked-commit",
          B.relates "result-commit",
          B.relates "pick-conflict",
        ]
        [] [],

      # Revert
      B.relation "reverting"
        [
          B.relates "revert-op",
          B.relates "reverted-commit",
          B.relates "revert-result",
          B.relates "revert-conflict",
        ]
        [] [],

      # Stash
      B.relation "stashing"
        [B.relates "stash", B.relates "stash-commit"]
        [] [],

      # Bisect
      B.relation "bisecting"
        [B.relates "session", B.relates "step", B.relates "tested-commit"]
        [] [],
    ],

    rules = [],
  }
}
