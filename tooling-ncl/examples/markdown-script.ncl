# Export the markdown pipeline as a runnable bash script
let P = import "../lib/pipe.ncl" in
let pipeline = import "markdown-pipeline.ncl" in

P.to_shell_script pipeline
