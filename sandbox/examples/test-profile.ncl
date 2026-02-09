# test-profile.ncl - Test Sandbox Profile
#
# Configuration for running tests in a sandbox.
let Interface = import "../interface.ncl" in
let User = import "user-config.ncl" in
{
  name = "test-sandbox",
  description = "Sandbox for running tests",

  resources = {
    max_memory_mb = 256,
    max_cpu_seconds = 60,
    max_file_size_mb = 50,
    max_fds = 64,
    max_processes = 16,
  },

  network = {
    enabled = false,
    mode = "deny",
  },

  filesystem = {
    mode = "ro",
    mounts = [
      { src = User.projects, dst = "/project", fstype = "bind", rw = false },
      { src = "/tmp", dst = "/tmp", fstype = "bind", rw = true },
    ],
    allowed_paths = [User.projects, "/tmp"],
  },

  seccomp = "basic",
  timeout_seconds = 120,
}
