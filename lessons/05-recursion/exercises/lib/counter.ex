defmodule Counter do
  @moduledoc "Recursive length over a list."

  # Elixir auto-imports Kernel.length/1. We're defining our own length/1,
  # so we explicitly opt out of the import for this one function.
  import Kernel, except: [length: 1]

  @doc """
  Count the elements of a list without using `Kernel.length/1`.

      iex> Counter.length([:a, :b, :c])
      3
      iex> Counter.length([])
      0
  """
  def length(_list), do: raise("TODO: base [] -> 0; recursive [_ | t] -> 1 + length(t)")
end
