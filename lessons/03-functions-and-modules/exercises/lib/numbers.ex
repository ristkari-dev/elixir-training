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
  def classify(_n), do: raise("TODO: three clauses with `when` guards")
end
