defmodule Sum do
  @moduledoc "Recursive sum over a list of integers."

  @doc """
  Sum a list of integers using head/tail recursion.

      iex> Sum.of([1, 2, 3])
      6
      iex> Sum.of([])
      0
  """
  def of(_list), do: raise("TODO: base case [] returns 0, recursive case sums h + of(t)")
end
