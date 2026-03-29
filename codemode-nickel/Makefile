# Makefile for non-Nix users. Requires: nickel, jq
# Also needs _deps/ populated — run: make deps
.PHONY: export validate check test fmt deps

deps:
	@echo "Set up _deps/ manually:"
	@echo "  mkdir -p _deps"
	@echo "  ln -sfn /path/to/codemode-ncl _deps/codemode-ncl"
	@echo "Or use: nix develop"

export:
	nickel export --format json examples/nickel-tools-export.ncl

export-project:
	nickel export --format json examples/sample-project.ncl

export-providers:
	nickel export --format json examples/provider-config.ncl

validate:
	@nickel export --format json examples/nickel-tools-export.ncl > /dev/null && echo "Nickel tools: OK"
	@nickel export --format json examples/sample-project.ncl > /dev/null && echo "Sample project: OK"
	@nickel export --format json examples/provider-config.ncl > /dev/null && echo "Provider config: OK"

check: validate

test:
	bash tests/validate.sh

fmt:
	@find . -name '*.ncl' ! -path './_deps/*' -exec nickel format {} +
