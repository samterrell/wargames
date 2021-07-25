defmodule WargamesWeb.Router do
  use WargamesWeb, :router

  def preload(conn, _) do
    preloads = [
      {__MODULE__.Helpers.static_path(conn, "/css/app.css"), :style},
      {__MODULE__.Helpers.static_path(conn, "/js/app.js"), :script},
      {__MODULE__.Helpers.static_path(conn, "/fonts/MajorMonoDisplay-Regular.ttf"), :font},
      {__MODULE__.Helpers.static_path(conn, "/images/logo.svg"), :image}
    ]

    link =
      Enum.map(preloads, fn {path, type} -> "<#{path}>; rel=preload; as=#{type}" end)
      |> Enum.join(", ")

    Enum.reduce(preloads, conn, fn {path, _type}, conn -> push(conn, path) end)
    |> put_resp_header("link", link)
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WargamesWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :preload
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WargamesWeb do
    pipe_through :browser

    post "/session", SessionController, :create
    live "/", PageLive, :index
    live "/tictactoe/:id", TicTacToeLive, :game
  end

  # Other scopes may use custom stacks.
  # scope "/api", WargamesWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WargamesWeb.Telemetry
    end
  end
end
