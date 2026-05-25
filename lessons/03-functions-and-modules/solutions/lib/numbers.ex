defmodule Numbers do
  @moduledoc "Guarded classification drill for lesson 03."

  @doc """
  Classify a number as :negative, :zero, or :positive.

      iex> Numbers.classify(-3)
      :negative
      iex> Numbers.classify(0)
      :zero
      iex> Numbers.classify(7)
      :positive
  """
  def classify(n) when n < 0, do: :negative
  def classify(0), do: :zero
  def classify(n) when n > 0, do: :positive
end
