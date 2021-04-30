# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :overlay,
  ecto_repos: [Overlay.Repo]

# Configures the endpoint
config :overlay, OverlayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/Vjm+yqNnarxrWgK34juV2Rcp/KvryEeH7h5DP8304k0TUjDqNYanloY/EGohhn/",
  render_errors: [view: OverlayWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Overlay.PubSub,
  live_view: [signing_salt: "g2DaZmB4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
