defmodule Wargames.TicTacToe do
  def create() do
    :crypto.strong_rand_bytes(24)
    |> Base.url_encode64()
    |> create()
  end

  def create(game_id) do
    case GenServer.start(__MODULE__.Server, game_id, name: name(game_id)) do
      {:ok, _} -> {:ok, game_id}
      {:error, {:already_started, _}} -> {:ok, game_id}
    end
  end

  def subscribe(game_id) do
    Phoenix.PubSub.subscribe(Wargames.PubSub, "tictactoe:#{game_id}")
  end

  def unsubscribe(game_id) do
    Phoenix.PubSub.unsubscribe(Wargames.PubSub, "tictactoe:#{game_id}")
  end

  def play(game_id, position, player), do: call(game_id, {:play, position, player})
  def ping(game_id), do: call(game_id, :ping)
  def state(game_id), do: call(game_id, :state)
  def restart(game_id), do: call(game_id, :restart)
  def join(game_id, player) when is_binary(player), do: call(game_id, {:join, player})

  defp call(game_id, message), do: GenServer.call(name(game_id), message)
  defp name(game_id), do: {:global, {__MODULE__, game_id}}
end
