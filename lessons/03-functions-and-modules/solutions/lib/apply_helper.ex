defmodule ApplyHelper do
  @moduledoc "Higher-order drill for lesson 03 — applies a function twice."

  @doc """
  Call `f` on `x`, then call `f` on the result.

      iex> ApplyHelper.twice(fn x -> x + 1 end, 0)
      2
      iex> ApplyHelper.twice(&(&1 * 2), 3)
      12
  """
  def twice(f, x), do: f.(f.(x))
end
