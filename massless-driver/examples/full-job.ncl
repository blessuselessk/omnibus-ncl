# Full job exercising every field — used by workflow-export and manifest-export
let B = import "../lib/builders.ncl" in

B.job "integration-test" "myorg" "scripts/integration.sh"
& {
  visibility = 'private,
  runner = { label = "actuated-4cpu-16gb" },
  timeout_seconds = 600,
  auto_delete = true,
  secrets = {
    entries = [
      { name = "API_KEY" },
      { name = "DB_PASSWORD" },
      { name = "DOCKER_TOKEN" },
    ],
  },
  artifacts = {
    enabled = true,
    path = "./downloads",
    retention_days = 3,
  },
  release = {
    enabled = true,
    tag_prefix = "v-",
  },
  tailscale = {
    enabled = true,
    auth_key_secret = "TS_AUTHKEY",
    version = "v2",
  },
}
