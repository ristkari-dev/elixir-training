defmodule PickTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pick.first_match/2 returns the first matching element" do
    assert Pick.first_match([1, 2, 3, 4], &(&1 > 2)) == 3
  end

  @tag :pending
  test "Pick.first_match/2 returns nil when no element matches" do
    assert Pick.first_match([1, 2, 3], &(&1 > 99)) == nil
  end

  @tag :pending
  test "Pick.first_match/2 returns nil for an empty list" do
    assert Pick.first_match([], fn _ -> true end) == nil
  end

  @tag :pending
  test "Pick.first_match/2 works with anonymous fn form too" do
    assert Pick.first_match([1, 2, 3], fn x -> x == 2 end) == 2
  end
end
