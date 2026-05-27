defmodule Freq do
  @moduledoc "Build a frequency map from a list."

  @doc """
  Count how many times each element appears in the list.

      iex> Freq.count(["a", "b", "a", "c", "b", "a"])
      %{"a" => 3, "b" => 2, "c" => 1}
  """
  def count(_list), do: raise("TODO: Enum.reduce into a map; use Map.update with default 1")
end
