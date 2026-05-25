defmodule Pairs do
  @moduledoc "Tuple-destructuring drills for lesson 02."

  @doc """
  Return the first element of a two-tuple.

      iex> Pairs.first({1, 2})
      1
  """
  def first({a, _}), do: a

  @doc """
  Return the second element of a two-tuple.

      iex> Pairs.second({1, 2})
      2
  """
  def second({_, b}), do: b
end
