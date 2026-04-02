# Ingestion: file tree, per-commit file changes, blame
#
# Maps ExtractedFile, ExtractedFileChange, ExtractedBlameBlock → TypeDB inserts.
let B = import "../../../typedb-ncl/lib/builders.ncl" in
[
  B.query_commented
    "insert-file"
    "Create file entry from HEAD tree listing"
    m%"
insert
  $file isa file-entry,
    has path $file_path,
    has name $file_name,
    has sha $blob_sha,
    has file-mode $mode,
    has size $size,
    has is-symlink false,
    has is-submodule false,
    has is-gitignored false;"%,

  B.query_commented
    "insert-file-snapshot"
    "Link file to the commit where it was snapshotted"
    m%"
match
  $commit isa commit, has sha $commit_sha;
  $file isa file-entry, has path $file_path;
insert
  (snapshot-commit: $commit, snapshot-file: $file) isa file-snapshot;"%,

  B.query_commented
    "insert-file-change"
    "Record per-commit file modification (add/delete/modify/rename)"
    m%"
match
  $commit isa commit, has sha $commit_sha;
insert
  $diff isa diff,
    has additions $additions,
    has deletions $deletions,
    has file-count 1,
    has is-merge false;
  (before-commit: $parent, after-commit: $commit, diff-result: $diff) isa diffing;
  $patch isa diff-patch,
    has path $file_path,
    has file-status $status,
    has is-binary false,
    has additions $additions,
    has deletions $deletions;
  (diff-owner: $diff, contained-patch: $patch) isa diff-containing;"%,

  B.query_commented
    "insert-file-rename"
    "Record file rename with similarity score"
    m%"
match
  $old_file isa file-entry, has path $old_path;
  $new_file isa file-entry, has path $new_path;
  $commit isa commit, has sha $commit_sha;
insert
  $patch isa diff-patch,
    has path $new_path,
    has file-status "R",
    has is-binary false,
    has similarity $similarity,
    has additions 0,
    has deletions 0;"%,

  B.query_commented
    "insert-blame-block"
    "Record blame attribution: file lines → commit → author"
    m%"
match
  $file isa file-entry, has path $file_path;
  $commit isa commit, has sha $commit_sha;
  $author isa contributor, has email $author_email;
insert
  $blame isa blame-result,
    has path $file_path,
    has sha $commit_sha;
  (blamed-file: $file, blamed-commit: $commit, blamed-author: $author,
   blame-output: $blame) isa blaming;"%,

  B.query_commented
    "insert-blame-line"
    "Record individual blame line attribution"
    m%"
match
  $file isa file-entry, has path $file_path;
  $commit isa commit, has sha $commit_sha;
  $author isa contributor, has email $author_email;
insert
  $line isa blame-line,
    has line-number $line_num,
    has content $line_content,
    has is-boundary $is_boundary;
  (blamed-file: $file, blamed-commit: $commit, blamed-author: $author,
   blamed-line: $line) isa blaming;"%,

  B.query_commented
    "insert-file-ownership"
    "Derive file ownership from blame majority (percentage of lines)"
    m%"
match
  $file isa file-entry, has path $file_path;
  $author isa contributor, has email $author_email;
insert
  (owned-file: $file, owner: $author) isa ownership,
    has percentage $ownership_pct,
    has line-count $owned_lines;"%,
]
