defmodule ListsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Lists.doubled/1 doubles each element" do
    assert Lists.doubled([1, 2, 3]) == [2, 4, 6]
  end

  @tag :pending
  test "Lists.doubled/1 returns [] for an empty list" do
    assert Lists.doubled([]) == []
  end

  @tag :pending
  test "Lists.evens/1 returns only even integers" do
    assert Lists.evens([1, 2, 3, 4, 5, 6]) == [2, 4, 6]
  end

  @tag :pending
  test "Lists.evens/1 returns [] when none are even" do
    assert Lists.evens([1, 3, 5]) == []
  end

  @tag :pending
  test "Lists.sum/1 sums a non-empty list" do
    assert Lists.sum([1, 2, 3, 4]) == 10
  end

  @tag :pending
  test "Lists.sum/1 returns 0 for an empty list" do
    assert Lists.sum([]) == 0
  end
end
