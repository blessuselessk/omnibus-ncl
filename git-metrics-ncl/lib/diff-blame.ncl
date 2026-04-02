# Diff, blame & patch — diff objects + diff/blame relations
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity "diff"
        [B.owns "additions", B.owns "deletions", B.owns "file-count", B.owns "is-merge"]
        [B.plays "diffing" "diff-result"],

      B.entity "diff-patch"
        [
          B.owns "path",
          B.owns "file-status",
          B.owns "is-binary",
          B.owns_opt "file-mode",
          B.owns_opt "similarity",
          B.owns "additions",
          B.owns "deletions",
          B.owns_opt "language",
        ]
        [
          B.plays "diff-containing" "contained-patch",
          B.plays "hunk-containing" "patch-owner",
        ],

      B.entity "diff-hunk"
        [
          B.owns "old-start",
          B.owns "old-count",
          B.owns "new-start",
          B.owns "new-count",
          B.owns_opt "section-header",
        ]
        [
          B.plays "hunk-containing" "contained-hunk",
          B.plays "line-containing" "hunk-owner",
        ],

      B.entity "diff-line"
        [B.owns "diff-line-type", B.owns "content", B.owns_opt "line-number"]
        [B.plays "line-containing" "contained-line"],

      B.entity "blame-result"
        [B.owns "path", B.owns "sha"]
        [B.plays "blaming" "blame-output"],

      B.entity "blame-line"
        [B.owns "line-number", B.owns "content", B.owns "is-boundary"]
        [B.plays "blaming" "blamed-line"],
    ],

    relations = [
      # Diff between two commits
      B.relation "diffing"
        [B.relates "before-commit", B.relates "after-commit", B.relates "diff-result"]
        [] [],

      # Diff contains patches
      B.relation "diff-containing"
        [B.relates_sub "diff-owner" "diff", B.relates "contained-patch"]
        [] [],

      # Patch contains hunks
      B.relation "hunk-containing"
        [B.relates "patch-owner", B.relates "contained-hunk"]
        [] [],

      # Hunk contains lines
      B.relation "line-containing"
        [B.relates "hunk-owner", B.relates "contained-line"]
        [] [],

      # File at a specific commit
      B.relation "file-snapshot"
        [B.relates "snapshot-commit", B.relates "snapshot-file"]
        [] [],

      # Blame attribution
      B.relation "blaming"
        [
          B.relates "blamed-file",
          B.relates "blamed-commit",
          B.relates "blamed-author",
          B.relates "blamed-line",
          B.relates "blame-output",
        ]
        [] [],

      # File ownership (derived from blame)
      B.relation "ownership"
        [B.relates "owned-file", B.relates_sub "owner" "identity"]
        [B.owns_opt "percentage", B.owns_opt "line-count"]
        [],
    ],

    rules = [],
  }
}
