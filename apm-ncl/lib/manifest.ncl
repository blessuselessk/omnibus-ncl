# ApmManifest contract — top-level schema for apm.yml
#
# Models the complete APM package manifest including metadata,
# dependencies, scripts, and compilation config.
let { DependencySet, .. } = import "dependency.ncl" in
let { CompilationConfig, .. } = import "compilation.ncl" in

{
  PackageTarget
    | doc "Target platform for the agent package"
    | not_exported
    = [| 'vscode, 'agents, 'claude, 'all, 'minimal |],

  PackageType
    | doc "Type of agent package content"
    | not_exported
    = [| 'instructions, 'skill, 'hybrid, 'prompts |],

  ApmManifest
    | doc m%"
      Top-level APM manifest (apm.yml).
      Describes an agent package's metadata, dependencies, and build config.
    "%
    | not_exported
    = {
      name | String,
      version | String,
      description | String | optional,
      author | String | optional,
      license | String | optional,
      target | PackageTarget | optional,
      type | PackageType | optional,
      scripts | { _ : String } | optional,
      dependencies | DependencySet | optional,
      devDependencies | DependencySet | optional,
      compilation | CompilationConfig | optional,
      ..
    },
}
