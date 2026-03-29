{
  description = "codemode-mcp — Nickel contracts for MCP tool wrapping via codeMcpServer()";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    codemode-ncl.url = "github:blessuselessk/codemode-ncl";
  };

  outputs = { self, nixpkgs, flake-utils, codemode-ncl }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Prepare a working tree with _deps/ populated
        withDeps = src: pkgs.runCommand "codemode-mcp-src" {} ''
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
            echo "codemode-mcp dev shell (_deps/ populated)"
          '';
        };

        apps.validate = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmcp-validate" ''
            export PATH="${pkgs.lib.makeBinPath [ pkgs.nickel pkgs.jq ]}:$PATH"
            exec ${pkgs.bash}/bin/bash ${withDeps self}/tests/validate.sh
          '');
        };

        apps.export = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmcp-export" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/demo-tools-export.ncl
          '');
        };

        apps.export-server = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmcp-export-server" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/server-config.ncl
          '');
        };

        packages.default = pkgs.runCommand "codemode-mcp-tools" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          cd ${withDeps self}
          nickel export --format json examples/demo-tools-export.ncl | jq -S . > $out
        '';

        packages.all = pkgs.runCommand "codemode-mcp-all" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          mkdir -p $out
          cd ${withDeps self}
          nickel export --format json examples/demo-tools-export.ncl | jq -S . > $out/demo-tools.json
          nickel export --format json examples/server-config.ncl | jq -S . > $out/server-config.json
        '';

        checks.default = pkgs.runCommand "codemode-mcp-check" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          cd ${withDeps self}

          echo "Checking demo-tools-export.ncl..."
          nickel export --format json examples/demo-tools-export.ncl > /dev/null

          echo "Checking server-config.ncl..."
          nickel export --format json examples/server-config.ncl > /dev/null

          TOOL_COUNT=$(nickel export --format json examples/demo-tools-export.ncl | jq 'keys | length')
          if [ "$TOOL_COUNT" -ne 3 ]; then
            echo "FAIL: expected 3 tools, got $TOOL_COUNT"
            exit 1
          fi

          echo "All checks passed"
          touch $out
        '';
      });
}
