defmodule MapMerge do
  @moduledoc "Recursive deep merge of two maps."

  @doc """
  Merge two maps recursively. When both maps have a value for the same
  key AND both values are themselves maps, recurse. Otherwise, the
  second map's value wins.

      iex> MapMerge.deep(%{a: 1, b: %{c: 2}}, %{b: %{d: 3}, e: 4})
      %{a: 1, b: %{c: 2, d: 3}, e: 4}
  """
  def deep(_a, _b), do: raise("TODO: Map.merge/3 with merger that recurses on map-map conflicts")
end
