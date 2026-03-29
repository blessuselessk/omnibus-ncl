# Makefile for non-Nix users. Requires: nickel, jq
# Also needs _deps/ populated — run: make deps
.PHONY: export-state export-git validate check test fmt deps

deps:
	@echo "Set up _deps/ manually:"
	@echo "  mkdir -p _deps"
	@echo "  ln -sfn /path/to/codemode-ncl _deps/codemode-ncl"
	@echo "Or use: nix develop"

export-state:
	nickel export --format json examples/state-tools.ncl

export-git:
	nickel export --format json examples/git-tools.ncl

export-providers:
	nickel export --format json examples/multi-provider.ncl

validate:
	@nickel export --format json examples/state-tools.ncl > /dev/null && echo "State tools: OK"
	@nickel export --format json examples/git-tools.ncl > /dev/null && echo "Git tools: OK"
	@nickel export --format json examples/workspace-config.ncl > /dev/null && echo "Workspace config: OK"
	@nickel export --format json examples/multi-provider.ncl > /dev/null && echo "Multi-provider: OK"

check: validate

test:
	bash tests/validate.sh

fmt:
	@find . -name '*.ncl' ! -path './_deps/*' -exec nickel format {} +
