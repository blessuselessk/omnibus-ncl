# lib/types.ncl - Type definitions for nsjail configurations
#
# Usage:
#   let types = import "lib/types.ncl" in
#   config | types.config
let ModeContract = std.contract.from_predicate (fun val => std.string.is_match val "^(ONCE|CGROUP|LISTEN|EXEC)$") in
let RlimitTypeContract = std.contract.from_predicate (fun val => std.string.is_match val "^(INF|SOFT|HARD|SEM|MSG)$") in
let NonEmptyString = std.contract.from_predicate (fun x => std.is_string x && std.string.length x > 0) in

{
  # Contracts marked as not_exported (not serializable)
  contracts | not_exported = {
    mode = ModeContract,
    rlimit_type = RlimitTypeContract,
    non_empty_string = NonEmptyString,
  },
}
