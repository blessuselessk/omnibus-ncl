# porkg → process-compose — run a porkg build pipeline locally
#
# Defines a porkg config with a fully-isolated worker running three
# Rust build jobs, then bridges it to process-compose so you can
# actually run it with `process-compose up`.
let B = import "../porkg-ncl/lib/builders.ncl" in
let NS = import "../porkg-ncl/lib/namespace.ncl" in
let bridge = import "../process-compose-ncl/lib/bridge.ncl" in

let porkg_config =
  B.config "rust-builder" [
    B.job "check" ["cargo", "check", "--all-targets"],
    B.job "clippy" ["cargo", "clippy", "--all-targets", "--", "-D", "warnings"],
    B.job "test" ["cargo", "test", "--release"],
  ]
  & {
    worker = {
      name = "rust-builder",
      namespaces = NS.network_isolated,
      shutdown_timeout_seconds = 15,
    },
    log_level = 'info,
  }
in

# Convert to process-compose — worker becomes daemon, jobs depend on it
bridge.from_porkg porkg_config
