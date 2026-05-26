defmodule Naturals do
  @moduledoc "Stream the natural numbers; filter and bound."

  @doc """
  Return all even naturals strictly less than `bound`, in ascending order.

      iex> Naturals.evens_below(10)
      [0, 2, 4, 6, 8]
  """
  def evens_below(bound) do
    0
    |> Stream.iterate(&(&1 + 1))
    |> Stream.filter(&(rem(&1, 2) == 0))
    |> Stream.take_while(&(&1 < bound))
    |> Enum.to_list()
  end
end
