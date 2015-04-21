defmodule Wargames.TicTacToeChannel do
  use Wargames.Web, :channel

  def join("tictactoe:" <> game_id, auth_message, socket) do
    server = find_server(game_id)
    user = find_user(auth_message)
    position = case TicTacToe.Server.join(server, user) do
      {:ok, position} -> position
      {:error, :game_full} -> :spectator
    end
    after_join fn socket ->
      broadcast!(socket, "user:joined", %{position: position, user: user})
      {:ok, state} = TicTacToe.Server.state(server)
      push(socket, "state", jsonify(state))
      socket
    end
    {:ok, socket
          |> Socket.assign(:server, server)
          |> Socket.assign(:user, user)}
  end

  def handle_in("play", [x, y], socket) do
    case TicTacToe.Server.play(socket.assigns[:server], {x,y}, socket.assigns[:user]) do
      {:ok, state} ->
        broadcast!(socket, "state", jsonify(state))
        {:noreply, socket}
      {:error, errors} ->
        {:reply, {:error, errors}, socket}
    end
  end

  def handle_in("ping", _, socket) do
    {:reply, TicTacToe.Server.ping(socket.assigns.server), socket}
  end

  def handle_in("restart", _, socket) do
    case TicTacToe.Server.restart(socket.assigns.server) do
      {:ok, state} ->
        broadcast!(socket, "state", jsonify(state))
        {:noreply, socket}
      {:error, errors} ->
        {:reply, {:error, errors}, socket}
    end
  end

  defp after_join(fun) do
    send(self, {:after_join, fun})
  end

  def handle_info({:after_join, fun}, socket) do
    {:noreply, fun.(socket)}
  end

  defp find_server(game_id) do
    {:ok, pid} = TicTacToe.Server.find_or_create(game_id)
    pid
  end

  defp find_user(auth_message) do
    #TODO
    auth_message["name"]
  end

  defp jsonify(state) do
    {{a,b,c},{d,e,f},{g,h,i}} = state.board
    %{state| board: [[a,b,c],[d,e,f],[g,h,i]]}
  end
end
