# Adapters — lift existing subproject configs into Envelope
#
# Each adapter takes a config from another omnibus-ncl subproject
# and returns an Envelope. This is the bridge between the
# domain-specific contracts and the generic composition layer.
{
  from_sandbox
    | doc m%"
      Lift a sandbox config into an Envelope.

      Maps sandbox network/fs/resource settings to Envelope constraints.

      # Examples

      ```nickel
      from_sandbox "jq-sandbox" 'nsjail {
        network = { mode = 'deny },
        fs = { mode = 'ro, allowed_paths = ["/tmp"] },
        resources = { max_memory_mb = 64, max_cpu_seconds = 10 },
        command = "jq '.name' input.json",
      }
      ```
    "%
    | not_exported
    = fun _name =>
      fun _backend =>
        fun _config =>
          {
            name = _name,
            payload = {
              kind = 'script,
              script =
                if std.record.has_field "command" _config then
                  _config.command
                else
                  null,
              description =
                if std.record.has_field "description" _config then
                  _config.description
                else
                  null,
            },
            constraints = {
              network =
                if std.record.has_field "network" _config then
                  _config.network
                else
                  {},
              fs =
                if std.record.has_field "fs" _config then
                  _config.fs
                else
                  {},
              resources =
                if std.record.has_field "resources" _config then
                  _config.resources
                else
                  {},
            },
            target = {
              kind = 'sandbox,
              sandbox_backend = _backend,
            },
          },

  from_workflow
    | doc m%"
      Lift a massless-driver Job into an Envelope.

      Maps Job fields to Envelope payload/constraints/target.

      # Examples

      ```nickel
      from_workflow {
        name = "build",
        owner = "myorg",
        script = "build.sh",
        runner = { label = "ubuntu-latest" },
        secrets = { entries = [{ name = "TOKEN" }] },
        timeout_seconds = 600,
      }
      ```
    "%
    | not_exported
    = fun _job =>
      {
        name = _job.name,
        payload =
          if std.record.has_field "nix" _job && std.record.has_field "flake_ref" _job.nix then
            {
              kind = 'nix_flake,
              flake_ref = _job.nix.flake_ref,
            }
          else
            {
              kind = 'script,
              script =
                if std.record.has_field "script" _job then
                  _job.script
                else
                  null,
            },
        constraints = {
          network = { mode = 'full },
          fs = { mode = 'rw },
          resources = {
            timeout_seconds =
              if std.record.has_field "timeout_seconds" _job then
                _job.timeout_seconds
              else
                360,
          },
          secrets =
            if std.record.has_field "secrets" _job
            && std.record.has_field "entries" _job.secrets then
              std.array.map (fun s => s.name) _job.secrets.entries
            else
              [],
        },
        target = {
          kind = 'workflow,
          runner_label =
            if std.record.has_field "runner" _job
            && std.record.has_field "label" _job.runner then
              _job.runner.label
            else
              "ubuntu-latest",
        },
      },

  from_tool
    | doc m%"
      Lift a codemode ToolDescriptor into an Envelope.

      The tool runs locally by default (target = 'local).
      Wrap with `nest` to place it inside a sandbox or workflow.

      # Examples

      ```nickel
      from_tool "add" "Add two numbers" {
        type = "object",
        properties = { a = { type = "number" }, b = { type = "number" } },
        required = ["a", "b"],
      }
      ```
    "%
    | not_exported
    = fun _name =>
      fun _desc =>
        fun _schema =>
          {
            name = _name,
            payload = {
              kind = 'tool,
              tool_name = _name,
              description = _desc,
              input_schema = _schema,
            },
            constraints = {
              network = { mode = 'deny },
              fs = { mode = 'ro },
            },
            target = { kind = 'local },
          },

  from_nix_tool
    | doc m%"
      Lift a codemode-nix NixToolDescriptor into an Envelope.

      Maps security level to constraint presets:
      - "strict"  → deny network, read-only fs, minimal resources
      - "network" → full network, read-only fs, medium resources
      - "io"      → deny network, whitelist fs, large resources
      - "full"    → full network, whitelist fs, large resources
    "%
    | not_exported
    = fun _name =>
      fun _nix_tool =>
        let level =
          if std.record.has_field "securityLevel" _nix_tool then
            _nix_tool.securityLevel
          else
            "strict"
        in
        let net_mode =
          if level == "network" || level == "full" then
            'full
          else
            'deny
        in
        let fs_mode =
          if level == "io" || level == "full" then
            'whitelist
          else
            'ro
        in
        let res =
          if level == "strict" then
            { max_memory_mb = 64, max_cpu_seconds = 10, max_file_descriptors = 32, timeout_seconds = 30 }
          else if level == "network" then
            { max_memory_mb = 256, max_cpu_seconds = 60, max_file_descriptors = 128, timeout_seconds = 300 }
          else
            { max_memory_mb = 512, max_cpu_seconds = 300, max_file_descriptors = 256, timeout_seconds = 600 }
        in
        {
          name = _name,
          payload = {
            kind = 'nix_flake,
            flake_ref = _nix_tool.flakeRef,
            description =
              if std.record.has_field "description" _nix_tool then
                _nix_tool.description
              else
                null,
          },
          constraints = {
            network = {
              mode = net_mode,
              allowed_hosts =
                if std.record.has_field "allowedHosts" _nix_tool then
                  _nix_tool.allowedHosts
                else
                  [],
            },
            fs = {
              mode = fs_mode,
              allowed_paths =
                if std.record.has_field "allowedPaths" _nix_tool then
                  _nix_tool.allowedPaths
                else
                  [],
            },
            resources = res,
          },
          target = { kind = 'sandbox, sandbox_backend = 'nsjail },
        },

  from_mcp_server
    | doc m%"
      Lift an MCP server config into an Envelope.

      The server itself is the payload; individual tools
      can be nested as inner envelopes.
    "%
    | not_exported
    = fun _server_config =>
      {
        name =
          if std.record.has_field "name" _server_config then
            _server_config.name
          else
            "mcp-server",
        payload = {
          kind = 'mcp_tool,
          tool_name =
            if std.record.has_field "name" _server_config then
              _server_config.name
            else
              "mcp-server",
        },
        constraints = {
          network = { mode = 'localhost },
          fs = { mode = 'ro },
        },
        target = {
          kind = 'mcp_server,
          server_name =
            if std.record.has_field "name" _server_config then
              _server_config.name
            else
              "mcp-server",
        },
      },
}
