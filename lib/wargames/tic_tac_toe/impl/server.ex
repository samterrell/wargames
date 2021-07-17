defmodule Wargames.TicTacToe.Server do
  use GenServer
  alias Wargames.TicTacToe.Board

  @timeout Application.get_env(:wargames, Wargames.TicTacToe)[:timeout]

  defstruct id: nil,
            turn: :x,
            winner: nil,
            x: nil,
            o: nil,
            board: Board.new()

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

      !Board.valid_position?(position) ->
        {:reply, {:error, :invalid_position}, state, @timeout}

      not is_nil(Board.get(state.board, position)) ->
        {:reply, {:error, :position_taken}, state, @timeout}

      not is_nil(state.winner) ->
        {:reply, {:error, :game_over}, state, @timeout}

      true ->
        board = Board.put(state.board, position, state.turn)
        winner = Board.winner(board)
        turn = unless winner, do: next_turn(state.turn)
        state = %{state | board: board, turn: turn, winner: winner}
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
