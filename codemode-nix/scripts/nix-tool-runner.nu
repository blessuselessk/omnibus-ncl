#!/usr/bin/env nu
# nix-tool-runner.nu — Execute a Nix package tool inside a sandbox
#
# Usage:
#   nu nix-tool-runner.nu <registry.json> <tool-name> [args...]
#
# The registry JSON is produced by:
#   nickel export --format json codemode-nix/examples/nix-registry.ncl > registry.json
def main [registry: path, tool_name: string, ...args: string] {
    let work_dir = ($env | get -o NIX_TOOL_WORK_DIR | default "/tmp/nix-tool-work")
    let profile_dir = ($env | get -o NIX_TOOL_PROFILE_DIR | default "/tmp/nix-tool-profiles")
    mkdir $work_dir
    mkdir $profile_dir
    let reg = (open $registry)
    if not ($tool_name in ($reg | columns)) {
        let available = ($reg | columns | str join ", ")
        error make {
            msg: $"unknown tool '($tool_name)'. available: ($available)"
        }
    }
    let tool = ($reg | get $tool_name)
    let flake_ref = $tool.flakeRef
    let network = $tool.sandbox.network.enabled
    let timeout_secs = $tool.sandbox.timeout
    match (sys host | get name) {
        "Darwin" => {
            let profile_path = $"($profile_dir)/($tool_name).sb"
            let network_rules = if $network { ["(allow network-outbound)", "(allow network-inbound)"] } else { ["(deny network-outbound)", "(deny network-inbound)"] }
            let fs_rules = ($tool.sandbox.filesystem.allowed_paths | each {|p|
        $'(allow file-read-data file-write-data (subpath "($p)"))'
      })
            let profile = (
                ["(version 1)", "(allow default)"] | append $network_rules | append $fs_rules | str join "\n"
            )
            $profile | save -f $profile_path
            timeout $"($timeout_secs)s" sandbox-exec -f $profile_path nix run $flake_ref -- ...$args
        }
        "Linux" => {
            let rlimit_as = ($tool.sandbox.resources.rlimit_as | default 134217728)
            let rlimit_cpu = ($tool.sandbox.resources.rlimit_cpu | default 30)
            if (which nsjail | is-not-empty) {
                mut nsjail_args = [
                    --mode
                    ONCE
                    --time_limit
                    ($timeout_secs | into string)
                    --rlimit_as
                    (($rlimit_as / 1024 / 1024) | into string)
                    --rlimit_cpu
                    ($rlimit_cpu | into string)
                ]
                if not $network { $nsjail_args = ($nsjail_args | append "--disable_clone_newnet") }
                nsjail ...$nsjail_args -- nix run $flake_ref -- ...$args
            } else { 
            # Fallback: timeout-only
            timeout $"($timeout_secs)s" nix run $flake_ref -- ...$args }
        }
        _ => { error make {
            msg: $"unsupported platform '(sys host | get name)'"
        } }
    }
}
