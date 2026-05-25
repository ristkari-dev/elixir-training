defmodule Sign do
  @moduledoc "Sign-classification drill for lesson 04 — using cond."

  @doc """
  Classify a number's sign using cond.

      iex> Sign.of(-3)
      :negative
      iex> Sign.of(0)
      :zero
      iex> Sign.of(7)
      :positive
  """
  def of(n) do
    cond do
      n < 0 -> :negative
      n == 0 -> :zero
      true -> :positive
    end
  end
end
