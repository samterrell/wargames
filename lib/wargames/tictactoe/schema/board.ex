defmodule Wargames.TicTacToe.Board do
  def new do
    {__MODULE__, nil, nil, nil, nil, nil, nil, nil, nil, nil}
  end

  def get({__MODULE__, v, _, _, _, _, _, _, _, _}, {0, 0}), do: v
  def get({__MODULE__, _, v, _, _, _, _, _, _, _}, {0, 1}), do: v
  def get({__MODULE__, _, _, v, _, _, _, _, _, _}, {0, 2}), do: v
  def get({__MODULE__, _, _, _, v, _, _, _, _, _}, {1, 0}), do: v
  def get({__MODULE__, _, _, _, _, v, _, _, _, _}, {1, 1}), do: v
  def get({__MODULE__, _, _, _, _, _, v, _, _, _}, {1, 2}), do: v
  def get({__MODULE__, _, _, _, _, _, _, v, _, _}, {2, 0}), do: v
  def get({__MODULE__, _, _, _, _, _, _, _, v, _}, {2, 1}), do: v
  def get({__MODULE__, _, _, _, _, _, _, _, _, v}, {2, 2}), do: v

  def valid_value?(:x), do: true
  def valid_value?(:o), do: true
  def valid_value?(_), do: false

  def valid_position?({0, 0}), do: true
  def valid_position?({0, 1}), do: true
  def valid_position?({0, 2}), do: true
  def valid_position?({1, 0}), do: true
  def valid_position?({1, 1}), do: true
  def valid_position?({1, 2}), do: true
  def valid_position?({2, 0}), do: true
  def valid_position?({2, 1}), do: true
  def valid_position?({2, 2}), do: true
  def valid_position?({_, _}), do: false

  def winner({__MODULE__, x, _, _, _, x, _, _, _, x}) when not is_nil(x), do: x
  def winner({__MODULE__, _, _, x, _, x, _, x, _, _}) when not is_nil(x), do: x
  def winner({__MODULE__, x, x, x, _, _, _, _, _, _}) when not is_nil(x), do: x
  def winner({__MODULE__, _, _, _, x, x, x, _, _, _}) when not is_nil(x), do: x
  def winner({__MODULE__, _, _, _, _, _, _, x, x, x}) when not is_nil(x), do: x
  def winner({__MODULE__, x, _, _, x, _, _, x, _, _}) when not is_nil(x), do: x
  def winner({__MODULE__, _, x, _, _, x, _, _, x, _}) when not is_nil(x), do: x
  def winner({__MODULE__, _, _, x, _, _, x, _, _, x}) when not is_nil(x), do: x
  def winner({__MODULE__, nil, _, _, _, _, _, _, _, _}), do: nil
  def winner({__MODULE__, _, nil, _, _, _, _, _, _, _}), do: nil
  def winner({__MODULE__, _, _, nil, _, _, _, _, _, _}), do: nil
  def winner({__MODULE__, _, _, _, nil, _, _, _, _, _}), do: nil
  def winner({__MODULE__, _, _, _, _, nil, _, _, _, _}), do: nil
  def winner({__MODULE__, _, _, _, _, _, nil, _, _, _}), do: nil
  def winner({__MODULE__, _, _, _, _, _, _, nil, _, _}), do: nil
  def winner({__MODULE__, _, _, _, _, _, _, _, nil, _}), do: nil
  def winner({__MODULE__, _, _, _, _, _, _, _, _, nil}), do: nil
  def winner({__MODULE__, _, _, _, _, _, _, _, _, _}), do: :draw

  def put({__MODULE__, nil, b, c, d, e, f, g, h, i}, {0, 0}, v) when v in [:x, :o],
    do: {__MODULE__, v, b, c, d, e, f, g, h, i}

  def put({__MODULE__, a, nil, c, d, e, f, g, h, i}, {0, 1}, v) when v in [:x, :o],
    do: {__MODULE__, a, v, c, d, e, f, g, h, i}

  def put({__MODULE__, a, b, nil, d, e, f, g, h, i}, {0, 2}, v) when v in [:x, :o],
    do: {__MODULE__, a, b, v, d, e, f, g, h, i}

  def put({__MODULE__, a, b, c, nil, e, f, g, h, i}, {1, 0}, v) when v in [:x, :o],
    do: {__MODULE__, a, b, c, v, e, f, g, h, i}

  def put({__MODULE__, a, b, c, d, nil, f, g, h, i}, {1, 1}, v) when v in [:x, :o],
    do: {__MODULE__, a, b, c, d, v, f, g, h, i}

  def put({__MODULE__, a, b, c, d, e, nil, g, h, i}, {1, 2}, v) when v in [:x, :o],
    do: {__MODULE__, a, b, c, d, e, v, g, h, i}

  def put({__MODULE__, a, b, c, d, e, f, nil, h, i}, {2, 0}, v) when v in [:x, :o],
    do: {__MODULE__, a, b, c, d, e, f, v, h, i}

  def put({__MODULE__, a, b, c, d, e, f, g, nil, i}, {2, 1}, v) when v in [:x, :o],
    do: {__MODULE__, a, b, c, d, e, f, g, v, i}

  def put({__MODULE__, a, b, c, d, e, f, g, h, nil}, {2, 2}, v) when v in [:x, :o],
    do: {__MODULE__, a, b, c, d, e, f, g, h, v}
end
