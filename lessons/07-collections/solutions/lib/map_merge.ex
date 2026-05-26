defmodule MapMerge do
  @moduledoc "Recursive deep merge of two maps."

  @doc """
  Merge two maps recursively. When both maps have a value for the same
  key AND both values are themselves maps, recurse. Otherwise, the
  second map's value wins.

      iex> MapMerge.deep(%{a: 1, b: %{c: 2}}, %{b: %{d: 3}, e: 4})
      %{a: 1, b: %{c: 2, d: 3}, e: 4}
  """
  def deep(a, b) do
    Map.merge(a, b, fn _k, v1, v2 ->
      if is_map(v1) and is_map(v2), do: deep(v1, v2), else: v2
    end)
  end
end
