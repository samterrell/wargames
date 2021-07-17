defmodule Wargames.Repo do
  use Ecto.Repo,
    otp_app: :wargames,
    adapter: Ecto.Adapters.Postgres
end
