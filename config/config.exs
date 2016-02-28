# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :wargames, Wargames.Endpoint,
  url: [host: "localhost"],
  root: Path.expand("..", __DIR__),
  secret_key_base: "SIegUX4ubLgsW1L5CApnuIa5lxxbIlm3FR0AvSL6VYFDECzEEUJSTz5q1A1VqThT",
  debug_errors: false,
  pubsub: [name: Wargames.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures TicTacToe Server timeout (how long before the game expires)
config :wargames, TicTacToe.Server,
  timeout: :timer.minutes(5)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
