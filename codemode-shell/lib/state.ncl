# State tool contracts — models stateTools() from @cloudflare/shell/workers
#
# 44 methods organized by category. All use positionalArgs: true,
# meaning calls look like state.readFile("/path") not state.readFile({path: "/path"}).
let { JsonSchema, .. } = import "schema.ncl" in

{
  StateEntryType
    | doc "File system entry types"
    | not_exported
    =
      std.contract.from_predicate (fun val =>
        std.is_string val
        && std.array.elem val ["file", "directory", "symlink"]
      ),

  StateSearchOptions
    | doc "Options for text search operations"
    | not_exported
    = {
      caseSensitive | Bool | optional,
      regex | Bool | optional,
      wholeWord | Bool | optional,
      contextBefore | Number | optional,
      contextAfter | Number | optional,
      maxMatches | Number | optional,
    },

  StateFindOptions
    | doc "Options for find operations"
    | not_exported
    = {
      name | String | optional,
      pathPattern | String | optional,
      type | Dyn | optional,
      minDepth | Number | optional,
      maxDepth | Number | optional,
      empty | Bool | optional,
      sizeMin | Number | optional,
      sizeMax | Number | optional,
      mtimeAfter | String | optional,
      mtimeBefore | String | optional,
    },

  StateToolDescriptor
    | doc m%"
      A single state tool. Simpler than JsonSchemaToolDescriptor because
      stateTools uses positionalArgs — parameters are positional, not keyed.
    "%
    | not_exported
    = {
      description | String,
      params | Array String | optional,
      category | String | optional,
    },

  StateToolSet
    | doc "Record of state tool descriptors keyed by method name"
    | not_exported
    = { _ : StateToolDescriptor },

  StateProviderConfig
    | doc m%"
      Configuration for the state ToolProvider.
      Maps to the return value of stateTools(workspace).
    "%
    | not_exported
    = {
      name | String | default = "state",
      positionalArgs | Bool | default = true,
      tools | StateToolSet,
    },
}
