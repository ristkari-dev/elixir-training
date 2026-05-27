defmodule FreqTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Freq.count/1 counts occurrences" do
    assert Freq.count(["a", "b", "a"]) == %{"a" => 2, "b" => 1}
  end

  @tag :pending
  test "Freq.count/1 returns an empty map for an empty list" do
    assert Freq.count([]) == %{}
  end

  @tag :pending
  test "Freq.count/1 works with atoms" do
    assert Freq.count([:x, :y, :x, :x]) == %{x: 3, y: 1}
  end
end
