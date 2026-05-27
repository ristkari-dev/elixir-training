defmodule Lists do
  @moduledoc "Enum drills for lesson 06."

  @doc """
  Return a new list with each element doubled.

      iex> Lists.doubled([1, 2, 3])
      [2, 4, 6]
  """
  def doubled(list), do: Enum.map(list, &(&1 * 2))

  @doc """
  Return only the even integers from the list.

      iex> Lists.evens([1, 2, 3, 4])
      [2, 4]
  """
  def evens(list), do: Enum.filter(list, &(rem(&1, 2) == 0))

  @doc """
  Sum the list of integers.

      iex> Lists.sum([1, 2, 3])
      6
  """
  def sum(list), do: Enum.reduce(list, 0, &+/2)
end
