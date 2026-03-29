# Makefile for non-Nix users. Requires: nickel, jq
# Also needs _deps/ populated — run: make deps
.PHONY: export validate check test fmt deps

deps:
	@echo "Set up _deps/ manually:"
	@echo "  mkdir -p _deps"
	@echo "  ln -sfn /path/to/codemode-ncl _deps/codemode-ncl"
	@echo "  cp -r /path/to/codemode-mcp-ncl _deps/codemode-mcp-ncl"
	@echo "  mkdir -p _deps/codemode-mcp-ncl/_deps"
	@echo "  ln -sfn /path/to/codemode-ncl _deps/codemode-mcp-ncl/_deps/codemode-ncl"
	@echo "Or use: nix develop"

export:
	nickel export --format json examples/mcp-tools-export.ncl

export-server:
	nickel export --format json examples/mcp-server.ncl

export-openapi:
	nickel export --format json examples/openapi-server.ncl

export-requests:
	nickel export --format json examples/request-examples.ncl

validate:
	@nickel export --format json examples/mcp-tools-export.ncl > /dev/null && echo "MCP tools: OK"
	@nickel export --format json examples/mcp-server.ncl > /dev/null && echo "MCP server: OK"
	@nickel export --format json examples/openapi-server.ncl > /dev/null && echo "OpenAPI server: OK"
	@nickel export --format json examples/request-examples.ncl > /dev/null && echo "Request examples: OK"

check: validate

test:
	bash tests/validate.sh

fmt:
	@find . -name '*.ncl' ! -path './_deps/*' -exec nickel format {} +
