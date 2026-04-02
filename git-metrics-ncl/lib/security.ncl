# Security — security alerts, secret scanning alerts
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity "security-alert"
        [
          B.owns "alert-type",
          B.owns "alert-state",
          B.owns "severity",
          B.owns_opt "cvss-score",
          B.owns_opt "cve-id",
          B.owns "title",
          B.owns "description",
          B.owns_opt "path",
          B.owns_opt "url",
          B.owns "created-at",
          B.owns_opt "updated-at",
          B.owns_opt "fixed-at",
          B.owns_opt "dismissed-at",
          B.owns_opt "dismiss-reason",
        ]
        [B.plays "alert-resolution" "alert"],

      B.entity "secret-scanning-alert"
        [
          B.owns "alert-state",
          B.owns "secret-type",
          B.owns_opt "path",
          B.owns_opt "sha",
          B.owns_opt "line-number",
          B.owns "created-at",
          B.owns_opt "resolved-at",
        ]
        [B.plays "alert-resolution" "alert"],
    ],

    relations = [
      # Security alert resolution
      B.relation "alert-resolution"
        [B.relates "alert", B.relates "resolver"]
        [] [],
    ],

    rules = [],
  }
}
