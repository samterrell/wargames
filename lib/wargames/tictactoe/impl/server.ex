defmodule Wargames.TicTacToe.Server do
  use GenServer

  @timeout Application.get_env(:wargames, Wargames.TicTacToe)[:timeout]

  defstruct id: nil,
            turn: :x,
            winner: nil,
            x: nil,
            o: nil,
            board: {nil, nil, nil, nil, nil, nil, nil, nil, nil}

  @impl GenServer
  def init(game_id), do: {:ok, %__MODULE__{id: game_id}, @timeout}

  @impl GenServer
  def handle_info(:timeout, state) do
    broadcast(state, :shutdown)
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_call({:join, player}, _from, state = %{x: player}) do
    {:reply, {:ok, :x}, state, @timeout}
  end

  @impl GenServer
  def handle_call({:join, player}, _from, state = %{x: nil}) do
    state = %{state | x: player}
    broadcast(state, :updated)
    {:reply, {:ok, :x}, state, @timeout}
  end

  @impl GenServer
  def handle_call({:join, player}, _from, state = %{o: player}) do
    {:reply, {:ok, :o}, state, @timeout}
  end

  @impl GenServer
  def handle_call({:join, player}, _from, state = %{o: nil}) do
    state = %{state | o: player}
    broadcast(state, :updated)
    {:reply, {:ok, :o}, state, @timeout}
  end

  @impl GenServer
  def handle_call({:join, _}, _from, state), do: {:reply, {:error, :game_full}, state, @timeout}

  @impl GenServer
  def handle_call(:ping, _, state), do: {:reply, {:ok, :pong}, state, @timeout}

  @impl GenServer
  def handle_call(:state, _, state), do: {:reply, {:ok, state}, state, @timeout}

  @impl GenServer
  def handle_call({:play, position, player}, _from, state) do
    cond do
      state.turn == :x and player != state.x ->
        {:reply, {:error, :not_your_turn}, state, @timeout}

      state.turn == :y and player != state.y ->
        {:reply, {:error, :not_your_turn}, state, @timeout}

      !valid_position?(position) ->
        {:reply, {:error, :invalid_position}, state, @timeout}

      not is_nil(value_at(state.board, position)) ->
        {:reply, {:error, :position_taken}, state, @timeout}

      not is_nil(state.winner) ->
        {:reply, {:error, :game_over}, state, @timeout}

      true ->
        board = update_at(state.board, position, state.turn)
        winner = winner(board)
        turn = unless winner, do: next_turn(state.turn)
        state = %{state | board: board, turn: turn, winner: winner(board)}
        broadcast(state, :updated)
        {:reply, :ok, state, @timeout}
    end
  end

  @impl GenServer
  def handle_call(:restart, _, state) do
    if is_nil(state.winner) do
      {:reply, {:error, :game_in_progress}, state, @timeout}
    else
      state = %__MODULE__{x: state.o, o: state.x, id: state.id}
      broadcast(state, :updated)
      {:reply, {:ok, state}, state, @timeout}
    end
  end

  defp next_turn(nil), do: :x
  defp next_turn(:x), do: :o
  defp next_turn(:o), do: :x

  defp value_at({v, _, _, _, _, _, _, _, _}, {0, 0}), do: v
  defp value_at({_, v, _, _, _, _, _, _, _}, {0, 1}), do: v
  defp value_at({_, _, v, _, _, _, _, _, _}, {0, 2}), do: v
  defp value_at({_, _, _, v, _, _, _, _, _}, {1, 0}), do: v
  defp value_at({_, _, _, _, v, _, _, _, _}, {1, 1}), do: v
  defp value_at({_, _, _, _, _, v, _, _, _}, {1, 2}), do: v
  defp value_at({_, _, _, _, _, _, v, _, _}, {2, 0}), do: v
  defp value_at({_, _, _, _, _, _, _, v, _}, {2, 1}), do: v
  defp value_at({_, _, _, _, _, _, _, _, v}, {2, 2}), do: v

  defp winner({x, _, _, _, x, _, _, _, x}) when not is_nil(x), do: x
  defp winner({_, _, x, _, x, _, x, _, _}) when not is_nil(x), do: x
  defp winner({x, x, x, _, _, _, _, _, _}) when not is_nil(x), do: x
  defp winner({_, _, _, x, x, x, _, _, _}) when not is_nil(x), do: x
  defp winner({_, _, _, _, _, _, x, x, x}) when not is_nil(x), do: x
  defp winner({x, _, _, x, _, _, x, _, _}) when not is_nil(x), do: x
  defp winner({_, x, _, _, x, _, _, x, _}) when not is_nil(x), do: x
  defp winner({_, _, x, _, _, x, _, _, x}) when not is_nil(x), do: x
  defp winner({nil, _, _, _, _, _, _, _, _}), do: nil
  defp winner({_, nil, _, _, _, _, _, _, _}), do: nil
  defp winner({_, _, nil, _, _, _, _, _, _}), do: nil
  defp winner({_, _, _, nil, _, _, _, _, _}), do: nil
  defp winner({_, _, _, _, nil, _, _, _, _}), do: nil
  defp winner({_, _, _, _, _, nil, _, _, _}), do: nil
  defp winner({_, _, _, _, _, _, nil, _, _}), do: nil
  defp winner({_, _, _, _, _, _, _, nil, _}), do: nil
  defp winner({_, _, _, _, _, _, _, _, nil}), do: nil
  defp winner({_, _, _, _, _, _, _, _, _}), do: :draw

  defp valid_position?({0, 0}), do: true
  defp valid_position?({0, 1}), do: true
  defp valid_position?({0, 2}), do: true
  defp valid_position?({1, 0}), do: true
  defp valid_position?({1, 1}), do: true
  defp valid_position?({1, 2}), do: true
  defp valid_position?({2, 0}), do: true
  defp valid_position?({2, 1}), do: true
  defp valid_position?({2, 2}), do: true
  defp valid_position?({_, _}), do: false

  defp update_at({nil, b, c, d, e, f, g, h, i}, {0, 0}, v), do: {v, b, c, d, e, f, g, h, i}
  defp update_at({a, nil, c, d, e, f, g, h, i}, {0, 1}, v), do: {a, v, c, d, e, f, g, h, i}
  defp update_at({a, b, nil, d, e, f, g, h, i}, {0, 2}, v), do: {a, b, v, d, e, f, g, h, i}
  defp update_at({a, b, c, nil, e, f, g, h, i}, {1, 0}, v), do: {a, b, c, v, e, f, g, h, i}
  defp update_at({a, b, c, d, nil, f, g, h, i}, {1, 1}, v), do: {a, b, c, d, v, f, g, h, i}
  defp update_at({a, b, c, d, e, nil, g, h, i}, {1, 2}, v), do: {a, b, c, d, e, v, g, h, i}
  defp update_at({a, b, c, d, e, f, nil, h, i}, {2, 0}, v), do: {a, b, c, d, e, f, v, h, i}
  defp update_at({a, b, c, d, e, f, g, nil, i}, {2, 1}, v), do: {a, b, c, d, e, f, g, v, i}
  defp update_at({a, b, c, d, e, f, g, h, nil}, {2, 2}, v), do: {a, b, c, d, e, f, g, h, v}

  defp broadcast(state, :updated) do
    Phoenix.PubSub.broadcast(
      Wargames.PubSub,
      "tictactoe:#{state.id}",
      {:updated, state.id, state}
    )
  end

  defp broadcast(state, :shutdown) do
    Phoenix.PubSub.broadcast(
      Wargames.PubSub,
      "tictactoe:#{state.id}",
      {:shutdown, state.id}
    )
  end
end
