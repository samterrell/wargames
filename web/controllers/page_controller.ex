defmodule Wargames.PageController do
  use Wargames.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
