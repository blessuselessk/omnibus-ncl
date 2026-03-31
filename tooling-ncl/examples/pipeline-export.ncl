# Export the markdown pipeline as-is (the Pipeline record)
let { Pipeline, .. } = import "../lib/pipe.ncl" in
let pipeline = import "markdown-pipeline.ncl" in

pipeline | Pipeline
