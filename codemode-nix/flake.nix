{
  description = "codemode-nix — Nix packages as LLM-callable tools with sandbox enforcement";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    codemode-ncl.url = "github:blessuselessk/codemode-ncl";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    codemode-ncl,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      withDeps = src:
        pkgs.runCommand "codemode-nix-src" {} ''
          cp -r ${src} $out
          chmod -R +w $out
          mkdir -p $out/_deps
          ln -s ${codemode-ncl} $out/_deps/codemode-ncl
        '';
    in {
      devShells.default = pkgs.mkShell {
        packages = [pkgs.nickel pkgs.just pkgs.fd pkgs.jq];

        shellHook = ''
          mkdir -p _deps
          ln -sfn ${codemode-ncl} _deps/codemode-ncl
          echo "codemode-nix dev shell (_deps/ populated)"
        '';
      };

      apps.validate = {
        type = "app";
        program = toString (pkgs.writeShellScript "cnix-validate" ''
          export PATH="${pkgs.lib.makeBinPath [pkgs.nickel pkgs.jq]}:$PATH"
          exec ${pkgs.bash}/bin/bash ${withDeps self}/tests/validate.sh
        '');
      };

      apps.export = {
        type = "app";
        program = toString (pkgs.writeShellScript "cnix-export" ''
          exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/nix-tools-export.ncl
        '');
      };

      apps.export-registry = {
        type = "app";
        program = toString (pkgs.writeShellScript "cnix-export-registry" ''
          exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/nix-registry.ncl
        '');
      };

      packages.default =
        pkgs.runCommand "codemode-nix-tools" {
          nativeBuildInputs = [pkgs.nickel pkgs.jq];
        } ''
          mkdir -p $out
          cd ${withDeps self}
          nickel export --format json examples/nix-tools-export.ncl | jq -S . > $out/nix-tools.json
          nickel export --format json examples/nix-registry.ncl | jq -S . > $out/nix-registry.json
          nickel export --format json examples/provider-config.ncl | jq -S . > $out/provider-config.json
        '';

      checks.default =
        pkgs.runCommand "codemode-nix-check" {
          nativeBuildInputs = [pkgs.nickel pkgs.jq];
        } ''
          cd ${withDeps self}

          echo "Checking nix-tools-export.ncl..."
          nickel export --format json examples/nix-tools-export.ncl > /dev/null

          echo "Checking nix-registry.ncl..."
          nickel export --format json examples/nix-registry.ncl > /dev/null

          echo "Checking provider-config.ncl..."
          nickel export --format json examples/provider-config.ncl > /dev/null

          TOOL_COUNT=$(nickel export --format json examples/nix-tools-export.ncl | jq 'keys | length')
          if [ "$TOOL_COUNT" -ne 5 ]; then
            echo "FAIL: expected 5 nix tools, got $TOOL_COUNT"
            exit 1
          fi

          echo "All checks passed"
          touch $out
        '';
    });
}
