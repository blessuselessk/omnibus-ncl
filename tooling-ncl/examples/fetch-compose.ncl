# Export the fetch pipeline as a process-compose config
let P = import "../lib/pipe.ncl" in
let pipeline = import "fetch-and-process.ncl" in

P.to_process_compose pipeline
