# Generate a ralph event from a diagnosis — feeds into the loop
let D = import "../lib/diagnose.ncl" in

let partial = { name = "transform", lang = 'bash, code = "jq '.name'" }
in
let diagnosis = D.diagnose partial in

D.to_ralph_event "transform" diagnosis
