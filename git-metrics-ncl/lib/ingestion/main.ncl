# Ingestion hub — re-exports all ingestion template modules
{
  repo = import "repo.ncl",
  commits = import "commits.ncl",
  refs = import "refs.ncl",
  files = import "files.ncl",
  github = import "github.ncl",
  gitlab = import "gitlab.ncl",

  # All templates flattened
  all =
    repo
    @ commits
    @ refs
    @ files
    @ github
    @ gitlab,
}
