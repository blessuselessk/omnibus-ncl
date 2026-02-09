# nsjail.ncl - NsJail Backend Configuration
#
# NsJail-specific sandbox configuration.
# See: https://github.com/google/nsjail
{
  name = "nsjail",
  description = "Google NsJail sandbox",
  cmd = "/nsjail",
  args = [
    "--mode=once",
    "--quiet",
    "--log=log.txt",
    "--pid_file=pid.txt",
    "--cwd",
    "/tmp",
    "--",
  ],
}
