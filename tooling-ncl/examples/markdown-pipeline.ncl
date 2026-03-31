# Markdown processing pipeline
#
# Three nodes chained:
# 1. pandoc: markdown → JSON AST
# 2. jq: extract headers as TOC
# 3. jq: format as markdown list
let B = import "../lib/builders.ncl" in
let P = import "../lib/pipe.ncl" in

let parse =
  B.bash "pandoc-parse" "pandoc -f markdown -t json"
  |> B.with_schemas
    { type = "string", description = "Raw markdown" }
    { type = "object", description = "Pandoc JSON AST" }
  |> B.sandboxed
in

let extract_toc =
  B.bash "extract-toc" "jq '[.blocks[] | select(.t == \"Header\") | {level: .c[0], text: [.c[2][] | select(.t == \"Str\") | .c] | join(\" \")}]'"
  |> B.with_schemas
    { type = "object", description = "Pandoc JSON AST" }
    { type = "array", items = { type = "object" }, description = "Array of headers" }
  |> B.sandboxed
in

let format_toc =
  B.bash "format-toc" "jq -r '.[] | (\" \" * (.level - 1) * 2) + \"- \" + .text'"
  |> B.with_schemas
    { type = "array" }
    { type = "string", description = "Markdown TOC" }
  |> B.sandboxed
in

P.pipeline "markdown-toc" [parse, extract_toc, format_toc]
