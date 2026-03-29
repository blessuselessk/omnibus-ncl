# Export Nix tools as LLM-facing JsonSchemaToolDescriptors.
# Strips flakeRef, securityLevel, and sandbox config — LLM only sees
# description + inputSchema.
# Usage: nickel export --format json codemode-nix/examples/nix-tools-export.ncl
let { ToolSet, .. } = import "../lib/tool.ncl" in
let B = import "../lib/builders.ncl" in
let tools = import "nix-tools.ncl" in

B.to_llm_view tools | ToolSet
