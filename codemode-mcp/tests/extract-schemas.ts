#!/usr/bin/env -S npx tsx
// extract-schemas.ts — Extract JSON Schema from the MCP demo tools
//
// Run from the agents repo root (where node_modules has zod):
//   npx tsx /path/to/codemode-mcp/tests/extract-schemas.ts
//
// Outputs MCP tool descriptors JSON to stdout.

import { z } from "zod";

// Reconstruct the Zod schemas from examples/codemode-mcp/src/server.ts
const toolSchemas = {
  add: {
    description: "Add two numbers together",
    inputSchema: z.object({
      a: z.number().describe("First number"),
      b: z.number().describe("Second number")
    })
  },
  greet: {
    description: "Generate a greeting message",
    inputSchema: z.object({
      name: z.string().describe("Name to greet"),
      language: z
        .enum(["en", "es", "fr"])
        .optional()
        .describe("Language for the greeting")
    })
  },
  list_items: {
    description: "List items with optional filtering",
    inputSchema: z.object({
      category: z.string().optional().describe("Filter by category"),
      limit: z.number().optional().describe("Max items to return")
    })
  }
};

const result: Record<
  string,
  { description: string; inputSchema: unknown }
> = {};

for (const [name, tool] of Object.entries(toolSchemas)) {
  result[name] = {
    description: tool.description,
    inputSchema: z.toJSONSchema(tool.inputSchema)
  };
}

console.log(JSON.stringify(result, null, 2));
