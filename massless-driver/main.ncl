# massless-driver — GitHub Actions as a compute platform
#
# Nickel configuration surface for massless-driver (actions-batch).
# Models jobs, workflows, runners, secrets, artifacts, and platform targets.
#
# Usage:
#   nickel export --format json massless-driver/examples/workflow-export.ncl
#   nickel export --format json massless-driver/examples/manifest-export.ncl
{
  lib = import "lib/main.ncl",
}
