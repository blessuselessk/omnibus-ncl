# Locked-down config — full isolation, no privilege escalation
let B = import "../lib/builders.ncl" in

let secure_worker =
  B.worker "secure-worker"
  |> B.with_full_isolation
  |> B.without_escalation
in

{
  worker = secure_worker & { shutdown_timeout_seconds = 10 },
  jobs = [
    B.job "lint" ["cargo", "clippy", "--all-targets"]
    & {
      allowed_paths = ["/workspace", "/tmp", "/usr/bin"],
      timeout_seconds = 120,
    },
    B.job "audit" ["cargo", "audit"]
    & {
      allowed_paths = ["/workspace", "/tmp"],
      timeout_seconds = 60,
    },
  ],
  log_level = 'warn,
}
