defmodule Naturals do
  @moduledoc "Stream the natural numbers; filter and bound."

  @doc """
  Return all even naturals strictly less than `bound`, in ascending order.

      iex> Naturals.evens_below(10)
      [0, 2, 4, 6, 8]
  """
  def evens_below(_bound),
    do: raise("TODO: Stream.iterate +1, filter even, take_while < bound, Enum.to_list")
end
