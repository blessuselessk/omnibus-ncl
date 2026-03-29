# All 14 git commands from @cloudflare/shell/git gitTools()
let { GitToolSet, .. } = import "../lib/git.ncl" in

{
  clone = {
    description = "Clone a remote repository",
    params = ["options"],
    category = "remote",
  },
  status = {
    description = "Show working tree status",
    params = ["options"],
    category = "local",
  },
  add = {
    description = "Stage a file for commit",
    params = ["options"],
    category = "local",
  },
  rm = {
    description = "Remove a file from tracking",
    params = ["options"],
    category = "local",
  },
  commit = {
    description = "Create a commit with staged changes",
    params = ["options"],
    category = "local",
  },
  log = {
    description = "Show commit history",
    params = ["options"],
    category = "local",
  },
  branch = {
    description = "List, create, or delete branches",
    params = ["options"],
    category = "local",
  },
  checkout = {
    description = "Switch branches or restore files",
    params = ["options"],
    category = "local",
  },
  fetch = {
    description = "Download objects and refs from a remote",
    params = ["options"],
    category = "remote",
  },
  pull = {
    description = "Fetch and merge from a remote",
    params = ["options"],
    category = "remote",
  },
  push = {
    description = "Upload local commits to a remote",
    params = ["options"],
    category = "remote",
  },
  diff = {
    description = "Show changes between working tree and HEAD",
    params = ["options"],
    category = "local",
  },
  init = {
    description = "Initialize a new git repository",
    params = ["options"],
    category = "local",
  },
  remote = {
    description = "Manage remote repository connections",
    params = ["options"],
    category = "remote",
  },
}
  | GitToolSet
