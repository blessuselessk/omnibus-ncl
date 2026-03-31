# Apply inferences to auto-fill a partial node, then diagnose again
let D = import "../lib/diagnose.ncl" in

let partial = {
  name = "fetch-api",
  lang = 'bash,
  code = "curl -s https://api.github.com/repos/porkg/porkg",
}
in

let filled = D.apply_inferences partial in
let after_diag = D.diagnose filled in

{
  before = D.diagnose partial,
  filled_node = filled,
  after = after_diag,
}
