defmodule ReverserTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Reverser.reverse/1 reverses a non-empty list" do
    assert Reverser.reverse([1, 2, 3]) == [3, 2, 1]
  end

  @tag :pending
  test "Reverser.reverse/1 returns [] for the empty list" do
    assert Reverser.reverse([]) == []
  end

  @tag :pending
  test "Reverser.reverse/1 handles a singleton" do
    assert Reverser.reverse([:only]) == [:only]
  end
end
