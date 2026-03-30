# CompilationConfig contract for APM manifest
#
# Models the `compilation` section of apm.yml — controls how APM
# compiles agent packages into output files.
{
  CompilationTarget
    | doc "Output target for compilation"
    | not_exported
    = [| 'vscode, 'agents, 'claude, 'all |],

  CompilationStrategy
    | doc "How to distribute compiled output"
    | not_exported
    = [| 'distributed, 'single-file |],

  PlacementConfig
    | doc "Placement options for compiled instructions"
    | not_exported
    = {
      min_instructions_per_file | Number | optional,
      ..
    },

  CompilationConfig
    | doc m%"
      Compilation settings for `apm compile`.
      Controls target format, output strategy, and post-processing.
    "%
    | not_exported
    = {
      target | CompilationTarget | optional,
      strategy | CompilationStrategy | optional,
      single_file | Bool | optional,
      output | String | optional,
      chatmode | String | optional,
      resolve_links | Bool | optional,
      source_attribution | Bool | optional,
      exclude | Array String | optional,
      placement | PlacementConfig | optional,
      ..
    },
}
