# Export wrapper — validates frontend workspace against WiredWorkspace contract.
# Enforces both edge validity and orphan detection.
# Usage: nickel export --format json prose-ncl/examples/workspace-export.ncl
let { Workspace, WiredWorkspace, .. } = import "../lib/workspace.ncl" in
let workspace = import "frontend-workspace.ncl" in

workspace | Workspace | WiredWorkspace
