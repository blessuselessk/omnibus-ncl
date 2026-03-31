# Simple process-compose config that actually runs — two echo processes
let PC = import "../process-compose-ncl/lib/builders.ncl" in

PC.compose {
  hello =
    PC.process "echo 'hello from process-compose'"
    & { availability = { restart = 'no } },

  world =
    PC.process "echo 'world — second process'"
    |> PC.depends_on_completed "hello"
    & { availability = { restart = 'no } },
}
