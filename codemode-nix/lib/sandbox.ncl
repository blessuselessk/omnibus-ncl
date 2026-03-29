# Sandbox profile generation for Nix tools
#
# Given a NixToolDescriptor, produces either a seatbelt profile (macOS)
# or a JSON-serializable registry entry with sandbox config.
let Seatbelt = import "../../sandbox/seatbelt/interface.ncl" in
let { profiles, .. } = import "security.ncl" in

{
  seatbelt_profile
    | doc "Generate macOS seatbelt profile for a Nix tool"
    | not_exported
    = fun tool =>
      let level_config = std.record.get tool.securityLevel profiles in
      let extra_paths =
        if std.record.has_field "allowedPaths" tool then
          tool.allowedPaths
        else
          []
      in
      Seatbelt.build {
        id = "nix-" ++ tool.flakeRef,
        backend = 'seatbelt,
        cmd = ["nix", "run", tool.flakeRef, "--"],
        network = level_config.network,
        fs = {
          mode = level_config.fs.mode,
          allowed_paths =
            level_config.fs.allowed_paths
            @ ["/nix"]
            @ extra_paths,
        },
      }
      |> Seatbelt.to_profile,

  registry_entry
    | doc "Build a full registry entry: tool metadata + sandbox config"
    | not_exported
    = fun tool_name =>
      fun tool =>
        let level_config = std.record.get tool.securityLevel profiles in
        let extra_paths =
          if std.record.has_field "allowedPaths" tool then
            tool.allowedPaths
          else
            []
        in
        {
          name = tool_name,
          flakeRef = tool.flakeRef,
          description = tool.description,
          securityLevel = tool.securityLevel,
          sandbox = {
            network = {
              enabled = level_config.network.enabled,
              mode =
                if level_config.network.mode == 'deny then "deny"
                else "full",
            },
            filesystem = {
              mode =
                if level_config.fs.mode == 'ro then "ro"
                else "whitelist",
              allowed_paths =
                level_config.fs.allowed_paths
                @ ["/nix"]
                @ extra_paths,
            },
            resources = {
              rlimit_as = level_config.resources.rlimit_as,
              rlimit_cpu = level_config.resources.rlimit_cpu,
              rlimit_nofile = level_config.resources.rlimit_nofile,
            },
            timeout =
              if std.record.has_field "timeout" tool then
                tool.timeout
              else
                level_config.resources.rlimit_cpu,
          },
          inputSchema = tool.inputSchema,
        },
}
