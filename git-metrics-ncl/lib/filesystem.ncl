# Filesystem & working directory — file-entry, directory-entry, gitignore/gitattribute rules
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity "file-entry"
        [
          B.owns_key "path",
          B.owns "name",
          B.owns_opt "sha",
          B.owns_opt "file-mode",
          B.owns_opt "size",
          B.owns_opt "language",
          B.owns_opt "encoding",
          B.owns_opt "is-binary",
          B.owns "is-symlink",
          B.owns "is-submodule",
          B.owns "is-gitignored",
          B.owns_opt "file-status",
        ]
        [
          B.plays "tree-containment" "child-entry",
          B.plays "file-snapshot" "snapshot-file",
          B.plays "file-change" "changed-file",
          B.plays "blaming" "blamed-file",
          B.plays "ownership" "owned-file",
          B.plays "dependency-source" "manifest-file",
          B.plays "license-detection" "license-file",
        ],

      B.entity "directory-entry"
        [
          B.owns_key "path",
          B.owns "name",
          B.owns_opt "file-count",
          B.owns_opt "size",
        ]
        [
          B.plays "tree-containment" "parent-tree",
          B.plays "tree-containment" "child-entry",
        ],

      B.entity "gitignore-rule"
        [B.owns "pattern", B.owns "path", B.owns "line-number", B.owns "is-default"]
        [],

      B.entity "gitattribute-rule"
        [B.owns "pattern", B.owns "path"]
        [],
    ],

    relations = [],

    rules = [],
  }
}
