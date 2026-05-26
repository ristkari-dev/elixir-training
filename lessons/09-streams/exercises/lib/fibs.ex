defmodule Fibs do
  @moduledoc "Fibonacci stream — first N numbers."

  @doc """
  Return the first n Fibonacci numbers starting from 0, 1, 1, 2, 3, ...

      iex> Fibs.take(6)
      [0, 1, 1, 2, 3, 5]
  """
  def take(_n), do: raise("TODO: Stream.iterate over {a, b} pairs, take n, map elem(&1, 0)")
end
