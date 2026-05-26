defmodule Lists do
  @moduledoc "Enum drills for lesson 06."

  @doc """
  Return a new list with each element doubled.

      iex> Lists.doubled([1, 2, 3])
      [2, 4, 6]
  """
  def doubled(_list), do: raise("TODO: Enum.map with &(&1 * 2)")

  @doc """
  Return only the even integers from the list.

      iex> Lists.evens([1, 2, 3, 4])
      [2, 4]
  """
  def evens(_list), do: raise("TODO: Enum.filter with a rem/2 predicate")

  @doc """
  Sum the list of integers.

      iex> Lists.sum([1, 2, 3])
      6
  """
  def sum(_list), do: raise("TODO: Enum.reduce with 0 and &+/2")
end
