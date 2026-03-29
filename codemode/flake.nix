{
  description = "codemode-ncl — Nickel contracts and builders for @cloudflare/codemode tool definitions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # `nix develop` — dev shell with nickel, just, fd, jq
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nickel
            pkgs.just
            pkgs.fd
            pkgs.jq
          ];

          shellHook = ''
            echo "codemode-ncl dev shell"
            echo "  nickel $(nickel --version 2>/dev/null | head -1)"
            echo "  just $(just --version 2>/dev/null)"
            echo ""
            echo "Commands: just cm-export | cm-validate | cm-test | cm-snapshot"
          '';
        };

        # `nix run .#validate` — run validation
        apps.validate = {
          type = "app";
          program = toString (pkgs.writeShellScript "cm-validate" ''
            export PATH="${pkgs.lib.makeBinPath [ pkgs.nickel pkgs.jq ]}:$PATH"
            exec ${pkgs.bash}/bin/bash ${self}/tests/validate.sh
          '');
        };

        # `nix run .#export` — export PM tools as JSON
        apps.export = {
          type = "app";
          program = toString (pkgs.writeShellScript "cm-export" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${self}/examples/pm-tools-export.ncl
          '');
        };

        # `nix build` — export PM tools JSON as a derivation
        packages.default = pkgs.runCommand "codemode-ncl-pm-tools" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
          src = self;
        } ''
          cd $src
          nickel export --format json examples/pm-tools-export.ncl | jq -S . > $out
        '';

        # `nix flake check`
        checks.default = pkgs.runCommand "codemode-ncl-check" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
          src = self;
        } ''
          cd $src
          echo "Checking pm-tools-export.ncl..."
          nickel export --format json examples/pm-tools-export.ncl > /dev/null
          echo "Checking single-tool.ncl..."
          nickel export --format json examples/single-tool.ncl > /dev/null

          # Structure validation
          TOOL_COUNT=$(nickel export --format json examples/pm-tools-export.ncl | jq 'keys | length')
          if [ "$TOOL_COUNT" -ne 10 ]; then
            echo "FAIL: expected 10 tools, got $TOOL_COUNT"
            exit 1
          fi
          echo "All checks passed"
          touch $out
        '';
      });
}
