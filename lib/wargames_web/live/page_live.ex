defmodule WargamesWeb.PageLive do
  use WargamesWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("submit", _, socket) do
    {:ok, id} = Wargames.TicTacToe.create()
    {:noreply, redirect(socket, to: Routes.tic_tac_toe_path(socket, :game, id))}
  end
end
