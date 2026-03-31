{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    nixpkgs,
    treefmt-nix,
    ...
  }: let
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    treefmtEval = forAllSystems (
      pkgs:
        treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
          programs.nickel.enable = true;
          programs.mdformat.enable = true;
          settings.formatter.nufmt = {
            command = "${pkgs.nufmt}/bin/nufmt";
            includes = ["*.nu"];
          };
        }
    );
  in {
    formatter = forAllSystems (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
    checks = forAllSystems (pkgs: {
      formatting = treefmtEval.${pkgs.system}.config.build.check nixpkgs.lib.cleanSource ./.;
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = [
          pkgs.nickel
          pkgs.just
          pkgs.fd
          pkgs.jq
          treefmtEval.${pkgs.system}.config.build.wrapper
        ];
        shellHook = ''
          echo ""
          echo "omnibus-ncl dev shell"
          echo "====================="
          echo "nickel $(nickel --version 2>/dev/null | head -1)"
          echo ""
          echo "just test-examples     — validate all 30 examples"
          echo "nix fmt                — format all .ncl + .nix files"
          echo ""
          echo "Subprojects:"
          echo "  just md-*            — massless-driver (GHA workflows)"
          echo "  just env-*           — envelope-ncl (composable nesting)"
          echo "  just porkg-*         — porkg-ncl (process hierarchy)"
          echo "  just pc-*            — process-compose-ncl (orchestration)"
          echo "  just cm-*            — codemode (tool descriptors)"
          echo "  just prose-*         — prose-ncl (AI primitives)"
          echo "  just apm-*           — apm-ncl (agent packages)"
          echo "  just sb-*            — sandbox (seatbelt/nsjail)"
          echo ""
          echo "Run 'just' for full command list"
          echo ""
        '';
      };
    });
  };
}
