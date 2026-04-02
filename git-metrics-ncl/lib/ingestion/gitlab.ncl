# Ingestion: GitLab platform — MRs, pipelines, jobs, discussions
#
# Maps GitLab API responses → TypeDB inserts.
let B = import "../../../typedb-ncl/lib/builders.ncl" in
[
  B.query_commented
    "insert-gitlab-user"
    "Create GitLab user from API response"
    m%"
insert
  $user isa gitlab-user,
    has platform-id $id,
    has login $username,
    has name $display_name,
    has is-bot false;"%,

  B.query_commented
    "insert-merge-request"
    "Create MR from GitLab API (GET /projects/:id/merge_requests/:iid)"
    m%"
insert
  $mr isa gitlab-merge-request,
    has number $iid,
    has title $title,
    has body $description,
    has mr-state $state,
    has is-draft $is_draft,
    has is-merged $is_merged,
    has squash-on-merge $squash,
    has delete-source-branch $delete_branch,
    has is-confidential $is_confidential,
    has created-at $created_at,
    has updated-at $updated_at;"%,

  B.query_commented
    "insert-mr-authoring"
    "Link MR to its author"
    m%"
match
  $author isa gitlab-user, has login $author_username;
  $mr isa gitlab-merge-request, has number $iid;
insert
  (mr-author: $author, mr: $mr) isa mr-authoring;"%,

  B.query_commented
    "insert-mr-branches"
    "Link MR to source and target branches"
    m%"
match
  $mr isa gitlab-merge-request, has number $iid;
  $source isa branch, has name $source_branch;
  $target isa branch, has name $target_branch;
insert
  (mr-item: $mr, source-branch: $source, target-branch: $target) isa mr-branching;"%,

  B.query_commented
    "insert-gitlab-issue"
    "Create issue from GitLab API"
    m%"
insert
  $issue isa gitlab-issue,
    has number $iid,
    has title $title,
    has body $description,
    has issue-state $state,
    has is-confidential $is_confidential,
    has weight $weight,
    has time-estimate $time_estimate,
    has time-spent $time_spent,
    has created-at $created_at,
    has updated-at $updated_at;"%,

  B.query_commented
    "insert-pipeline"
    "Create pipeline from GitLab API (GET /projects/:id/pipelines/:id)"
    m%"
match
  $commit isa commit, has sha $sha;
insert
  $pipeline isa gitlab-pipeline,
    has sha $sha,
    has pipeline-status $status,
    has pipeline-source $source,
    has duration $duration_secs,
    has created-at $created_at,
    has started-at $started_at,
    has completed-at $finished_at;
  (pipeline: $pipeline, pipeline-commit: $commit) isa pipeline-targeting;"%,

  B.query_commented
    "insert-pipeline-mr-link"
    "Associate pipeline with a merge request"
    m%"
match
  $pipeline isa gitlab-pipeline, has sha $pipeline_sha;
  $mr isa gitlab-merge-request, has number $mr_iid;
insert
  (pipeline-item: $pipeline, pipeline-mr: $mr) isa pipeline-association;"%,

  B.query_commented
    "insert-job"
    "Create job within a pipeline stage"
    m%"
match
  $pipeline isa gitlab-pipeline, has sha $pipeline_sha;
insert
  $job isa gitlab-job,
    has name $job_name,
    has job-status $status,
    has duration $duration_secs,
    has allow-failure $allow_failure,
    has created-at $created_at,
    has started-at $started_at,
    has completed-at $finished_at;
  (pipeline-owner: $pipeline, job: $job) isa pipeline-staging,
    has name $stage_name;"%,

  B.query_commented
    "insert-job-artifact"
    "Attach artifact to a job"
    m%"
match
  $job isa gitlab-job, has name $job_name;
insert
  $artifact isa gitlab-artifact,
    has name $artifact_name,
    has size $size_bytes,
    has content-type $file_type,
    has expires-at $expire_at;
  (job-owner: $job, artifact: $artifact) isa artifact-containing;"%,

  B.query_commented
    "insert-discussion"
    "Create discussion on an MR or issue"
    m%"
match
  $mr isa gitlab-merge-request, has number $mr_iid;
insert
  $discussion isa gitlab-discussion,
    has external-id $discussion_id,
    has is-resolved $is_resolved;
  (discussion: $discussion, discussed-item: $mr) isa discussion-on;"%,

  B.query_commented
    "insert-note"
    "Create note within a discussion"
    m%"
match
  $discussion isa gitlab-discussion, has external-id $discussion_id;
  $author isa gitlab-user, has login $author_username;
insert
  $note isa gitlab-note,
    has body $body,
    has created-at $created_at,
    has is-system-note $is_system,
    has is-internal $is_internal,
    has is-resolved $is_resolved;
  (discussion-owner: $discussion, note: $note) isa discussion-noting;
  (commenter: $author, comment: $note) isa commenting-action;"%,
]
