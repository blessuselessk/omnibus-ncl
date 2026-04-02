# GitLab platform — users, labels, milestones, MRs, issues, discussions,
# notes, pipelines, jobs, artifacts
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity_sub "gitlab-user" "platform-user"
        [] [],

      B.entity "gitlab-label"
        [
          B.owns_key "name",
          B.owns_opt "color",
          B.owns_opt "description",
          B.owns_opt "priority",
        ]
        [B.plays "labeling" "label"],

      B.entity "gitlab-milestone"
        [
          B.owns_key "title",
          B.owns_opt "description",
          B.owns "issue-state",
          B.owns "created-at",
          B.owns_opt "updated-at",
        ]
        [B.plays "milestoning" "milestone"],

      B.entity "gitlab-merge-request"
        [
          B.owns "number",
          B.owns "title",
          B.owns_opt "body",
          B.owns "mr-state",
          B.owns "is-draft",
          B.owns "is-merged",
          B.owns_opt "merged-at",
          B.owns_opt "sha",
          B.owns_opt "additions",
          B.owns_opt "deletions",
          B.owns_opt "file-count",
          B.owns "squash-on-merge",
          B.owns "delete-source-branch",
          B.owns "is-confidential",
          B.owns "created-at",
          B.owns_opt "updated-at",
          B.owns_opt "closed-at",
        ]
        [
          B.plays "mr-authoring" "mr",
          B.plays "mr-branching" "mr-item",
          B.plays "merging" "merged-pr",
          B.plays "reviewing" "reviewed-pr",
          B.plays "labeling" "labeled-item",
          B.plays "milestoning" "milestoned-item",
          B.plays "assignment" "assigned-item",
          B.plays "commenting-action" "commented-on",
          B.plays "pipeline-association" "pipeline-mr",
          B.plays "discussion-on" "discussed-item",
        ],

      B.entity "gitlab-issue"
        [
          B.owns "number",
          B.owns "title",
          B.owns_opt "body",
          B.owns "issue-state",
          B.owns "is-confidential",
          B.owns_opt "weight",
          B.owns_opt "time-estimate",
          B.owns_opt "time-spent",
          B.owns "created-at",
          B.owns_opt "updated-at",
          B.owns_opt "closed-at",
        ]
        [
          B.plays "issue-authoring" "issue",
          B.plays "labeling" "labeled-item",
          B.plays "milestoning" "milestoned-item",
          B.plays "assignment" "assigned-item",
          B.plays "commenting-action" "commented-on",
          B.plays "discussion-on" "discussed-item",
        ],

      B.entity "gitlab-discussion"
        [
          B.owns_key "external-id",
          B.owns "is-resolved",
          B.owns_opt "resolved-at",
        ]
        [
          B.plays "discussion-on" "discussion",
          B.plays "discussion-noting" "discussion-owner",
        ],

      B.entity "gitlab-note"
        [
          B.owns "body",
          B.owns "created-at",
          B.owns_opt "updated-at",
          B.owns "is-system-note",
          B.owns "is-internal",
          B.owns "is-resolved",
          B.owns_opt "path",
          B.owns_opt "line-number",
        ]
        [
          B.plays "discussion-noting" "note",
          B.plays "commenting-action" "comment",
        ],

      B.entity "gitlab-pipeline"
        [
          B.owns "sha",
          B.owns "pipeline-status",
          B.owns_opt "pipeline-source",
          B.owns_opt "duration",
          B.owns_opt "coverage",
          B.owns "created-at",
          B.owns_opt "started-at",
          B.owns_opt "completed-at",
        ]
        [
          B.plays "pipeline-targeting" "pipeline",
          B.plays "pipeline-association" "pipeline-item",
          B.plays "pipeline-staging" "pipeline-owner",
        ],

      B.entity "gitlab-job"
        [
          B.owns "name",
          B.owns "job-status",
          B.owns_opt "duration",
          B.owns_opt "coverage",
          B.owns "allow-failure",
          B.owns_opt "failure-reason",
          B.owns "created-at",
          B.owns_opt "started-at",
          B.owns_opt "completed-at",
          B.owns_opt "url",
        ]
        [
          B.plays "pipeline-staging" "job",
          B.plays "artifact-containing" "job-owner",
        ],

      B.entity "gitlab-artifact"
        [
          B.owns "name",
          B.owns "size",
          B.owns_opt "content-type",
          B.owns_opt "expires-at",
        ]
        [B.plays "artifact-containing" "artifact"],
    ],

    relations = [
      # MR authored by user (GitLab)
      B.relation "mr-authoring"
        [B.relates_sub "mr-author" "platform-user", B.relates "mr"]
        [] [],

      # MR branch refs (GitLab)
      B.relation "mr-branching"
        [B.relates "mr-item", B.relates "source-branch", B.relates "target-branch"]
        [] [],

      # GitLab: discussion on MR/issue
      B.relation "discussion-on"
        [B.relates "discussion", B.relates "discussed-item"]
        [] [],

      # GitLab: notes in discussion
      B.relation "discussion-noting"
        [B.relates "discussion-owner", B.relates "note"]
        [] [],

      # GitLab: pipeline on commit
      B.relation "pipeline-targeting"
        [B.relates "pipeline", B.relates "pipeline-commit"]
        [] [],

      # GitLab: pipeline associated with MR
      B.relation "pipeline-association"
        [B.relates "pipeline-item", B.relates "pipeline-mr"]
        [] [],

      # GitLab: pipeline contains jobs via stages
      B.relation "pipeline-staging"
        [B.relates "pipeline-owner", B.relates "job"]
        [B.owns "name"]
        [],

      # GitLab: job contains artifacts
      B.relation "artifact-containing"
        [B.relates "job-owner", B.relates "artifact"]
        [] [],
    ],

    rules = [],
  }
}
