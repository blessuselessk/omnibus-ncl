# Contributors — contributor, contributor-alias + authorship/identity relations
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity_sub "contributor" "identity"
        [
          B.owns_opt "count",
          B.owns_opt "additions",
          B.owns_opt "deletions",
          B.owns_opt "file-count",
          B.owns_opt "created-at",
          B.owns_opt "percentage",
        ]
        [],

      B.entity "contributor-alias"
        [B.owns "name", B.owns "email"]
        [B.plays "identity-aliasing" "alias"],
    ],

    relations = [
      # Person authored a commit
      B.relation "authoring"
        [B.relates "author", B.relates "authored-commit"]
        [B.owns_opt "authored-at", B.owns_opt "timezone"]
        [],

      # Person committed (applied) a commit
      B.relation "committing"
        [B.relates "committer", B.relates "committed-commit"]
        [B.owns_opt "committed-at", B.owns_opt "timezone"]
        [],

      # Person created an annotated tag
      B.relation "tagging-action"
        [B.relates "tagger", B.relates "tag"]
        [B.owns_opt "created-at"]
        [],

      # Identity aliasing (same person, different name/email)
      B.relation "identity-aliasing"
        [B.relates_sub "primary" "identity", B.relates "alias"]
        [] [],

      # Contributor -> repository contribution
      B.relation "contribution"
        [B.relates "contributor", B.relates "contributed-to"]
        [
          B.owns_opt "count",
          B.owns_opt "additions",
          B.owns_opt "deletions",
          B.owns_opt "created-at",
        ]
        [],
    ],

    rules = [],
  }
}
