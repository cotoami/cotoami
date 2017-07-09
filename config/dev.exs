use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :cotoami, Cotoami.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [npm: ["run", "watch",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :cotoami, Cotoami.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :cotoami, Cotoami.Repo,
  adapter: Ecto.Adapters.Postgres,
  loggers: [Cotoami.Repo.Instrumenter, Ecto.LogEntry],
  username: System.get_env("COTOAMI_DEV_REPO_USER") || "postgres",
  password: System.get_env("COTOAMI_DEV_REPO_PASSWORD") || "postgres",
  database: System.get_env("COTOAMI_DEV_REPO_DATABASE") || "cotoami_dev",
  hostname: System.get_env("COTOAMI_DEV_REPO_HOST")  || "localhost",
  port: (System.get_env("COTOAMI_DEV_REPO_PORT") || "5432") |> String.to_integer,
  pool_size: 10
