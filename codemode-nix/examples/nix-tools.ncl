# Nix package tools — 5 starter tools for LLM-callable Nix packages
#
# Each tool declares a flakeRef, security level, and input schema.
# Export via nix-tools-export.ncl for LLM consumption, or via
# nix-registry.ncl for the full registry with sandbox config.
let B = import "../lib/builders.ncl" in
let { NixToolSet, .. } = import "../lib/nix.ncl" in

{
  jq =
    B.nix_tool
      "nixpkgs#jq"
      "strict"
      "Process JSON data using jq filter expressions. Reads from stdin or a file."
      (
        B.object_schema
          {
            filter = B.string_field "jq filter expression (e.g., '.[] | .name')",
            input = B.string_field "JSON input string to process",
            raw_output = B.boolean_field "Output raw strings without JSON quoting (-r)",
          }
          ["filter", "input"]
      ),

  ripgrep =
    B.nix_tool
      "nixpkgs#ripgrep"
      "strict"
      "Search file contents using regular expressions. Fast recursive search."
      (
        B.object_schema
          {
            pattern = B.string_field "Regex pattern to search for",
            path = B.string_field "File or directory to search (default: current dir)",
            glob = B.string_field "Only search files matching this glob (e.g., '*.ts')",
            case_insensitive = B.boolean_field "Case insensitive search (-i)",
            fixed_strings = B.boolean_field "Treat pattern as literal string (-F)",
            context = B.integer_field "Show N lines of context around matches (-C)",
          }
          ["pattern"]
      ),

  curl =
    B.nix_tool
      "nixpkgs#curl"
      "network"
      "Make HTTP requests. Supports GET, POST, PUT, DELETE with headers and body."
      (
        B.object_schema
          {
            url = B.string_field "URL to request",
            method = B.enum_field "HTTP method" ["GET", "POST", "PUT", "PATCH", "DELETE"],
            headers = B.array_field "HTTP headers" (B.string_field "Header in 'Key: Value' format"),
            data = B.string_field "Request body data",
            output = B.string_field "Write response to file instead of stdout",
            silent = B.boolean_field "Silent mode — hide progress meter",
          }
          ["url"]
      ),

  ffmpeg =
    B.nix_tool_with_paths
      "nixpkgs#ffmpeg"
      "io"
      "Convert and process audio/video files. Supports format conversion, trimming, encoding."
      (
        B.object_schema
          {
            input = B.string_field "Input file path",
            output = B.string_field "Output file path",
            format = B.string_field "Output format (e.g., mp4, mp3, wav)",
            codec = B.string_field "Codec to use (e.g., libx264, aac)",
            start_time = B.string_field "Start time for trimming (HH:MM:SS or seconds)",
            duration = B.string_field "Duration to extract (HH:MM:SS or seconds)",
            extra_args = B.array_field "Additional ffmpeg arguments" (B.string_field "arg"),
          }
          ["input", "output"]
      )
      ["/tmp/nix-tool-work"],

  pandoc =
    B.nix_tool_with_paths
      "nixpkgs#pandoc"
      "io"
      "Convert documents between formats. Supports Markdown, HTML, PDF, DOCX, LaTeX, and more."
      (
        B.object_schema
          {
            input = B.string_field "Input file path",
            output = B.string_field "Output file path",
            from = B.string_field "Input format (e.g., markdown, html, latex)",
            to = B.string_field "Output format (e.g., html, pdf, docx)",
            standalone = B.boolean_field "Produce standalone document (-s)",
            template = B.string_field "Template file for output formatting",
          }
          ["input", "output"]
      )
      ["/tmp/nix-tool-work"],
}
  | NixToolSet
