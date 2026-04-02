# Ingestion: commits, contributors, authoring, parentage
#
# Maps ExtractedCommit → TypeDB inserts.
# Commits are the backbone — author/committer identity and parentage DAG.
let B = import "../../../typedb-ncl/lib/builders.ncl" in
[
  B.query_commented
    "insert-commit"
    "Create commit entity from extracted commit data"
    m%"
insert
  $commit isa commit,
    has sha $sha,
    has message $message,
    has subject $subject,
    has body $body,
    has is-merge $is_merge;"%,

  B.query_commented
    "insert-commit-author"
    "Create contributor and link as commit author"
    m%"
match
  $commit isa commit, has sha $sha;
insert
  $author isa contributor,
    has name $author_name,
    has email $author_email;
  (author: $author, authored-commit: $commit) isa authoring,
    has authored-at $author_date,
    has timezone $author_tz;"%,

  B.query_commented
    "insert-commit-committer"
    "Create contributor and link as committer (when different from author)"
    m%"
match
  $commit isa commit, has sha $sha;
insert
  $committer isa contributor,
    has name $committer_name,
    has email $committer_email;
  (committer: $committer, committed-commit: $commit) isa committing,
    has committed-at $committer_date,
    has timezone $committer_tz;"%,

  B.query_commented
    "insert-parentage"
    "Link child commit to parent commit (core DAG edge)"
    m%"
match
  $child isa commit, has sha $child_sha;
  $parent isa commit, has sha $parent_sha;
insert
  (child: $child, parent: $parent) isa parentage;"%,

  B.query_commented
    "insert-contribution"
    "Link contributor to repository via branch → commit chain"
    m%"
match
  $contributor isa contributor, has email $email;
  (author: $contributor, authored-commit: $commit) isa authoring;
  (branch-ref: $branch, branch-commit: $commit) isa branching;
  (host-repo: $repo, hosted-branch: $branch) isa hosting;
insert
  (contributor: $contributor, contributed-to: $repo) isa contribution,
    has created-at $now;"%,
]
