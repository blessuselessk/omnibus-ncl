# Envelope bridge — convert a nested envelope to Process Compose config
#
# Takes the three-layer envelope (tool → sandbox → workflow) from
# envelope-ncl and produces a process-compose.yaml that orchestrates
# each layer as a process with dependency ordering.
let bridge = import "../lib/bridge.ncl" in
let nested = import "../../envelope-ncl/examples/three-layer.ncl" in

bridge.from_envelope nested
