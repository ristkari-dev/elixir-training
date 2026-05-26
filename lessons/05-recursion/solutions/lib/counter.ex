defmodule Counter do
  @moduledoc "Recursive length over a list."
  import Kernel, except: [length: 1]

  @doc """
  Count the elements of a list without using `Kernel.length/1`.

      iex> Counter.length([:a, :b, :c])
      3
      iex> Counter.length([])
      0
  """
  def length([]), do: 0
  def length([_ | t]), do: 1 + length(t)
end
