# seatbelt-minimal.ncl - Minimal Seatbelt Profile
#
# Minimal macOS Seatbelt sandbox for simple tasks.
# Provides only basic filesystem access for testing.
let Sandbox = import "../seatbelt/interface.ncl" in

Sandbox.build {
  id = "seatbelt-minimal",
  backend = 'seatbelt,
  cmd = ["/bin/pwd"],

  network = { enabled = false },

  fs = {
    mode = 'ro,
    allowed_paths = ["/tmp"],
  },
}
|> Sandbox.to_profile
