# Standalone skill example — validates against the Skill contract.
# Usage: nickel export --format json prose-ncl/examples/single-skill.ncl
let { Skill, .. } = import "../lib/skill.ncl" in

{
  name = "deploy-preview",
  description = "Deploy a preview environment for the current branch",
  references = [
    "references/cloudflare-pages.md",
    "references/deploy-config.md",
  ],
  scripts = [
    "scripts/deploy-preview.sh",
  ],
}
  | Skill
