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
config :cotoami, Cotoami.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ykbmEEU9u3Hoeh7tt8X6XMhLwRFPZw2PF3qZw1uO0+r6+3zbVD5s8b12rpiN7CzU",
  render_errors: [view: Cotoami.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Cotoami.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
