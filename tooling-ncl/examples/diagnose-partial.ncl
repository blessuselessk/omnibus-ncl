# Diagnose a partial node — just a name, nothing else
let D = import "../lib/diagnose.ncl" in

D.diagnose { name = "filter" }
