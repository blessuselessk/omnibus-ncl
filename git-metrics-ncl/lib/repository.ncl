# Repository structure — repo, remote, branch, submodule, hook, worktree
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity "repository"
        [
          B.owns_key "name",
          B.owns "path",
          B.owns "is-bare",
          B.owns "is-shallow",
          B.owns_opt "description",
        ]
        [
          B.plays "hosting" "host-repo",
          B.plays "submodule-inclusion" "parent-repo",
        ],

      B.entity "remote"
        [B.owns "name", B.owns "url", B.owns_opt "path"]
        [
          B.plays "hosting" "hosted-remote",
          B.plays "remote-tracking" "tracked-remote",
        ],

      B.entity "branch"
        [
          B.owns "name",
          B.owns "sha",
          B.owns "is-active",
          B.owns "is-protected",
          B.owns_opt "description",
          B.owns_opt "ahead-by",
          B.owns_opt "behind-by",
        ]
        [
          B.plays "hosting" "hosted-branch",
          B.plays "branching" "branch-ref",
          B.plays "remote-tracking" "local-branch",
          B.plays "remote-tracking" "remote-branch",
          B.plays "pr-branching" "base-branch",
          B.plays "pr-branching" "head-branch",
          B.plays "mr-branching" "source-branch",
          B.plays "mr-branching" "target-branch",
          B.plays "protection" "protected-branch",
        ],

      B.entity "submodule"
        [
          B.owns "name",
          B.owns "path",
          B.owns "url",
          B.owns "sha",
          B.owns_opt "submodule-update-strategy",
          B.owns_opt "submodule-ignore-rule",
          B.owns "is-active",
        ]
        [B.plays "submodule-inclusion" "included-submodule"],

      B.entity "hook"
        [
          B.owns "hook-name",
          B.owns "path",
          B.owns "is-active",
          B.owns "is-executable",
          B.owns_opt "language",
          B.owns_opt "content",
        ]
        [B.plays "hosting" "hosted-hook"],

      B.entity "worktree"
        [
          B.owns_key "path",
          B.owns "sha",
          B.owns "is-locked",
          B.owns_opt "lock-reason",
          B.owns "is-bare",
        ]
        [
          B.plays "hosting" "hosted-worktree",
          B.plays "branching" "branch-ref",
        ],
    ],

    relations = [
      # Repository hosts branches, tags, remotes, hooks, worktrees
      B.relation "hosting"
        [
          B.relates "host-repo",
          B.relates "hosted-branch",
          B.relates "hosted-remote",
          B.relates "hosted-hook",
          B.relates "hosted-worktree",
        ]
        [] [],

      # Branch points at a commit
      B.relation "branching"
        [B.relates "branch-ref", B.relates "branch-commit"]
        [] [],

      # Local branch tracks remote branch
      B.relation "remote-tracking"
        [B.relates "local-branch", B.relates "remote-branch", B.relates "tracked-remote"]
        [] [],

      # Submodule inclusion
      B.relation "submodule-inclusion"
        [B.relates "parent-repo", B.relates "included-submodule"]
        [] [],

      # Branch protection
      B.relation "protection"
        [B.relates "protected-branch", B.relates "rule"]
        [] [],
    ],

    rules = [],
  }
}
