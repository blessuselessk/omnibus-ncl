# Ingestion: repository metadata, remotes
#
# Maps ExtractedRepoMeta → TypeDB inserts.
let B = import "../../../typedb-ncl/lib/builders.ncl" in
[
  B.query_commented
    "insert-repository"
    "Create or update repository from extracted metadata"
    m%"
match
  ?$repo isa repository, has name $repo_name;
insert
  $repo isa repository,
    has name $repo_name,
    has path $repo_path,
    has is-bare $is_bare,
    has is-shallow false;"%,

  B.query_commented
    "insert-remote"
    "Create remote and link to repository via hosting"
    m%"
match
  $repo isa repository, has name $repo_name;
insert
  $remote isa remote,
    has name $remote_name,
    has url $remote_url;
  (host-repo: $repo, hosted-remote: $remote) isa hosting;"%,
]
