{
  description = "codemode-shell-ncl — Nickel contracts for @cloudflare/shell stateTools + gitTools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    codemode-ncl.url = "github:blessuselessk/codemode-ncl";
  };

  outputs = { self, nixpkgs, flake-utils, codemode-ncl }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        withDeps = src: pkgs.runCommand "codemode-shell-src" {} ''
          cp -r ${src} $out
          chmod -R +w $out
          mkdir -p $out/_deps
          ln -s ${codemode-ncl} $out/_deps/codemode-ncl
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nickel pkgs.just pkgs.fd pkgs.jq ];

          shellHook = ''
            mkdir -p _deps
            ln -sfn ${codemode-ncl} _deps/codemode-ncl
            echo "codemode-shell dev shell (_deps/ populated)"
          '';
        };

        apps.validate = {
          type = "app";
          program = toString (pkgs.writeShellScript "cs-validate" ''
            export PATH="${pkgs.lib.makeBinPath [ pkgs.nickel pkgs.jq ]}:$PATH"
            exec ${pkgs.bash}/bin/bash ${withDeps self}/tests/validate.sh
          '');
        };

        apps.export-state = {
          type = "app";
          program = toString (pkgs.writeShellScript "cs-export-state" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/state-tools.ncl
          '');
        };

        apps.export-git = {
          type = "app";
          program = toString (pkgs.writeShellScript "cs-export-git" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/git-tools.ncl
          '');
        };

        apps.export-providers = {
          type = "app";
          program = toString (pkgs.writeShellScript "cs-export-providers" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/multi-provider.ncl
          '');
        };

        packages.default = pkgs.runCommand "codemode-shell-tools" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          mkdir -p $out
          cd ${withDeps self}
          nickel export --format json examples/state-tools.ncl | jq -S . > $out/state-tools.json
          nickel export --format json examples/git-tools.ncl | jq -S . > $out/git-tools.json
          nickel export --format json examples/workspace-config.ncl | jq -S . > $out/workspace-config.json
          nickel export --format json examples/multi-provider.ncl | jq -S . > $out/multi-provider.json
        '';

        checks.default = pkgs.runCommand "codemode-shell-check" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          cd ${withDeps self}

          echo "Checking state-tools.ncl..."
          nickel export --format json examples/state-tools.ncl > /dev/null

          echo "Checking git-tools.ncl..."
          nickel export --format json examples/git-tools.ncl > /dev/null

          echo "Checking workspace-config.ncl..."
          nickel export --format json examples/workspace-config.ncl > /dev/null

          echo "Checking multi-provider.ncl..."
          nickel export --format json examples/multi-provider.ncl > /dev/null

          STATE_COUNT=$(nickel export --format json examples/state-tools.ncl | jq 'keys | length')
          if [ "$STATE_COUNT" -ne 46 ]; then
            echo "FAIL: expected 46 state tools, got $STATE_COUNT"
            exit 1
          fi

          GIT_COUNT=$(nickel export --format json examples/git-tools.ncl | jq 'keys | length')
          if [ "$GIT_COUNT" -ne 14 ]; then
            echo "FAIL: expected 14 git tools, got $GIT_COUNT"
            exit 1
          fi

          echo "All checks passed"
          touch $out
        '';
      });
}
