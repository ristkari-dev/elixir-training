defmodule Pick do
  @moduledoc "First-match drill — anonymous functions inside case."

  @doc """
  Return the first element of `list` for which `pred.(element)` is true.
  If no element matches, return nil.

      iex> Pick.first_match([1, 2, 3, 4], &(&1 > 2))
      3
      iex> Pick.first_match([1, 2, 3], &(&1 > 99))
      nil
  """
  def first_match(_list, _pred), do: raise("TODO: head-tail recursion + case on pred.(head)")
end
