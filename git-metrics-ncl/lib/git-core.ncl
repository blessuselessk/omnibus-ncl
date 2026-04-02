# Git core — abstract types + git internal objects + object-graph relations
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      # Abstract: every git object has a sha
      B.entity_abstract "git-object"
        [B.owns_key "sha", B.owns_opt "size"]
        [B.plays "object-graph" "object"],

      # Abstract: person identity
      B.entity_abstract "identity"
        [B.owns "name", B.owns_key "email", B.owns_opt "timezone"]
        [
          B.plays "authoring" "author",
          B.plays "committing" "committer",
          B.plays "tagging-action" "tagger",
          B.plays "blaming" "blamed-author",
          B.plays "contribution" "contributor",
        ],

      # Abstract: platform user
      B.entity_abstract "platform-user"
        [
          B.owns_key "platform-id",
          B.owns "login",
          B.owns_opt "name",
          B.owns_opt "email",
          B.owns_opt "url",
          B.owns "is-bot",
          B.owns_opt "user-type",
        ]
        [
          B.plays "assignment" "assignee",
          B.plays "assignment" "assigner",
          B.plays "issue-authoring" "issue-author",
          B.plays "pr-authoring" "pr-author",
          B.plays "reviewing" "reviewer",
          B.plays "commenting-action" "commenter",
          B.plays "merging" "merger",
          B.plays "closing" "closer",
          B.plays "review-requesting" "requested-reviewer",
          B.plays "team-membership" "member",
          B.plays "deployment-action" "deployer",
          B.plays "releasing" "releaser",
          B.plays "dismissal" "dismisser",
          B.plays "alert-resolution" "resolver",
        ],

      # Abstract: issue-like trackable
      B.entity_abstract "trackable"
        [
          B.owns "number",
          B.owns "title",
          B.owns_opt "body",
          B.owns "created-at",
          B.owns_opt "updated-at",
          B.owns_opt "closed-at",
          B.owns "is-locked",
          B.owns_opt "lock-reason",
          B.owns "is-pinned",
        ]
        [
          B.plays "assignment" "assigned-item",
          B.plays "labeling" "labeled-item",
          B.plays "milestoning" "milestoned-item",
          B.plays "commenting-action" "commented-on",
          B.plays "closing" "closed-item",
          B.plays "reaction-on" "reacted-to",
          B.plays "timeline-recording" "timeline-subject",
        ],

      # Concrete git objects
      B.entity_sub "blob" "git-object"
        [B.owns_opt "content", B.owns "is-binary", B.owns_opt "content-type"]
        [],

      B.entity_sub "tree" "git-object"
        []
        [B.plays "tree-containment" "parent-tree"],

      B.entity_sub "commit" "git-object"
        [
          B.owns "message",
          B.owns "subject",
          B.owns_opt "body",
          B.owns_opt "encoding",
          B.owns "is-merge",
          B.owns_opt "signature-type",
          B.owns_opt "is-valid",
        ]
        [
          B.plays "parentage" "child",
          B.plays "parentage" "parent",
          B.plays "authoring" "authored-commit",
          B.plays "committing" "committed-commit",
          B.plays "commit-tree" "committing-commit",
          B.plays "branching" "branch-commit",
          B.plays "tag-targeting" "tagged-object",
          B.plays "ref-targeting" "targeted-commit",
          B.plays "diffing" "before-commit",
          B.plays "diffing" "after-commit",
          B.plays "file-snapshot" "snapshot-commit",
          B.plays "blaming" "blamed-commit",
          B.plays "cherry-picking" "picked-commit",
          B.plays "cherry-picking" "result-commit",
          B.plays "rebasing-step" "original-commit",
          B.plays "rebasing-step" "rewritten-commit",
          B.plays "reverting" "reverted-commit",
          B.plays "reverting" "revert-result",
          B.plays "stashing" "stash-commit",
          B.plays "check-targeting" "checked-commit",
          B.plays "status-checking" "status-checked-commit",
          B.plays "deployment-action" "deployed-commit",
          B.plays "pr-committing" "pr-commit",
          B.plays "pipeline-targeting" "pipeline-commit",
        ],

      B.entity_sub "annotated-tag" "git-object"
        [
          B.owns "name",
          B.owns_opt "message",
          B.owns_opt "signature-type",
          B.owns_opt "is-valid",
        ]
        [
          B.plays "tag-targeting" "tag-object",
          B.plays "tagging-action" "tag",
        ],

      B.entity "lightweight-tag"
        [B.owns_key "name"]
        [
          B.plays "tag-targeting" "tag-object",
          B.plays "ref-targeting" "ref",
        ],

      B.entity "reference"
        [
          B.owns "name",
          B.owns_key "ref-path",
          B.owns "ref-type",
          B.owns "sha",
          B.owns "is-symbolic",
          B.owns_opt "path",
        ]
        [B.plays "ref-targeting" "ref"],

      B.entity "reflog-entry"
        [
          B.owns "sha",
          B.owns "reflog-operation",
          B.owns "log-message",
          B.owns "index",
          B.owns "created-at",
        ]
        [
          B.plays "reflog-recording" "entry",
          B.plays "reflog-recording" "ref-owner",
        ],
    ],

    relations = [
      # Commit parentage (the core DAG)
      B.relation "parentage"
        [B.relates "child", B.relates "parent"]
        [] [],

      # Tree contains blobs/subtrees
      B.relation "tree-containment"
        [B.relates "parent-tree", B.relates "child-entry"]
        [B.owns "name", B.owns "file-mode", B.owns "entry-type"]
        [],

      # Commit points to its root tree
      B.relation "commit-tree"
        [B.relates "committing-commit", B.relates "root-tree"]
        [] [],

      # Tag points to target object
      B.relation "tag-targeting"
        [B.relates "tag-object", B.relates "tagged-object"]
        [] [],

      # Reference points to a commit
      B.relation "ref-targeting"
        [B.relates "ref", B.relates "targeted-commit"]
        [] [],

      # Generic object graph edge
      B.relation "object-graph"
        [B.relates "object"]
        [] [],

      # Reflog entries for a reference
      B.relation "reflog-recording"
        [B.relates "ref-owner", B.relates "entry"]
        [] [],
    ],

    rules = [],
  }
}
