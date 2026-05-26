defmodule Freq do
  @moduledoc "Build a frequency map from a list."

  @doc """
  Count how many times each element appears in the list.

      iex> Freq.count(["a", "b", "a", "c", "b", "a"])
      %{"a" => 3, "b" => 2, "c" => 1}
  """
  def count(list) do
    Enum.reduce(list, %{}, fn item, acc -> Map.update(acc, item, 1, &(&1 + 1)) end)
  end
end
