use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :wargames, Wargames.Endpoint,
  secret_key_base: "W970aLlfKFPsiDrgjiRmFj8OyhH1ocls/1N8o2LbNb4BPp1hn9t1KVPZUCaLKstF"

# Configure your database
config :wargames, Wargames.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "wargames_prod"
