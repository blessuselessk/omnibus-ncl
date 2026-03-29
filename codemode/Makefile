# Makefile for non-Nix users. Requires: nickel, jq
.PHONY: export validate check fmt

export:
	nickel export --format json examples/pm-tools-export.ncl

export-single:
	nickel export --format json examples/single-tool.ncl

validate:
	@nickel export --format json examples/pm-tools-export.ncl > /dev/null && echo "PM tools: OK"
	@nickel export --format json examples/single-tool.ncl > /dev/null && echo "Single tool: OK"

check: validate

test:
	bash tests/validate.sh

fmt:
	@find . -name '*.ncl' -exec nickel format {} +
