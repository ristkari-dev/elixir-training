defmodule PairsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pairs.first/1 returns the first element" do
    assert Pairs.first({"a", "b"}) == "a"
  end

  @tag :pending
  test "Pairs.first/1 works with integers" do
    assert Pairs.first({1, 2}) == 1
  end

  @tag :pending
  test "Pairs.second/1 returns the second element" do
    assert Pairs.second({"a", "b"}) == "b"
  end

  @tag :pending
  test "Pairs.second/1 works with integers" do
    assert Pairs.second({1, 2}) == 2
  end
end
