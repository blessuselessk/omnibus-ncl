# Ingestion: GitHub platform — issues, PRs, reviews, labels, deployments
#
# Maps GitHub API responses → TypeDB inserts.
let B = import "../../../typedb-ncl/lib/builders.ncl" in
[
  # -- Users & Teams --

  B.query_commented
    "insert-github-user"
    "Create GitHub user from API response (GET /users/:login)"
    m%"
insert
  $user isa github-user,
    has platform-id $id,
    has login $login,
    has name $display_name,
    has url $profile_url,
    has is-bot $is_bot;"%,

  B.query_commented
    "insert-github-team"
    "Create team and membership"
    m%"
insert
  $team isa github-team,
    has name $team_name,
    has slug $team_slug,
    has description $team_desc;"%,

  B.query_commented
    "insert-team-membership"
    "Link user to team"
    m%"
match
  $user isa github-user, has login $login;
  $team isa github-team, has slug $team_slug;
insert
  (team: $team, member: $user) isa team-membership;"%,

  # -- Issues --

  B.query_commented
    "insert-issue"
    "Create issue from GitHub API (GET /repos/:owner/:repo/issues/:number)"
    m%"
insert
  $issue isa issue,
    has number $issue_number,
    has title $title,
    has body $body,
    has issue-state $state,
    has is-locked $is_locked,
    has is-pinned $is_pinned,
    has created-at $created_at,
    has updated-at $updated_at;"%,

  B.query_commented
    "insert-issue-authoring"
    "Link issue to its author"
    m%"
match
  $author isa github-user, has login $author_login;
  $issue isa issue, has number $issue_number;
insert
  (issue-author: $author, issue: $issue) isa issue-authoring;"%,

  # -- Pull Requests --

  B.query_commented
    "insert-pull-request"
    "Create PR from GitHub API (GET /repos/:owner/:repo/pulls/:number)"
    m%"
insert
  $pr isa pull-request,
    has number $pr_number,
    has title $title,
    has body $body,
    has pr-state $state,
    has is-draft $is_draft,
    has is-merged $is_merged,
    has is-locked false,
    has is-pinned false,
    has created-at $created_at,
    has updated-at $updated_at;"%,

  B.query_commented
    "insert-pr-authoring"
    "Link PR to its author"
    m%"
match
  $author isa github-user, has login $author_login;
  $pr isa pull-request, has number $pr_number;
insert
  (pr-author: $author, pr: $pr) isa pr-authoring;"%,

  B.query_commented
    "insert-pr-branches"
    "Link PR to its base and head branches"
    m%"
match
  $pr isa pull-request, has number $pr_number;
  $base isa branch, has name $base_branch;
  $head isa branch, has name $head_branch;
insert
  (pr-item: $pr, base-branch: $base, head-branch: $head) isa pr-branching;"%,

  B.query_commented
    "insert-pr-commit"
    "Link commit to its pull request"
    m%"
match
  $pr isa pull-request, has number $pr_number;
  $commit isa commit, has sha $sha;
insert
  (pr-item: $pr, pr-commit: $commit) isa pr-committing;"%,

  B.query_commented
    "insert-pr-merge"
    "Record PR merge event"
    m%"
match
  $merger isa github-user, has login $merger_login;
  $pr isa pull-request, has number $pr_number;
insert
  (merger: $merger, merged-pr: $pr) isa merging;
  $pr has is-merged true,
    has merged-at $merged_at,
    has merge-method $merge_method;"%,

  # -- Reviews --

  B.query_commented
    "insert-review"
    "Create review from GitHub API (GET /repos/:owner/:repo/pulls/:number/reviews)"
    m%"
match
  $reviewer isa github-user, has login $reviewer_login;
  $pr isa pull-request, has number $pr_number;
insert
  $review isa review,
    has review-state $state,
    has body $body,
    has sha $commit_sha,
    has created-at $submitted_at;
  (reviewer: $reviewer, reviewed-pr: $pr, review-item: $review) isa reviewing;"%,

  B.query_commented
    "insert-review-comment"
    "Create inline review comment on a PR"
    m%"
match
  $commenter isa github-user, has login $commenter_login;
  $pr isa pull-request, has number $pr_number;
insert
  $comment isa review-comment,
    has body $body,
    has path $file_path,
    has line-number $line,
    has diff-side $side,
    has sha $commit_sha,
    has is-outdated false,
    has created-at $created_at;
  (commenter: $commenter, commented-on: $pr, comment: $comment)
    isa commenting-action;"%,

  # -- Labels & Milestones --

  B.query_commented
    "insert-label"
    "Create label and apply to issue/PR"
    m%"
match
  $item isa trackable, has number $item_number;
insert
  $label isa github-label,
    has name $label_name,
    has color $label_color,
    has is-default false;
  (label: $label, labeled-item: $item) isa labeling;"%,

  B.query_commented
    "insert-milestone"
    "Create milestone and link to issue/PR"
    m%"
match
  $item isa trackable, has number $item_number;
insert
  $milestone isa github-milestone,
    has number $milestone_number,
    has title $milestone_title,
    has issue-state $milestone_state,
    has created-at $created_at;
  (milestone: $milestone, milestoned-item: $item) isa milestoning;"%,

  # -- Checks & Status --

  B.query_commented
    "insert-check-suite"
    "Create check suite linked to a PR"
    m%"
match
  $pr isa pull-request, has number $pr_number;
insert
  $suite isa check-suite,
    has sha $head_sha,
    has check-status $status,
    has created-at $created_at;
  (suite: $suite, suite-pr: $pr) isa check-suite-association;"%,

  B.query_commented
    "insert-check-run"
    "Create check run inside a suite, linked to commit"
    m%"
match
  $suite isa check-suite, has sha $suite_sha;
  $commit isa commit, has sha $commit_sha;
insert
  $check isa check-run,
    has name $check_name,
    has sha $commit_sha,
    has check-status $status,
    has check-conclusion $conclusion,
    has started-at $started_at,
    has completed-at $completed_at;
  (suite: $suite, check-item: $check) isa check-suite-containing;
  (check: $check, checked-commit: $commit) isa check-targeting;"%,

  # -- Releases --

  B.query_commented
    "insert-release"
    "Create release from GitHub API (GET /repos/:owner/:repo/releases)"
    m%"
match
  $releaser isa github-user, has login $releaser_login;
insert
  $release isa release,
    has tag-name $tag_name,
    has name $release_name,
    has body $release_body,
    has is-draft $is_draft,
    has is-prerelease $is_prerelease,
    has is-latest $is_latest,
    has sha $target_sha,
    has created-at $created_at,
    has published-at $published_at;
  (releaser: $releaser, released-item: $release) isa releasing;"%,

  B.query_commented
    "insert-release-asset"
    "Attach asset to a release"
    m%"
match
  $release isa release, has tag-name $tag_name;
insert
  $asset isa release-asset,
    has name $asset_name,
    has content-type $content_type,
    has size $size_bytes,
    has download-count $downloads,
    has url $download_url,
    has created-at $uploaded_at;
  (release-owner: $release, asset: $asset) isa asset-containing;"%,

  # -- Deployments --

  B.query_commented
    "insert-deployment"
    "Create deployment from GitHub API"
    m%"
match
  $deployer isa github-user, has login $deployer_login;
  $commit isa commit, has sha $sha;
insert
  $deployment isa deployment,
    has sha $sha,
    has name $environment,
    has description $description,
    has created-at $created_at;
  (deployer: $deployer, deployment-item: $deployment, deployed-commit: $commit)
    isa deployment-action;"%,

  B.query_commented
    "insert-deployment-status"
    "Record deployment status update"
    m%"
match
  $deployment isa deployment, has sha $deploy_sha, has name $environment;
insert
  $status isa deployment-status,
    has deployment-state $state,
    has description $description,
    has url $log_url,
    has created-at $created_at;
  (deployed-item: $deployment, status-entry: $status) isa deployment-statusing;"%,
]
