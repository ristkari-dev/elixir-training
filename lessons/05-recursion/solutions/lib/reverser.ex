defmodule Reverser do
  @moduledoc "Reverse a list using an accumulator helper."

  @doc """
  Reverse a list using the accumulator pattern.

      iex> Reverser.reverse([1, 2, 3])
      [3, 2, 1]
      iex> Reverser.reverse([])
      []
  """
  def reverse(list), do: do_reverse(list, [])

  defp do_reverse([], acc), do: acc
  defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
end
