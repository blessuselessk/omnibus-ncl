#!/usr/bin/env -S npx tsx
// extract-schemas.ts — Extract JSON Schema from the PM tools in examples/codemode
//
// Run from the agents repo root (where node_modules has zod + ai):
//   npx tsx /path/to/omnibus-ncl/codemode/tests/extract-schemas.ts
//
// Outputs JsonSchemaToolDescriptors JSON to stdout.
// Redirect to snapshot.json to update the ground truth.

import { z } from "zod";

// Reconstruct the Zod schemas from examples/codemode/src/tools.ts
// (without execute functions — we only need the schema shapes)
const toolSchemas = {
  createProject: {
    description: "Create a new project",
    inputSchema: z.object({
      name: z.string().describe("Project name"),
      description: z.string().optional().describe("Project description")
    })
  },
  listProjects: {
    description: "List all projects",
    inputSchema: z.object({})
  },
  createTask: {
    description: "Create a task in a project",
    inputSchema: z.object({
      projectId: z.string().describe("Project ID"),
      title: z.string().describe("Task title"),
      description: z.string().optional().describe("Task description"),
      status: z
        .enum(["todo", "in_progress", "in_review", "done"])
        .optional()
        .describe("Task status"),
      priority: z
        .enum(["low", "medium", "high", "urgent"])
        .optional()
        .describe("Priority level"),
      assignee: z.string().optional().describe("Assignee name"),
      sprintId: z.string().optional().describe("Sprint ID")
    })
  },
  listTasks: {
    description: "List tasks with optional filters",
    inputSchema: z.object({
      projectId: z.string().optional().describe("Filter by project ID"),
      status: z.string().optional().describe("Filter by status"),
      priority: z.string().optional().describe("Filter by priority"),
      assignee: z.string().optional().describe("Filter by assignee"),
      sprintId: z.string().optional().describe("Filter by sprint ID")
    })
  },
  updateTask: {
    description: "Update a task's fields",
    inputSchema: z.object({
      id: z.string().describe("Task ID"),
      title: z.string().optional().describe("New title"),
      description: z.string().optional().describe("New description"),
      status: z
        .enum(["todo", "in_progress", "in_review", "done"])
        .optional()
        .describe("New status"),
      priority: z
        .enum(["low", "medium", "high", "urgent"])
        .optional()
        .describe("New priority"),
      assignee: z.string().optional().describe("New assignee"),
      sprintId: z.string().optional().describe("New sprint ID")
    })
  },
  deleteTask: {
    description: "Delete a task and its comments",
    inputSchema: z.object({
      id: z.string().describe("Task ID to delete")
    })
  },
  createSprint: {
    description: "Create a sprint for a project",
    inputSchema: z.object({
      projectId: z.string().describe("Project ID"),
      name: z.string().describe("Sprint name"),
      startDate: z.string().optional().describe("Start date (ISO 8601)"),
      endDate: z.string().optional().describe("End date (ISO 8601)")
    })
  },
  listSprints: {
    description: "List sprints, optionally by project",
    inputSchema: z.object({
      projectId: z.string().optional().describe("Filter by project ID")
    })
  },
  addComment: {
    description: "Add a comment to a task",
    inputSchema: z.object({
      taskId: z.string().describe("Task ID"),
      content: z.string().describe("Comment content"),
      author: z.string().optional().describe("Author name")
    })
  },
  listComments: {
    description: "List comments on a task",
    inputSchema: z.object({
      taskId: z.string().describe("Task ID")
    })
  }
};

// Convert Zod schemas to JSON Schema and output as JsonSchemaToolDescriptors
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
