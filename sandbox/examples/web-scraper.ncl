# web-scraper.ncl - Web Scraper Sandbox
#
# Provides:
# - Full network access for HTTP requests
# - Access to project files and output
# - Python environment for scraping
let Sandbox = import "../seatbelt/interface.ncl" in
let User = import "user-config.ncl" in

Sandbox.build {
  id = "web-scraper",
  backend = 'seatbelt,
  cmd = ["/usr/local/bin/python3", User.projects ++ "/scraper/run.py"],

  network = { enabled = true, mode = 'full },

  fs = {
    mode = 'whitelist,
    allowed_paths = [
      # Project directories
      User.projects,
      User.projects ++ "/scraper/data",
      User.projects ++ "/scraper/output",

      # Python runtime
      "/usr/local/lib",
      "/usr/lib/python3.*",

      # Temp
      "/tmp",
      "/var/folders",

      # Downloads
      User.downloads,
    ],
  },

  env = {
    HOME = User.home,
    PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    PYTHONPATH = User.projects ++ "/scraper",
    PYTHONUNBUFFERED = "1",
  },
}
|> Sandbox.to_profile
