# Diagnose a node that has code — inference kicks in
let D = import "../lib/diagnose.ncl" in

D.diagnose {
  name = "extract-names",
  lang = 'bash,
  code = "jq '[.[] | .name]'",
}
