# All 44 state tools from @cloudflare/shell/workers stateTools()
#
# Organized by category matching the StateBackend interface.
# Each tool has description and positional param names.
let { StateToolSet, .. } = import "../lib/state.ncl" in

{
  # -- Capabilities --
  getCapabilities = {
    description = "Get workspace capabilities and feature flags",
    category = "metadata",
  },

  # -- File I/O --
  readFile = {
    description = "Read a file as UTF-8 text",
    params = ["path"],
    category = "file-io",
  },
  readFileBytes = {
    description = "Read a file as raw bytes (Uint8Array)",
    params = ["path"],
    category = "file-io",
  },
  writeFile = {
    description = "Write UTF-8 text to a file (creates or overwrites)",
    params = ["path", "content"],
    category = "file-io",
  },
  writeFileBytes = {
    description = "Write raw bytes to a file",
    params = ["path", "content"],
    category = "file-io",
  },
  appendFile = {
    description = "Append content to a file",
    params = ["path", "content"],
    category = "file-io",
  },

  # -- JSON --
  readJson = {
    description = "Read and parse a JSON file",
    params = ["path"],
    category = "json",
  },
  writeJson = {
    description = "Write a value as formatted JSON to a file",
    params = ["path", "value", "options"],
    category = "json",
  },
  queryJson = {
    description = "Query a JSON file with a dot-path expression",
    params = ["path", "query"],
    category = "json",
  },
  updateJson = {
    description = "Apply set/delete operations to a JSON file",
    params = ["path", "operations"],
    category = "json",
  },

  # -- Metadata & Directories --
  exists = {
    description = "Check if a path exists",
    params = ["path"],
    category = "metadata",
  },
  stat = {
    description = "Get file/directory metadata (follows symlinks)",
    params = ["path"],
    category = "metadata",
  },
  lstat = {
    description = "Get file/directory metadata (does not follow symlinks)",
    params = ["path"],
    category = "metadata",
  },
  mkdir = {
    description = "Create a directory (with optional recursive creation)",
    params = ["path", "options"],
    category = "directory",
  },
  readdir = {
    description = "List entries in a directory",
    params = ["path"],
    category = "directory",
  },
  readdirWithFileTypes = {
    description = "List directory entries with type information",
    params = ["path"],
    category = "directory",
  },

  # -- Tree Traversal --
  find = {
    description = "Find files/directories matching criteria (name, type, size, date)",
    params = ["path", "options"],
    category = "tree",
  },
  walkTree = {
    description = "Walk directory tree and return nested node structure",
    params = ["path", "options"],
    category = "tree",
  },
  summarizeTree = {
    description = "Summarize directory tree (file count, total size, types)",
    params = ["path", "options"],
    category = "tree",
  },

  # -- Search & Replace --
  searchText = {
    description = "Search for text in a single file",
    params = ["path", "query", "options"],
    category = "search",
  },
  searchFiles = {
    description = "Search for text across files matching a glob pattern",
    params = ["pattern", "query", "options"],
    category = "search",
  },
  replaceInFile = {
    description = "Replace text in a single file",
    params = ["path", "search", "replacement", "options"],
    category = "search",
  },
  replaceInFiles = {
    description = "Replace text across files matching a glob pattern",
    params = ["pattern", "search", "replacement", "options"],
    category = "search",
  },

  # -- File Operations --
  rm = {
    description = "Remove a file or directory",
    params = ["path", "options"],
    category = "file-ops",
  },
  cp = {
    description = "Copy a file or directory",
    params = ["src", "dest", "options"],
    category = "file-ops",
  },
  mv = {
    description = "Move/rename a file or directory",
    params = ["src", "dest", "options"],
    category = "file-ops",
  },
  symlink = {
    description = "Create a symbolic link",
    params = ["target", "linkPath"],
    category = "file-ops",
  },
  readlink = {
    description = "Read the target of a symbolic link",
    params = ["path"],
    category = "file-ops",
  },
  realpath = {
    description = "Resolve a path to its absolute real path",
    params = ["path"],
    category = "file-ops",
  },
  resolvePath = {
    description = "Resolve a relative path against a base",
    params = ["base", "path"],
    category = "file-ops",
  },
  glob = {
    description = "Find files matching a glob pattern",
    params = ["pattern"],
    category = "file-ops",
  },
  diff = {
    description = "Compute unified diff between two files",
    params = ["pathA", "pathB"],
    category = "file-ops",
  },
  diffContent = {
    description = "Compute diff between a file and new content string",
    params = ["path", "newContent"],
    category = "file-ops",
  },
  removeTree = {
    description = "Recursively remove a directory tree",
    params = ["path"],
    category = "file-ops",
  },
  copyTree = {
    description = "Recursively copy a directory tree",
    params = ["src", "dest"],
    category = "file-ops",
  },
  moveTree = {
    description = "Recursively move a directory tree",
    params = ["src", "dest"],
    category = "file-ops",
  },

  # -- Archives & Compression --
  createArchive = {
    description = "Create an archive from source paths",
    params = ["path", "sources"],
    category = "archive",
  },
  listArchive = {
    description = "List entries in an archive",
    params = ["path"],
    category = "archive",
  },
  extractArchive = {
    description = "Extract an archive to a destination directory",
    params = ["path", "destination"],
    category = "archive",
  },
  compressFile = {
    description = "Compress a file (gzip)",
    params = ["path", "destination"],
    category = "archive",
  },
  decompressFile = {
    description = "Decompress a file (gzip)",
    params = ["path", "destination"],
    category = "archive",
  },
  hashFile = {
    description = "Compute hash of a file (SHA-256 default)",
    params = ["path", "options"],
    category = "archive",
  },
  detectFile = {
    description = "Detect file type and MIME type",
    params = ["path"],
    category = "archive",
  },

  # -- Edit Planning --
  planEdits = {
    description = "Plan a batch of file edits from instructions",
    params = ["instructions"],
    category = "edit",
  },
  applyEditPlan = {
    description = "Apply a previously planned set of edits",
    params = ["plan", "options"],
    category = "edit",
  },
  applyEdits = {
    description = "Apply edits directly (without planning step)",
    params = ["edits", "options"],
    category = "edit",
  },
}
  | StateToolSet
