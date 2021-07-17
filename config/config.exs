# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :wargames,
  ecto_repos: [Wargames.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :wargames, WargamesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "HmVn+JV1kLU1HqyoPgPLpxbQwoQU8d29YQbSy3dSYu6dWqrDb8afFlZhiURrRcMu",
  render_errors: [view: WargamesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Wargames.PubSub,
  live_view: [signing_salt: "1hYbFtdt"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures TicTacToe Server timeout (how long before the game expires)
config :wargames, Wargames.TicTacToe, timeout: :timer.minutes(5)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
