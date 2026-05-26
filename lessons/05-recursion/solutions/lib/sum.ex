defmodule Sum do
  @moduledoc "Recursive sum over a list of integers."

  @doc """
  Sum a list of integers using head/tail recursion.

      iex> Sum.of([1, 2, 3])
      6
      iex> Sum.of([])
      0
  """
  def of([]), do: 0
  def of([h | t]), do: h + of(t)
end
