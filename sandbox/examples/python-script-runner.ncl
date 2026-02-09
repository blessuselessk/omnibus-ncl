# python-script-runner.ncl - Python Script Runner Sandbox
#
# Usage:
#   1. Generate profile:
#      nickel export python-script-runner.ncl --field _profile -f text -- \
#        --override 'home_dir="/Users/guangtao"' \
#        --override 'script_path="/Users/guangtao/projects/test_sandbox/hello.py"' \
#        --override 'python_path="/Users/guangtao/.devenv/state/venv/bin/python3"' \
#        > profile.txt
#
#   2. Run in sandbox:
#      sandbox-exec -f profile.txt <cmd> <args>
let Sandbox = import "../seatbelt/interface.ncl" in

# Config (top-level fields can be overridden with --override)
{
  home_dir | default = "/home/user",
  script_path | default = home_dir ++ "/projects/test_sandbox/hello.py",
  python_path | default = "/usr/bin/python3",

  # Profile output
  _profile =
    let user_projects = home_dir ++ "/projects" in
    let script_dir = home_dir ++ "/projects/test_sandbox" in
    Sandbox.build {
      id = "python-script-runner",
      backend = 'seatbelt,
      cmd = [python_path, script_path],

      network = { enabled = true, mode = 'full' },

      fs = {
        mode = 'whitelist,
        allowed_paths = [
          script_dir,
          script_path,
          user_projects,
          "/usr/local",
          "/usr/lib",
          "/System/Library",
          "/Library",
          "/private/tmp",
          "/var/folders",
        ],
      },

      env = {
        HOME = home_dir,
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
        PYTHONPATH = user_projects,
        PYTHONUNBUFFERED = "1",
      },
    }
    |> Sandbox.to_profile,

  # Reference info
  _info = {
    user_projects = home_dir ++ "/projects",
    script_dir = home_dir ++ "/projects/test_sandbox",
    cmd = [python_path, script_path],
    env = {
      HOME = home_dir,
      PYTHONPATH = home_dir ++ "/projects",
    },
  },
}
