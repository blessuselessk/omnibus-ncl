# Nix flake job — runs `nix run` instead of a shell script
let B = import "../lib/builders.ncl" in

B.nix_job "nix-build" "myorg" "github:owner/repo#package"
