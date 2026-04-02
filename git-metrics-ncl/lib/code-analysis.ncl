# Code analysis — language stats, complexity, dependencies, vulnerabilities, licenses
let B = import "../../typedb-ncl/lib/builders.ncl" in
{
  schema = {
    attributes = [],
    entities = [
      B.entity "language-stats"
        [
          B.owns_key "language",
          B.owns "file-count",
          B.owns "line-count",
          B.owns "size",
          B.owns "percentage",
        ]
        [],

      B.entity "code-complexity"
        [
          B.owns_key "path",
          B.owns "language",
          B.owns "score",
          B.owns "line-count",
          B.owns_opt "depth",
        ]
        [],

      B.entity "dependency"
        [
          B.owns "name",
          B.owns "version",
          B.owns "dependency-type",
          B.owns_opt "is-active",
          B.owns_opt "description",
        ]
        [
          B.plays "dependency-source" "dep",
          B.plays "vulnerability-affecting" "affected-dep",
        ],

      B.entity "vulnerability"
        [
          B.owns_opt "cve-id",
          B.owns "severity",
          B.owns_opt "cvss-score",
          B.owns "title",
          B.owns "description",
          B.owns_opt "version",
          B.owns_opt "fixed-at",
          B.owns_opt "url",
        ]
        [B.plays "vulnerability-affecting" "vuln"],

      B.entity "license"
        [
          B.owns_key "spdx-id",
          B.owns "name",
          B.owns_opt "url",
          B.owns_opt "confidence",
        ]
        [B.plays "license-detection" "detected-license"],
    ],

    relations = [
      # Dependency sourced from manifest file
      B.relation "dependency-source"
        [B.relates "dep", B.relates "manifest-file"]
        [] [],

      # Vulnerability affects dependency
      B.relation "vulnerability-affecting"
        [B.relates "vuln", B.relates "affected-dep"]
        [] [],

      # License detected in file
      B.relation "license-detection"
        [B.relates "detected-license", B.relates "license-file"]
        [B.owns_opt "confidence"]
        [],
    ],

    rules = [],
  }
}
