defmodule WargamesWeb.SessionController do
  use WargamesWeb, :controller

  def create(conn, params = %{"name" => name}) do
    conn
    |> put_session("name", name)
    |> redirect(to: params["redirect_to"] || "/")
  end
end
