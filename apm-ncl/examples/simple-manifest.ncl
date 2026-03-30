# Minimal APM manifest — equivalent of a simple apm.yml
#
# Just name, version, and a single string dependency.
let B = import "../lib/builders.ncl" in

B.manifest "hello-agent" "0.1.0"
& {
  description = "A minimal agent package",
  type = 'instructions,
  dependencies = {
    apm = [
      "anthropics/courses",
    ],
  },
}
