# Workspace configuration matching examples/workspace-chat
let { WorkspaceConfig, .. } = import "../lib/workspace.ncl" in

{
  namespace = "ws",
}
  | WorkspaceConfig
