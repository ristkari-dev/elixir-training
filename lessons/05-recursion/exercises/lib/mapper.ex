defmodule Mapper do
  @moduledoc "Recursive map over a list, doubling each element."

  @doc """
  Return a new list with each element doubled.

      iex> Mapper.double_all([1, 2, 3])
      [2, 4, 6]
      iex> Mapper.double_all([])
      []
  """
  def double_all(_list), do: raise("TODO: prepend h*2 to the recursive call on the tail")
end
