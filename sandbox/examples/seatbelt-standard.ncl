# seatbelt-standard.ncl - Standard Seatbelt Profile
#
# Standard macOS Seatbelt sandbox for general development.
# Similar to nsjail/apache.ncl complexity.
#
# Provides:
# - Full filesystem access to user directories
# - Network access for localhost
# - Environment variables for shell
let Sandbox = import "../seatbelt/interface.ncl" in

Sandbox.build {
  id = "seatbelt-standard",
  backend = 'seatbelt,
  cmd = ["/bin/bash"],

  network = { enabled = true, mode = 'localhost },

  fs = {
    mode = 'whitelist,
    allowed_paths = [
      "/Users",
      "/tmp",
      "/private",
      "/var/folders",
      "/usr/local",
    ],
  },
}
|> Sandbox.to_profile
