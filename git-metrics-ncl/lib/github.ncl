# GitHub platform — users, teams, labels, milestones, issues, PRs, reviews,
# checks, releases, deployments, branch protection, codeowners, timeline
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity_sub "github-user" "platform-user"
        [B.owns_opt "url"]
        [],

      B.entity "github-team"
        [B.owns "name", B.owns_key "slug", B.owns_opt "description"]
        [
          B.plays "team-membership" "team",
          B.plays "review-requesting" "requested-team",
        ],

      B.entity "github-label"
        [B.owns_key "name", B.owns_opt "color", B.owns_opt "description", B.owns "is-default"]
        [B.plays "labeling" "label"],

      B.entity "github-milestone"
        [
          B.owns_key "number",
          B.owns "title",
          B.owns_opt "description",
          B.owns "issue-state",
          B.owns "created-at",
          B.owns_opt "updated-at",
          B.owns_opt "closed-at",
        ]
        [B.plays "milestoning" "milestone"],

      B.entity_sub "issue" "trackable"
        [
          B.owns "issue-state",
          B.owns_opt "issue-state-reason",
          B.owns "is-pinned",
        ]
        [B.plays "issue-authoring" "issue"],

      B.entity_sub "pull-request" "trackable"
        [
          B.owns "pr-state",
          B.owns "is-draft",
          B.owns "is-merged",
          B.owns_opt "merged-at",
          B.owns_opt "merge-method",
          B.owns_opt "sha",
          B.owns_opt "additions",
          B.owns_opt "deletions",
          B.owns_opt "file-count",
          B.owns_opt "mergeable-state",
        ]
        [
          B.plays "pr-authoring" "pr",
          B.plays "pr-branching" "pr-item",
          B.plays "pr-committing" "pr-item",
          B.plays "reviewing" "reviewed-pr",
          B.plays "review-requesting" "review-requested-pr",
          B.plays "merging" "merged-pr",
          B.plays "check-suite-association" "suite-pr",
        ],

      B.entity "review"
        [
          B.owns "review-state",
          B.owns_opt "body",
          B.owns "sha",
          B.owns "created-at",
          B.owns_opt "author-association",
        ]
        [
          B.plays "reviewing" "review-item",
          B.plays "dismissal" "dismissed-review",
        ],

      B.entity "review-comment"
        [
          B.owns "body",
          B.owns "path",
          B.owns_opt "line-number",
          B.owns_opt "start-line",
          B.owns_opt "diff-side",
          B.owns "sha",
          B.owns "is-outdated",
          B.owns "created-at",
          B.owns_opt "updated-at",
        ]
        [
          B.plays "commenting-action" "comment",
          B.plays "reaction-on" "reacted-to",
        ],

      B.entity "comment-entity"
        [
          B.owns "body",
          B.owns "created-at",
          B.owns_opt "updated-at",
          B.owns_opt "author-association",
        ]
        [
          B.plays "commenting-action" "comment",
          B.plays "reaction-on" "reacted-to",
        ],

      B.entity "check-suite"
        [
          B.owns "sha",
          B.owns "check-status",
          B.owns_opt "check-conclusion",
          B.owns "created-at",
          B.owns_opt "updated-at",
        ]
        [
          B.plays "check-suite-association" "suite",
          B.plays "check-suite-containing" "suite",
        ],

      B.entity "check-run"
        [
          B.owns "name",
          B.owns "sha",
          B.owns "check-status",
          B.owns_opt "check-conclusion",
          B.owns_opt "started-at",
          B.owns_opt "completed-at",
          B.owns_opt "url",
        ]
        [
          B.plays "check-targeting" "check",
          B.plays "check-suite-containing" "check-item",
        ],

      B.entity "check-annotation"
        [
          B.owns "path",
          B.owns "start-line",
          B.owns "end-line",
          B.owns_opt "start-column",
          B.owns_opt "end-column",
          B.owns "annotation-level",
          B.owns_opt "title",
          B.owns "message",
          B.owns_opt "raw-details",
        ]
        [B.plays "check-annotating" "annotation"],

      B.entity "status-check"
        [
          B.owns "context-name",
          B.owns "status-check-state",
          B.owns_opt "description",
          B.owns_opt "target-url",
          B.owns "created-at",
        ]
        [B.plays "status-checking" "status-check-item"],

      B.entity "release"
        [
          B.owns "tag-name",
          B.owns_opt "name",
          B.owns_opt "body",
          B.owns "is-draft",
          B.owns "is-prerelease",
          B.owns "is-latest",
          B.owns_opt "sha",
          B.owns "created-at",
          B.owns_opt "published-at",
        ]
        [
          B.plays "releasing" "released-item",
          B.plays "asset-containing" "release-owner",
        ],

      B.entity "release-asset"
        [
          B.owns "name",
          B.owns "content-type",
          B.owns "size",
          B.owns "download-count",
          B.owns "url",
          B.owns "created-at",
        ]
        [B.plays "asset-containing" "asset"],

      B.entity "deployment"
        [
          B.owns "sha",
          B.owns "name",
          B.owns_opt "description",
          B.owns "created-at",
          B.owns_opt "updated-at",
        ]
        [
          B.plays "deployment-action" "deployment-item",
          B.plays "deployment-statusing" "deployed-item",
        ],

      B.entity "deployment-status"
        [
          B.owns "deployment-state",
          B.owns_opt "description",
          B.owns_opt "url",
          B.owns "created-at",
        ]
        [B.plays "deployment-statusing" "status-entry"],

      B.entity "branch-protection-rule"
        [
          B.owns "pattern",
          B.owns "require-pull-request",
          B.owns_opt "count",
          B.owns "dismiss-stale-reviews",
          B.owns "require-code-owner-review",
          B.owns "require-signature",
          B.owns "require-linear-history",
          B.owns "require-conversation-resolution",
          B.owns "allow-force-push",
          B.owns "allow-deletion",
        ]
        [B.plays "protection" "rule"],

      B.entity "codeowner-rule"
        [B.owns "pattern", B.owns "path", B.owns "line-number"]
        [],

      B.entity "timeline-event"
        [B.owns "name", B.owns "created-at", B.owns_opt "sha"]
        [B.plays "timeline-recording" "event"],
    ],

    relations = [
      # Issue authored by user
      B.relation "issue-authoring"
        [B.relates "issue-author", B.relates "issue"]
        [] [],

      # PR authored by user
      B.relation "pr-authoring"
        [B.relates "pr-author", B.relates "pr"]
        [] [],

      # Assignment
      B.relation "assignment"
        [B.relates "assignee", B.relates "assigner", B.relates "assigned-item"]
        [] [],

      # Labeling
      B.relation "labeling"
        [B.relates "label", B.relates "labeled-item"]
        [] [],

      # Milestoning
      B.relation "milestoning"
        [B.relates "milestone", B.relates "milestoned-item"]
        [] [],

      # PR branch refs
      B.relation "pr-branching"
        [B.relates "pr-item", B.relates "base-branch", B.relates "head-branch"]
        [] [],

      # Commits in a PR
      B.relation "pr-committing"
        [B.relates "pr-item", B.relates "pr-commit"]
        [] [],

      # Reviewing a PR
      B.relation "reviewing"
        [B.relates "reviewer", B.relates "reviewed-pr", B.relates "review-item"]
        [] [],

      # Requesting a review
      B.relation "review-requesting"
        [B.relates "review-requested-pr", B.relates "requested-reviewer", B.relates "requested-team"]
        [] [],

      # Commenting
      B.relation "commenting-action"
        [B.relates "commenter", B.relates "commented-on", B.relates "comment"]
        [] [],

      # Reactions
      B.relation "reaction-on"
        [B.relates "reacted-to"]
        [B.owns "name", B.owns "count"]
        [],

      # Merging a PR
      B.relation "merging"
        [B.relates "merger", B.relates "merged-pr"]
        [] [],

      # Closing an issue/PR
      B.relation "closing"
        [B.relates "closer", B.relates "closed-item"]
        [] [],

      # Review dismissal
      B.relation "dismissal"
        [B.relates "dismisser", B.relates "dismissed-review"]
        [B.owns_opt "dismiss-reason"]
        [],

      # Check run targets a commit
      B.relation "check-targeting"
        [B.relates "check", B.relates "checked-commit"]
        [] [],

      # Check suite contains check runs
      B.relation "check-suite-containing"
        [B.relates "suite", B.relates "check-item"]
        [] [],

      # Check suite associated with PR
      B.relation "check-suite-association"
        [B.relates "suite", B.relates "suite-pr"]
        [] [],

      # Check annotation
      B.relation "check-annotating"
        [B.relates_sub "check-run" "check-run", B.relates "annotation"]
        [] [],

      # Status check on commit
      B.relation "status-checking"
        [B.relates "status-check-item", B.relates "status-checked-commit"]
        [] [],

      # Release by user
      B.relation "releasing"
        [B.relates "releaser", B.relates "released-item"]
        [] [],

      # Release contains assets
      B.relation "asset-containing"
        [B.relates "release-owner", B.relates "asset"]
        [] [],

      # Deployment
      B.relation "deployment-action"
        [B.relates "deployer", B.relates "deployment-item", B.relates "deployed-commit"]
        [] [],

      # Deployment status
      B.relation "deployment-statusing"
        [B.relates "deployed-item", B.relates "status-entry"]
        [] [],

      # Team membership
      B.relation "team-membership"
        [B.relates "team", B.relates "member"]
        [] [],

      # Timeline event on issue/PR
      B.relation "timeline-recording"
        [B.relates "timeline-subject", B.relates "event"]
        [] [],
    ],

    rules = [],
  }
}
