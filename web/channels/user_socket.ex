defmodule Wargames.UserSocket do
  use Phoenix.Socket
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  channel "tictactoe:*", Wargames.TicTacToeChannel


  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
