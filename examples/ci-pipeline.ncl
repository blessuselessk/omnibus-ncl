# CI pipeline — lint in sandbox, test on GHA, deploy if green
#
# Three stages composed from different subprojects:
# 1. Lint: runs locally in nsjail sandbox (no network, read-only fs)
# 2. Test: runs on GitHub Actions with secrets for DB access
# 3. Deploy: runs on GHA with full permissions, depends on test passing
#
# Export produces a process-compose config that orchestrates all three.
let PC = import "../process-compose-ncl/lib/builders.ncl" in

PC.compose {
  lint =
    PC.process "nix run nixpkgs#nixpkgs-fmt -- --check ."
    & {
      namespace = "ci",
      description = "Format check — sandboxed, no network",
    },

  test =
    PC.process "nix flake check"
    |> PC.depends_on_completed "lint"
    |> PC.with_health_check "test -f result/ok"
    & {
      namespace = "ci",
      description = "Run test suite",
      environment = [
        "DATABASE_URL=postgres://localhost:5432/test",
        "CI=true",
      ],
    },

  deploy =
    PC.process "nix run .#deploy -- --env production"
    |> PC.depends_on_healthy "test"
    & {
      namespace = "ci",
      description = "Deploy to production",
      availability = { restart = 'no },
    },
}
