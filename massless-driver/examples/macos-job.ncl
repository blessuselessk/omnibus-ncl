# macOS job using runner presets
let B = import "../lib/builders.ncl" in
let R = import "../lib/runner.ncl" in

B.job "macos-build" "myorg" "scripts/build-universal.sh"
& {
  runner = R.macos_14,
  artifacts = { enabled = true },
}
