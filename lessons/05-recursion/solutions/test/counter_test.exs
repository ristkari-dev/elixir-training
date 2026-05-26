defmodule CounterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Counter.length/1 counts a non-empty list" do
    assert Counter.length([:a, :b, :c, :d]) == 4
  end

  @tag :pending
  test "Counter.length/1 returns 0 for the empty list" do
    assert Counter.length([]) == 0
  end

  @tag :pending
  test "Counter.length/1 works on a singleton" do
    assert Counter.length([1]) == 1
  end
end
