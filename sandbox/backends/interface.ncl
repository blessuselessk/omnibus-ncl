# backends/interface.ncl - Backend Interface
let NonEmptyStringArray =
  std.contract.from_predicate (fun value =>
    std.is_array value
    && std.array.all (fun x => std.is_string x && std.string.length x > 0) value
  )
in
let ValidTimeout =
  std.contract.from_predicate (fun x =>
    std.is_number x && x > 0 && x <= 3600
  )
in
{
  BackendContract = {
    name | String,
    supported_platforms | NonEmptyStringArray,
    supported_profiles | NonEmptyStringArray,
    supported_features = {
      seccomp | Bool,
      cgroups | Bool,
      namespaces | Bool,
      network_isolation | Bool,
    },
    default_timeout_seconds | ValidTimeout,
  },
  BackendInstance = {
    id | String,
    contract | BackendContract,
    state | String,
  },
  BackendParams = {
    config | { _ | Dyn },
    profile | { _ | Dyn },
  },
}
