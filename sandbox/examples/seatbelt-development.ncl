# seatbelt-development.ncl - Development Seatbelt Profile
#
# macOS Seatbelt sandbox for development with relaxed restrictions.
# Allows common development tools: bash, python, git, etc.
let Sandbox = import "../seatbelt/interface.ncl" in
let User = import "user-config.ncl" in

Sandbox.build {
  id = "seatbelt-development",
  backend = 'seatbelt,
  cmd = ["/bin/bash"],

  network = { enabled = true, mode = 'full },

  fs = {
    mode = 'whitelist,
    allowed_paths = [
      # Home directory
      User.home,
      User.projects,
      User.ssh,

      # Development tools
      "/usr/local",
      "/usr/bin",
      "/bin",
      "/usr/sbin",
      "/sbin",

      # Temp
      "/tmp",
      "/var/folders",
      "/var/tmp",

      # Logs
      "/var/log",
      "/Library/Logs",

      # Fonts
      "/Library/Fonts",
      "/System/Library/Fonts",
    ],
  },

  env = {
    HOME = User.home,
    PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
  },
}
|> Sandbox.to_profile
