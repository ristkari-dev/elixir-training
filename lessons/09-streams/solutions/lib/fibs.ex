defmodule Fibs do
  @moduledoc "Fibonacci stream — first N numbers."

  @doc """
  Return the first n Fibonacci numbers starting from 0, 1, 1, 2, 3, ...

      iex> Fibs.take(6)
      [0, 1, 1, 2, 3, 5]
  """
  def take(n) do
    {0, 1}
    |> Stream.iterate(fn {a, b} -> {b, a + b} end)
    |> Enum.take(n)
    |> Enum.map(&elem(&1, 0))
  end
end
