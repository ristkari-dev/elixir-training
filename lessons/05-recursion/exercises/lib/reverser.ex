defmodule Reverser do
  @moduledoc "Reverse a list using an accumulator helper."

  @doc """
  Reverse a list using the accumulator pattern.

      iex> Reverser.reverse([1, 2, 3])
      [3, 2, 1]
      iex> Reverser.reverse([])
      []
  """
  def reverse(_list), do: raise("TODO: delegate to do_reverse/2 with empty accumulator")
end
