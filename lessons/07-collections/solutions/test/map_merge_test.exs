defmodule MapMergeTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "MapMerge.deep/2 merges top-level keys" do
    assert MapMerge.deep(%{a: 1}, %{b: 2}) == %{a: 1, b: 2}
  end

  @tag :pending
  test "MapMerge.deep/2 recurses on nested maps" do
    assert MapMerge.deep(%{a: %{b: 1}}, %{a: %{c: 2}}) == %{a: %{b: 1, c: 2}}
  end

  @tag :pending
  test "MapMerge.deep/2 lets the second map override a non-map value" do
    assert MapMerge.deep(%{a: 1}, %{a: 2}) == %{a: 2}
  end

  @tag :pending
  test "MapMerge.deep/2 handles mixed nested and flat" do
    assert MapMerge.deep(%{a: 1, b: %{c: 2}}, %{b: %{d: 3}, e: 4}) ==
             %{a: 1, b: %{c: 2, d: 3}, e: 4}
  end
end
