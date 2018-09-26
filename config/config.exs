# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :cotoami,
  ecto_repos: [Cotoami.Repo]

# Configures the endpoint
config :cotoami, CotoamiWeb.Endpoint,
  url: [host: "treba.tk"],
  secret_key_base: "ykbmEEU9u3Hoeh7tt8X6XMhLwRFPZw2PF3qZw1uO0+r6+3zbVD5s8b12rpiN7CzU",
  render_errors: [view: CotoamiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cotoami.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Amishi-related
config :cotoami, Cotoami.AmishiService,
  owner_emails:
    (System.get_env("COTOAMI_OWNER_EMAILS") || "tukroschu@gmail.com,kroschu@mail.ua,kroschu@email.ua")
    |> String.split(",", trim: true),
  signup_enabled:
    (System.get_env("COTOAMI_SIGNUP_ENABLED") || "true")
    |> String.to_existing_atom()

# Redis
case System.get_env("REDIS_URL") do
  nil ->
    config :cotoami, Cotoami.Redix,
      host: System.get_env("COTOAMI_REDIS_HOST") || "treba.tk",
      port: (System.get_env("COTOAMI_REDIS_PORT") || "6379") |> String.to_integer
  url ->
    config :cotoami, Cotoami.Redix, url: url
end

# Mail
case System.get_env("SENDGRID_USERNAME") do
  nil ->
    config :cotoami, Cotoami.Mailer,
      adapter: Bamboo.SMTPAdapter,
      server: System.get_env("COTOAMI_SMTP_SERVER") || "treba.tk",
      port: (System.get_env("COTOAMI_SMTP_PORT") || "25") |> String.to_integer,
      username: System.get_env("COTOAMI_SMTP_USER")  || "tukroschu@gmail.com",
      password: System.get_env("COTOAMI_SMTP_PASSWORD") || "agni.0.523",
      tls: :if_available, # can be `:always` or `:never`
      ssl: false, # can be `true`
      retries: 1
  username ->
    config :cotoami, Cotoami.Mailer,
      adapter: Bamboo.SendgridAdapter,
      api_key: System.get_env("SENDGRID_API_KEY")
end

config :cotoami, CotoamiWeb.Email,
  from: System.get_env("COTOAMI_EMAIL_FROM")

# Neo4j
case System.get_env("GRAPHENEDB_BOLT_URL") do
  nil ->
    config :bolt_sips, Bolt,
      hostname: System.get_env("COTOAMI_NEO4J_HOST") || "treba.tk",
      port: (System.get_env("COTOAMI_NEO4J_PORT") || "7687") |> String.to_integer,
      pool_size: 5,
      max_overflow: 1
  url ->
    config :bolt_sips, Bolt,
      url: url,
      basic_auth: [
        username: System.get_env("GRAPHENEDB_BOLT_USER"), 
        password: System.get_env("GRAPHENEDB_BOLT_PASSWORD")
      ],
      ssl: true
end


# Configure your database
config :cotoami, Cotoami.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("COTOAMI_DEV_REPO_USER") || "postgres",
  password: System.get_env("COTOAMI_DEV_REPO_PASSWORD") || "postgres",
  database: System.get_env("COTOAMI_DEV_REPO_DATABASE") || "cotoami_dev",
  hostname: System.get_env("COTOAMI_DEV_REPO_HOST")  || "treba.tk",
  port: (System.get_env("COTOAMI_DEV_REPO_PORT") || "5432") |> String.to_integer,
  pool_size: 10,
  timeout: 300_000
  
  # Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

 
