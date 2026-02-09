# lib/base.ncl - Base configuration module
#
# Provides common configuration patterns.
let NonEmptyStringContract = std.contract.from_predicate (fun val => std.is_string val && val != "") in
let ModeContract = std.contract.from_predicate (fun val => std.is_string val && std.array.elem val ["ONCE", "CGROUP", "LISTEN", "EXEC"]) in

let working_dir_fn = fun dir => { working_dir = dir } in
let transient_dir_fn = fun dir => { transient = { enable = true, dest_dir = dir, delete = true } } in
let rootfs_fn = fun path => { rootfs = path, read_only = false } in
let read_only_rootfs_fn = fun path => { rootfs = path, read_only = true } in
let with_logging_fn = fun log_path => fun log_level => { log = log_path, log_level = log_level } in
let proc_title_fn = fun title => { proc_title = title } in
let cgroup_fn = fun name => { cgroup = { name = name, mem_max = "512M", cpu_max = "100000" } } in
let cpu_affinity_fn = fun cpus => { cgroup = { cpu_affinity = cpus } } in

let env_default = [
  "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  "LANG=en_US.UTF-8",
  "LANGUAGE=en_US:en",
]
in

let logging_default = { log_level = "INFO", log = "/var/log/nsjail.log" } in
let cwd_default = { working_dir = "/tmp" } in

{
  # Contracts marked as not_exported (contain contracts)
  contracts | not_exported = {
    non_empty_string = NonEmptyStringContract,
    mode = ModeContract,
  },
  # Helper functions marked as not_exported (contain functions)
  lib | not_exported = {
    working_dir = working_dir_fn,
    transient_dir = transient_dir_fn,
    rootfs = rootfs_fn,
    read_only_rootfs = read_only_rootfs_fn,
    with_logging = with_logging_fn,
    proc_title = proc_title_fn,
    cgroup = cgroup_fn,
    cpu_affinity = cpu_affinity_fn,
  },
  config = {
    default_env = env_default,
    logging = logging_default,
    default_cwd = cwd_default,
  },
}
