{
  description = "codemode-nickel — tool definitions for a Nickel project generator agent";

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
        pkgs.runCommand "codemode-nickel-src" {} ''
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
          echo "codemode-nickel dev shell (_deps/ populated)"
        '';
      };

      apps.validate = {
        type = "app";
        program = toString (pkgs.writeShellScript "cn-validate" ''
          export PATH="${pkgs.lib.makeBinPath [pkgs.nickel pkgs.jq]}:$PATH"
          exec ${pkgs.bash}/bin/bash ${withDeps self}/tests/validate.sh
        '');
      };

      apps.export = {
        type = "app";
        program = toString (pkgs.writeShellScript "cn-export" ''
          exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/nickel-tools-export.ncl
        '');
      };

      apps.export-project = {
        type = "app";
        program = toString (pkgs.writeShellScript "cn-export-project" ''
          exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/sample-project.ncl
        '');
      };

      packages.default =
        pkgs.runCommand "codemode-nickel-tools" {
          nativeBuildInputs = [pkgs.nickel pkgs.jq];
        } ''
          mkdir -p $out
          cd ${withDeps self}
          nickel export --format json examples/nickel-tools-export.ncl | jq -S . > $out/nickel-tools.json
          nickel export --format json examples/sample-project.ncl | jq -S . > $out/sample-project.json
          nickel export --format json examples/provider-config.ncl | jq -S . > $out/provider-config.json
        '';

      checks.default =
        pkgs.runCommand "codemode-nickel-check" {
          nativeBuildInputs = [pkgs.nickel pkgs.jq];
        } ''
          cd ${withDeps self}

          echo "Checking nickel-tools-export.ncl..."
          nickel export --format json examples/nickel-tools-export.ncl > /dev/null

          echo "Checking sample-project.ncl..."
          nickel export --format json examples/sample-project.ncl > /dev/null

          echo "Checking provider-config.ncl..."
          nickel export --format json examples/provider-config.ncl > /dev/null

          TOOL_COUNT=$(nickel export --format json examples/nickel-tools-export.ncl | jq 'keys | length')
          if [ "$TOOL_COUNT" -ne 6 ]; then
            echo "FAIL: expected 6 nickel tools, got $TOOL_COUNT"
            exit 1
          fi

          echo "All checks passed"
          touch $out
        '';
    });
}
