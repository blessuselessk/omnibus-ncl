# Standalone Process Compose config — web app with database
let B = import "../lib/builders.ncl" in

B.compose {
  postgres =
    B.daemon "postgres -D /var/lib/postgres/data"
    |> B.with_health_check "pg_isready -h localhost"
    & {
      availability = { restart = 'always, backoff_seconds = 5 },
      shutdown = { signal = 15 },
      namespace = "data",
    },

  api =
    B.service "node server.js"
    |> B.depends_on_healthy "postgres"
    |> B.with_http_health "3000" "/health"
    & {
      environment = ["PORT=3000", "NODE_ENV=development"],
      working_dir = "/app",
    },

  worker =
    B.process "celery -A tasks worker --loglevel=info"
    |> B.depends_on_healthy "api"
    & {
      availability = { restart = 'on_failure },
    },
}
