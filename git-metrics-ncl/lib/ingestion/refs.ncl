# Ingestion: branches, tags (lightweight + annotated)
#
# Maps ExtractedRef → TypeDB inserts.
let B = import "../../../typedb-ncl/lib/builders.ncl" in
[
  B.query_commented
    "insert-branch"
    "Create branch and link to repository + HEAD commit"
    m%"
match
  $repo isa repository, has name $repo_name;
  $commit isa commit, has sha $head_sha;
insert
  $branch isa branch,
    has name $branch_name,
    has sha $head_sha,
    has is-active true,
    has is-protected false;
  (host-repo: $repo, hosted-branch: $branch) isa hosting;
  (branch-ref: $branch, branch-commit: $commit) isa branching;"%,

  B.query_commented
    "insert-remote-tracking"
    "Link local branch to remote branch tracking"
    m%"
match
  $local isa branch, has name $local_name;
  $remote_branch isa branch, has name $remote_branch_name;
  $remote isa remote, has name $remote_name;
insert
  (local-branch: $local, remote-branch: $remote_branch, tracked-remote: $remote)
    isa remote-tracking;"%,

  B.query_commented
    "insert-lightweight-tag"
    "Create lightweight tag pointing at a commit"
    m%"
match
  $commit isa commit, has sha $target_sha;
insert
  $tag isa lightweight-tag,
    has name $tag_name;
  (tag-object: $tag, tagged-object: $commit) isa tag-targeting;"%,

  B.query_commented
    "insert-annotated-tag"
    "Create annotated tag with tagger identity"
    m%"
match
  $commit isa commit, has sha $target_sha;
insert
  $tag isa annotated-tag,
    has sha $tag_sha,
    has name $tag_name,
    has message $tag_message;
  (tag-object: $tag, tagged-object: $commit) isa tag-targeting;
  $tagger isa contributor,
    has name $tagger_name,
    has email $tagger_email;
  (tagger: $tagger, tag: $tag) isa tagging-action,
    has created-at $tagger_date;"%,
]
