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
  url: [host: "localhost"],
  secret_key_base: "ykbmEEU9u3Hoeh7tt8X6XMhLwRFPZw2PF3qZw1uO0+r6+3zbVD5s8b12rpiN7CzU",
  render_errors: [view: CotoamiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cotoami.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# EmailAuth
config :cotoami, CotoamiWeb.EmailAuthController,
  signup_enabled:
  (System.get_env("COTOAMI_SIGNUP_ENABLED") || "true")
  |> String.to_existing_atom()

# OAuth2
config :oauth2, 
  serializers: %{
    "application/json" => Poison,
    "application/vnd.api+json" => Poison
  },
  debug: true

config :cotoami, CotoamiWeb.OAuth2Controller,
  providers:
    (System.get_env("COTOAMI_OAUTH2_PROVIDERS") || "")
    |> String.split(",", trim: true)

config :cotoami, CotoamiWeb.OAuth2.Google,
  client_id: System.get_env("OAUTH_GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("OAUTH_GOOGLE_CLIENT_SECRET"),
  redirect_uri: System.get_env("OAUTH_GOOGLE_REDIRECT_URI")

config :cotoami, CotoamiWeb.OAuth2.GitHub,
  client_id: System.get_env("OAUTH_GITHUB_CLIENT_ID"),
  client_secret: System.get_env("OAUTH_GITHUB_CLIENT_SECRET"),
  redirect_uri: System.get_env("OAUTH_GITHUB_REDIRECT_URI")

config :cotoami, CotoamiWeb.OAuth2.Patreon,
  client_id: System.get_env("OAUTH_PATREON_CLIENT_ID"),
  client_secret: System.get_env("OAUTH_PATREON_CLIENT_SECRET"),
  redirect_uri: System.get_env("OAUTH_PATREON_REDIRECT_URI")

# Amishi-related
config :cotoami, Cotoami.AmishiService,
  owner_emails:
    (System.get_env("COTOAMI_OWNER_EMAILS") || "")
    |> String.split(",", trim: true)

config :cotoami, Cotoami.CotonomaService,
  global_cotonomas_holder: System.get_env("COTOAMI_GLOBAL_COTONOMAS_HOLDER")

# Redis
case System.get_env("REDIS_URL") do
  nil ->
    config :cotoami, Cotoami.Redix,
      host: System.get_env("COTOAMI_REDIS_HOST") || "localhost",
      port: (System.get_env("COTOAMI_REDIS_PORT") || "6379") |> String.to_integer
  url ->
    config :cotoami, Cotoami.Redix, url: url
end

# Mail
case System.get_env("SENDGRID_USERNAME") do
  nil ->
    config :cotoami, Cotoami.Mailer,
      adapter: Bamboo.SMTPAdapter,
      server: System.get_env("COTOAMI_SMTP_SERVER") || "localhost",
      port: (System.get_env("COTOAMI_SMTP_PORT") || "587") |> String.to_integer,
      username: System.get_env("COTOAMI_SMTP_USER"),
      password: System.get_env("COTOAMI_SMTP_PASSWORD"),
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
      hostname: System.get_env("COTOAMI_NEO4J_HOST") || "localhost",
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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
