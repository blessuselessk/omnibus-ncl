# Sample project plan — what the agent would generate for a K8s config project
#
# This is the project descriptor the agent builds before creating files.
let B = import "../lib/builders.ncl" in
let { ProjectStructure, .. } = import "../lib/project.ncl" in

B.project
  "k8s-ncl"
  "Nickel contracts for Kubernetes deployment configurations"
  [
    B.contract_file "lib/schema.ncl" "Core contracts: Pod, Container, Service, Deployment",
    B.contract_file "lib/resources.ncl" "Resource limits and requests contracts",
    B.builder_file "lib/builders.ncl" "Ergonomic builders for K8s resources",
    B.contract_file "lib/main.ncl" "Library aggregator",
    B.example_file "examples/web-app.ncl" "Web app deployment with service",
    B.export_file "examples/web-app-export.ncl" "Export wrapper with contract validation",
    B.test_file "tests/validate.sh" "Validation script",
  ]
  | ProjectStructure
