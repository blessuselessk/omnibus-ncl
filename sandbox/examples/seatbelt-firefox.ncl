# seatbelt-firefox.ncl - Firefox GUI Application Sandbox
#
# Provides:
# - X11 display forwarding
# - Home directory access
# - Audio through system sockets
# - Localhost network access
let Sandbox = import "../seatbelt/interface.ncl" in
let User = import "user-config.ncl" in

Sandbox.build {
  id = "seatbelt-firefox",
  backend = 'seatbelt,
  cmd = [
    "/usr/bin/firefox",
    "--no-remote",
    "--new-instance",
    "--profile",
    User.mozilla ++ "/firefox/default",
  ],

  network = { enabled = true, mode = 'full },

  fs = {
    mode = 'whitelist,
    allowed_paths = [
      # Home directory
      User.home,
      User.downloads,
      User.mozilla,
      User.cache,
      User.config,

      # System directories
      "/tmp",
      "/var/folders",

      # Fonts
      "/Library/Fonts",
      "/System/Library/Fonts",
      User.macos_fonts,

      # Applications
      "/Applications",
      "/usr/local",
    ],
  },

  env = {
    DISPLAY = ":0",
    HOME = User.home,
    PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    USER = User.username,
    LANG = "en_US.UTF-8",
  },
}
|> Sandbox.to_profile
