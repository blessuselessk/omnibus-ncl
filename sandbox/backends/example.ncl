# backends/example.ncl - Example Backend Configuration
let BackendInterface = import "interface.ncl" in
{
  nsjail_backend | BackendInterface.BackendContract = {
    name = "nsjail",
    supported_platforms = ["linux"],
    supported_profiles = ["strict", "standard", "relaxed"],
    supported_features = {
      seccomp = true,
      cgroups = true,
      namespaces = true,
      network_isolation = true,
    },
    default_timeout_seconds = 30,
  },
  nsjail_instance | BackendInterface.BackendInstance = {
    id = "nsjail-001",
    contract = nsjail_backend,
    state = "running",
  },
  nsjail_params | BackendInterface.BackendParams = {
    config = {
      mode = "single",
      bindhost = "127.0.0.1",
      port = 8080,
    },
    profile = {
      name = "test",
      level = 'standard,
      resources = nsjail_backend.default_timeout_seconds,
      seccomp = 'basic,
    },
  },
}
