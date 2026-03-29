# Makefile for non-Nix users. Requires: nickel, jq
# Also needs _deps/ populated — run: make deps
.PHONY: export export-registry validate check test fmt deps

deps:
	@echo "Set up _deps/ manually:"
	@echo "  mkdir -p _deps"
	@echo "  ln -sfn /path/to/codemode _deps/codemode-ncl"
	@echo "Or use: nix develop"

export:
	nickel export --format json examples/nix-tools-export.ncl

export-registry:
	nickel export --format json examples/nix-registry.ncl

validate:
	@nickel export --format json examples/nix-tools-export.ncl > /dev/null && echo "Nix tools: OK"
	@nickel export --format json examples/nix-registry.ncl > /dev/null && echo "Registry: OK"
	@nickel export --format json examples/provider-config.ncl > /dev/null && echo "Provider config: OK"

check: validate

test:
	bash tests/validate.sh

fmt:
	@find . -name '*.ncl' ! -path './_deps/*' -exec nickel format {} +
