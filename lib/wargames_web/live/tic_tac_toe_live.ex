defmodule WargamesWeb.TicTacToeLive do
  use WargamesWeb, :live_view
  alias Wargames.TicTacToe.Board

  @impl Phoenix.LiveView
  def mount(%{"id" => id}, session, socket) do
    Wargames.TicTacToe.create(id)
    :ok = Wargames.TicTacToe.subscribe(id)
    {:ok, state} = Wargames.TicTacToe.state(id)

    {:ok,
     socket
     |> assign(id: id, name: session["name"])
     |> assign_state(state)}
  end

  @impl Phoenix.LiveView
  def handle_event("join", _, socket) do
    {:ok, _} = Wargames.TicTacToe.join(socket.assigns.id, socket.assigns.name)
    {:ok, state} = Wargames.TicTacToe.state(socket.assigns.id)
    {:noreply, assign_state(socket, state)}
  end

  @impl Phoenix.LiveView
  def handle_event("play", %{"x" => x, "y" => y}, socket) do
    {:ok, x} = Ecto.Type.cast(:integer, x)
    {:ok, y} = Ecto.Type.cast(:integer, y)
    :ok = Wargames.TicTacToe.play(socket.assigns.id, {x, y}, socket.assigns.name)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("restart", _, socket) do
    Wargames.TicTacToe.restart(socket.assigns.id)
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:updated, id, state}, socket) do
    if socket.assigns.id == id do
      {:noreply, assign_state(socket, state)}
    else
      {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:shutdown, id}, socket) do
    if socket.assigns.id == id do
      {:noreply, redirect(socket, to: "/")}
    else
      {:noreply, socket}
    end
  end

  defp assign_state(socket, state) do
    started = not is_nil(state.x) and not is_nil(state.o)

    assign(socket,
      board: state.board,
      turn: state.turn,
      x: state.x,
      o: state.o,
      winner: state.winner,
      started: started,
      my_turn:
        started and
          ((state.turn == :x and socket.assigns.name == state.x) or
             (state.turn == :o and socket.assigns.name == state.o))
    )
  end
end
