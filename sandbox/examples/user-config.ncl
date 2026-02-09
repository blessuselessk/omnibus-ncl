# user-config.ncl - User-specific Configuration
#
# Dynamic user configuration using environment variables.
#
# Usage:
#   let User = import "user-config.ncl" in
#   User.home
#
# Environment variables:
#   - HOME_DIR: User home directory (default: /home/user)
#   - USER_NAME: Username (default: user)
{
  # Environment-based overrides
  _env = {
    HOME_DIR | default = "/home/user",
    USER_NAME | default = "user",
  },

  # Derived values
  home_dir = _env.HOME_DIR,
  username = _env.USER_NAME,

  home = _env.HOME_DIR,
  downloads = _env.HOME_DIR ++ "/Downloads",
  projects = _env.HOME_DIR ++ "/projects",
  data = _env.HOME_DIR ++ "/data",
  documents = _env.HOME_DIR ++ "/Documents",
  config = _env.HOME_DIR ++ "/.config",
  cache = _env.HOME_DIR ++ "/.cache",
  mozilla = _env.HOME_DIR ++ "/.mozilla",
  ssh = _env.HOME_DIR ++ "/.ssh",

  macos_library = _env.HOME_DIR ++ "/Library",
  macos_fonts = _env.HOME_DIR ++ "/Library/Fonts",
}
