# porkg bridge — convert a porkg config to Process Compose config
#
# Takes the nix-pipeline porkg config and produces a process-compose.yaml
# with the worker as a daemon and each job depending on it.
let bridge = import "../lib/bridge.ncl" in
let porkg_config = import "../../porkg-ncl/examples/nix-pipeline.ncl" in

bridge.from_porkg porkg_config
