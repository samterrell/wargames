defmodule TicTacToe.Server do
  use GenServer

  @timeout Application.get_env(:tictactoe, :timeout)

  @derive [Access]
  defstruct turn: :x, winner: nil, x: nil, o: nil,
            board: {{nil, nil, nil},
                    {nil, nil, nil},
                    {nil, nil, nil}}
  @type t :: %TicTacToe.Server{turn: atom, winner: atom, board: tuple, x: String.t, o: String.t}

  # Client

  def find_or_create(game_id) do
    name = {:global, {__MODULE__, game_id}}
    case GenServer.start(__MODULE__, nil, name: name) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      status -> status
    end
  end

  def play(pid, position, player), do: GenServer.call(pid, {:play, position, player})

  def ping(pid), do: GenServer.call(pid, :ping)

  def state(pid), do: GenServer.call(pid, :state)

  def join(pid, player) when player != nil, do: GenServer.call(pid, {:join, player})

  # Server

  def init(_args), do: {:ok, %TicTacToe.Server{}, @timeout}

  def handle_info(:timeout, state), do: {:stop, :normal, state}

  def handle_call({:join, player}, _from, state) do
    if !state.x  || state.x == player do
      state = %{state | x: player}
      {:reply, {:ok, :x}, state, @timeout}
    else
      if !state.o || state.o == player do
        state = %{state | o: player}
        {:reply, {:ok, :o}, state, @timeout}
      else
        {:reply, {:error, :game_full}, state, @timeout}
      end
    end
  end

  def handle_call(:ping, _, state), do: {:reply, {:ok, :pong}, state, @timeout}

  def handle_call(:state, _, state), do: {:reply, {:ok, state}, state, @timeout}

  def handle_call({:play, position, player}, _from, state) do
    errors = []
    if !valid_position?(position) do
      errors = [:invalid_position | errors]
    else
      if value_at(state.board, position) != nil, do: errors = [:position_taken | errors]
    end
    if player != state[state.turn], do: errors = [:not_your_turn | errors]
    if state.winner, do: errors = [:game_over | errors]
    if errors == [] do
      board = update_at(state.board, position, state.turn)
      turn = next_turn(state.turn)
      state = %{state | board: board, turn: turn, winner: winner(board)}
      {:reply, {:ok, state}, state, @timeout}
    else
      {:reply, {:error, errors}, state, @timeout}
    end
  end

  # Library

  defp next_turn(:x), do: :o
  defp next_turn(:o), do: :x

  defp value_at(board, {x, y}), do: elem(board, x) |> elem(y)

  # Pattern matching for great justice.
  defp winner({{x, _, _},
               {_, x, _},
               {_, _, x}}) when is_atom(x), do: x
  defp winner({{_, _, x},
               {_, x, _},
               {x, _, _}}) when is_atom(x), do: x
  defp winner({{x, x, x},
               {_, _, _},
               {_, _, _}}) when is_atom(x), do: x
  defp winner({{_, _, _},
               {x, x, x},
               {_, _, _}}) when is_atom(x), do: x
  defp winner({{_, _, _},
               {_, _, _},
               {x, x, x}}) when is_atom(x), do: x
  defp winner({{x, _, _},
               {x, _, _},
               {x, _, _}}) when is_atom(x), do: x
  defp winner({{_, x, _},
               {_, x, _},
               {_, x, _}}) when is_atom(x), do: x
  defp winner({{_, _, x},
               {_, _, x},
               {_, _, x}}) when is_atom(x), do: x
  defp winner({{a, b, c}, {d, e, f}, {g, h, i}}) do
    # if nothing is nil, must be a draw
    a && b && c && d && e && f && g && h && i && :draw
  end

  defp valid_position?({x, y}), do: x in 0..2 && y in 0..2

  defp update_at(board, {x, y}, value), do: put_elem(board, x, elem(board, x) |> put_elem(y, value))
end
