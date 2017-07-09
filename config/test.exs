use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :cotoami, Cotoami.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :cotoami, Cotoami.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("COTOAMI_TEST_REPO_USER") || "postgres",
  password: System.get_env("COTOAMI_TEST_REPO_PASSWORD") || "postgres",
  database: System.get_env("COTOAMI_TEST_REPO_DATABASE") || "cotoami_test",
  hostname: System.get_env("COTOAMI_TEST_REPO_HOST")  || "localhost",
  port: (System.get_env("COTOAMI_TEST_REPO_PORT") || "5432") |> String.to_integer,
  pool: Ecto.Adapters.SQL.Sandbox
