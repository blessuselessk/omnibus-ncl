# Flatten a nested envelope into an array of layers for inspection
# Usage: nickel export --format json envelope-ncl/examples/flatten-export.ncl
let N = import "../lib/nesting.ncl" in
let nested = import "three-layer.ncl" in

N.flatten nested
