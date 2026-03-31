# Nix build pipeline — isolated worker with multiple Nix build jobs
let B = import "../lib/builders.ncl" in
let NS = import "../lib/namespace.ncl" in

B.config
  "nix-builder"
  [
    B.nix_build_job "build-cli" ".#cli",
    B.nix_build_job "build-daemon" ".#daemon",
    B.job_with_env
      "run-tests"
      ["nix", "flake", "check"]
      {
        NIX_CONFIG = "experimental-features = nix-command flakes",
      },
  ]
& {
  worker = {
    name = "nix-builder",
    namespaces = NS.network_isolated,
    shutdown_timeout_seconds = 30,
    max_jobs = 4,
  },
  log_level = 'debug,
}
