{
  description = "codemode-mcp-openapi — Nickel contracts for MCP tool wrapping and OpenAPI→MCP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    codemode-ncl.url = "github:blessuselessk/codemode-ncl";
    codemode-mcp-ncl.url = "github:blessuselessk/codemode-mcp-ncl";
    codemode-mcp-ncl.inputs.codemode-ncl.follows = "codemode-ncl";
  };

  outputs = { self, nixpkgs, flake-utils, codemode-ncl, codemode-mcp-ncl }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Prepare working tree with _deps/ for both upstreams.
        # codemode-mcp-ncl itself needs _deps/codemode-ncl/ for its imports.
        withDeps = src: pkgs.runCommand "codemode-mcp-openapi-src" {} ''
          cp -r ${src} $out
          chmod -R +w $out

          # Direct deps
          mkdir -p $out/_deps
          ln -s ${codemode-ncl} $out/_deps/codemode-ncl

          # codemode-mcp-ncl needs a writable copy so we can populate its _deps/
          cp -r ${codemode-mcp-ncl} $out/_deps/codemode-mcp-ncl
          chmod -R +w $out/_deps/codemode-mcp-ncl
          mkdir -p $out/_deps/codemode-mcp-ncl/_deps
          ln -s ${codemode-ncl} $out/_deps/codemode-mcp-ncl/_deps/codemode-ncl
        '';
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.nickel pkgs.just pkgs.fd pkgs.jq ];

          shellHook = ''
            mkdir -p _deps
            ln -sfn ${codemode-ncl} _deps/codemode-ncl

            # codemode-mcp-ncl needs its own _deps/, so copy + populate
            rm -rf _deps/codemode-mcp-ncl
            cp -r ${codemode-mcp-ncl} _deps/codemode-mcp-ncl
            chmod -R +w _deps/codemode-mcp-ncl
            mkdir -p _deps/codemode-mcp-ncl/_deps
            ln -sfn ${codemode-ncl} _deps/codemode-mcp-ncl/_deps/codemode-ncl

            echo "codemode-mcp-openapi dev shell (_deps/ populated)"
          '';
        };

        apps.validate = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmo-validate" ''
            export PATH="${pkgs.lib.makeBinPath [ pkgs.nickel pkgs.jq ]}:$PATH"
            exec ${pkgs.bash}/bin/bash ${withDeps self}/tests/validate.sh
          '');
        };

        apps.export = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmo-export" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/mcp-tools-export.ncl
          '');
        };

        apps.export-server = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmo-export-server" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/mcp-server.ncl
          '');
        };

        apps.export-openapi = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmo-export-openapi" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/openapi-server.ncl
          '');
        };

        apps.export-requests = {
          type = "app";
          program = toString (pkgs.writeShellScript "cmo-export-requests" ''
            exec ${pkgs.nickel}/bin/nickel export --format json ${withDeps self}/examples/request-examples.ncl
          '');
        };

        packages.default = pkgs.runCommand "codemode-mcp-openapi-tools" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          cd ${withDeps self}
          nickel export --format json examples/mcp-tools-export.ncl | jq -S . > $out
        '';

        packages.all = pkgs.runCommand "codemode-mcp-openapi-all" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          mkdir -p $out
          cd ${withDeps self}
          nickel export --format json examples/mcp-tools-export.ncl | jq -S . > $out/mcp-tools.json
          nickel export --format json examples/mcp-server.ncl | jq -S . > $out/mcp-server.json
          nickel export --format json examples/openapi-server.ncl | jq -S . > $out/openapi-server.json
          nickel export --format json examples/request-examples.ncl | jq -S . > $out/request-examples.json
        '';

        checks.default = pkgs.runCommand "codemode-mcp-openapi-check" {
          nativeBuildInputs = [ pkgs.nickel pkgs.jq ];
        } ''
          cd ${withDeps self}

          echo "Checking mcp-tools-export.ncl..."
          nickel export --format json examples/mcp-tools-export.ncl > /dev/null

          echo "Checking mcp-server.ncl..."
          nickel export --format json examples/mcp-server.ncl > /dev/null

          echo "Checking openapi-server.ncl..."
          nickel export --format json examples/openapi-server.ncl > /dev/null

          echo "Checking request-examples.ncl..."
          nickel export --format json examples/request-examples.ncl > /dev/null

          TOOL_COUNT=$(nickel export --format json examples/mcp-tools-export.ncl | jq 'keys | length')
          if [ "$TOOL_COUNT" -ne 3 ]; then
            echo "FAIL: expected 3 MCP tools, got $TOOL_COUNT"
            exit 1
          fi

          REQ_COUNT=$(nickel export --format json examples/request-examples.ncl | jq 'keys | length')
          if [ "$REQ_COUNT" -ne 4 ]; then
            echo "FAIL: expected 4 request examples, got $REQ_COUNT"
            exit 1
          fi

          echo "All checks passed"
          touch $out
        '';
      });
}
