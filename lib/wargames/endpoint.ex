defmodule Wargames.Endpoint do
  use Phoenix.Endpoint, otp_app: :wargames

  # Serve at "/" the given assets from "priv/static" directory
  plug Plug.Static,
    at: "/", from: :wargames,
    only: ~w(css images js favicon.ico robots.txt fonts)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_wargames_key",
    signing_salt: "RY8qgfUE",
    encryption_salt: "ydWHTbbC"

  plug :router, Wargames.Router
end
