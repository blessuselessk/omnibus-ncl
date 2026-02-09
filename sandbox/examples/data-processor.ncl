# data-processor.ncl - Data Processing Sandbox
#
# Provides:
# - No network access (security)
# - Read-only access to input data
# - Write access to output directory
# - Python/data processing tools
let Sandbox = import "../seatbelt/interface.ncl" in
let User = import "user-config.ncl" in

Sandbox.build {
  id = "data-processor",
  backend = 'seatbelt,
  cmd = ["/usr/local/bin/python3", User.data ++ "/pipeline/process.py"],

  network = { enabled = false },

  fs = {
    mode = 'whitelist,
    allowed_paths = [
      # Data directories
      User.data ++ "/input",
      User.data ++ "/output",
      User.data ++ "/logs",

      # Python runtime
      "/usr/local/lib/python3.*",
      "/usr/lib/python3.*",

      # Temp
      "/tmp",
      "/var/folders",
    ],
  },

  env = {
    HOME = User.home,
    PATH = "/usr/local/bin:/usr/bin:/bin",
    PYTHONUNBUFFERED = "1",
  },
}
|> Sandbox.to_profile
