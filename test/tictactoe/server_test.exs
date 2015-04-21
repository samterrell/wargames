defmodule TicTacToe.ServerTest do
  use ExUnit.Case, async: true

  defp random_id, do: :crypto.rand_bytes(33) |> Base.url_encode64

  test "creating a server" do
    {:ok, pid} = TicTacToe.Server.find_or_create(random_id)
    {:ok, other} = TicTacToe.Server.find_or_create(random_id)
    assert pid != other
  end

  test "finding a server" do
    id = random_id
    {:ok, pid} = TicTacToe.Server.find_or_create(id)
    {:ok, other} = TicTacToe.Server.find_or_create(id)
    assert pid == other
  end

  test "joining a server" do
    {:ok, pid} = TicTacToe.Server.find_or_create(random_id)
    assert {:ok, :x} == TicTacToe.Server.join(pid, "player1")
    assert {:ok, :x} == TicTacToe.Server.join(pid, "player1")
    assert {:ok, :o} == TicTacToe.Server.join(pid, "player2")
    assert {:error, :game_full} == TicTacToe.Server.join(pid, "player3")
  end

  test "playing a game" do
    {:ok, pid} = TicTacToe.Server.find_or_create(random_id)
    TicTacToe.Server.join(pid, "player1")
    TicTacToe.Server.join(pid, "player2")
    {:ok, state} = TicTacToe.Server.play(pid, {0, 0}, "player1")
    assert state[:board] == {{:x, nil, nil}, {nil, nil, nil}, {nil, nil, nil}}
    {:ok, state} = TicTacToe.Server.play(pid, {1, 1}, "player2")
    assert state[:board] == {{:x, nil, nil}, {nil, :o, nil}, {nil, nil, nil}}
    {:error, errors} = TicTacToe.Server.play(pid, {1, 1}, "player1")
    assert errors == [:position_taken]
    {:error, errors} = TicTacToe.Server.play(pid, {-1, 1}, "player1")
    assert errors == [:invalid_position]
    {:error, errors} = TicTacToe.Server.play(pid, {2, 2}, "player3")
    assert errors == [:not_your_turn]
    {:error, errors} = TicTacToe.Server.play(pid, {2, 2}, "player2")
    assert errors == [:not_your_turn]
    {:ok, state} = TicTacToe.Server.play(pid, {2, 2}, "player1")
    assert state[:board] == {{:x, nil, nil}, {nil, :o, nil}, {nil, nil, :x}}
    {:ok, state} = TicTacToe.Server.play(pid, {0, 2}, "player2")
    assert state[:board] == {{:x, nil, :o}, {nil, :o, nil}, {nil, nil, :x}}
    {:ok, state} = TicTacToe.Server.play(pid, {2, 0}, "player1")
    assert state[:board] == {{:x, nil, :o}, {nil, :o, nil}, {:x, nil, :x}}
    {:ok, state} = TicTacToe.Server.play(pid, {1, 0}, "player2")
    assert state[:board] == {{:x, nil, :o}, {:o, :o, nil}, {:x, nil, :x}}
    assert state[:winner] == nil
    {:ok, state} = TicTacToe.Server.play(pid, {2, 1}, "player1")
    assert state[:board] == {{:x, nil, :o}, {:o, :o, nil}, {:x, :x, :x}}
    assert state[:winner] == :x
    {:error, errors} = TicTacToe.Server.play(pid, {1, 2}, "player2")
    assert errors == [:game_over]

    {:ok, pid} = TicTacToe.Server.find_or_create(random_id)
    {:ok, _} = TicTacToe.Server.join(pid, "player1")
    {:ok, _} = TicTacToe.Server.join(pid, "player2")
    {:ok, _} = TicTacToe.Server.play(pid, {0, 0}, "player1")
    {:ok, _} = TicTacToe.Server.play(pid, {0, 1}, "player2")
    {:ok, _} = TicTacToe.Server.play(pid, {0, 2}, "player1")
    {:ok, _} = TicTacToe.Server.play(pid, {1, 1}, "player2")
    {:ok, _} = TicTacToe.Server.play(pid, {1, 2}, "player1")
    {:ok, _} = TicTacToe.Server.play(pid, {1, 0}, "player2")
    {:ok, _} = TicTacToe.Server.play(pid, {2, 1}, "player1")
    {:ok, _} = TicTacToe.Server.play(pid, {2, 2}, "player2")
    {:ok, state} = TicTacToe.Server.play(pid, {2, 0}, "player1")
    assert state[:board] == {{:x, :o, :x}, {:o, :o, :x}, {:x, :x, :o}}
    assert state[:winner] == :draw
    {:error, errors} = TicTacToe.Server.play(pid, {0, 0}, "player3")
    assert :game_over in errors
    assert :not_your_turn in errors
    assert :position_taken in errors
    assert length(errors) == 3
  end

  test "games time out unless pinged" do
    timeout = Application.get_env(:tictactoe, :timeout)
    id = random_id
    {:ok, pid} = TicTacToe.Server.find_or_create(id)
    TicTacToe.Server.join(pid, "player1")
    {:ok, state} = TicTacToe.Server.state(pid)
    assert state[:x] == "player1"
    :timer.sleep(div(timeout, 2))
    TicTacToe.Server.ping(pid)
    :timer.sleep(div(timeout, 2))
    TicTacToe.Server.ping(pid)
    :timer.sleep(div(timeout, 2))
    {:ok, state} = TicTacToe.Server.state(pid)
    assert state[:x] == "player1"
    :timer.sleep(timeout + 100)
    {:ok, pid} = TicTacToe.Server.find_or_create(id)
    {:ok, state} = TicTacToe.Server.state(pid)
    assert state[:x] == nil
  end
end
