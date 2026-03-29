# Project management tools — Nickel replica of examples/codemode/src/tools.ts
#
# These 10 tools match the Zod schemas from the Cloudflare Agents codemode
# example. Export as JSON to get valid JsonSchemaToolDescriptors for
# generateTypesFromJsonSchema().
let B = (import "../lib/builders.ncl") in

{
  createProject =
    B.tool
      "Create a new project"
      (
        B.object_schema
          {
            name = B.string_field "Project name",
            description = B.string_field "Project description",
          }
          ["name"]
      ),

  listProjects =
    B.tool
      "List all projects"
      (B.object_schema {} []),

  createTask =
    B.tool
      "Create a task in a project"
      (
        B.object_schema
          {
            projectId = B.string_field "Project ID",
            title = B.string_field "Task title",
            description = B.string_field "Task description",
            status =
              B.enum_field
                "Task status"
                ["todo", "in_progress", "in_review", "done"],
            priority =
              B.enum_field
                "Priority level"
                ["low", "medium", "high", "urgent"],
            assignee = B.string_field "Assignee name",
            sprintId = B.string_field "Sprint ID",
          }
          ["projectId", "title"]
      ),

  listTasks =
    B.tool
      "List tasks with optional filters"
      (
        B.object_schema
          {
            projectId = B.string_field "Filter by project ID",
            status = B.string_field "Filter by status",
            priority = B.string_field "Filter by priority",
            assignee = B.string_field "Filter by assignee",
            sprintId = B.string_field "Filter by sprint ID",
          }
          []
      ),

  updateTask =
    B.tool
      "Update a task's fields"
      (
        B.object_schema
          {
            id = B.string_field "Task ID",
            title = B.string_field "New title",
            description = B.string_field "New description",
            status =
              B.enum_field
                "New status"
                ["todo", "in_progress", "in_review", "done"],
            priority =
              B.enum_field
                "New priority"
                ["low", "medium", "high", "urgent"],
            assignee = B.string_field "New assignee",
            sprintId = B.string_field "New sprint ID",
          }
          ["id"]
      ),

  deleteTask =
    B.tool
      "Delete a task and its comments"
      (
        B.object_schema
          {
            id = B.string_field "Task ID to delete",
          }
          ["id"]
      ),

  createSprint =
    B.tool
      "Create a sprint for a project"
      (
        B.object_schema
          {
            projectId = B.string_field "Project ID",
            name = B.string_field "Sprint name",
            startDate = B.string_field "Start date (ISO 8601)",
            endDate = B.string_field "End date (ISO 8601)",
          }
          ["projectId", "name"]
      ),

  listSprints =
    B.tool
      "List sprints, optionally by project"
      (
        B.object_schema
          {
            projectId = B.string_field "Filter by project ID",
          }
          []
      ),

  addComment =
    B.tool
      "Add a comment to a task"
      (
        B.object_schema
          {
            taskId = B.string_field "Task ID",
            content = B.string_field "Comment content",
            author = B.string_field "Author name",
          }
          ["taskId", "content"]
      ),

  listComments =
    B.tool
      "List comments on a task"
      (
        B.object_schema
          {
            taskId = B.string_field "Task ID",
          }
          ["taskId"]
      ),
}
