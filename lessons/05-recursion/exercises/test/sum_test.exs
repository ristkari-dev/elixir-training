defmodule SumTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Sum.of/1 sums a non-empty list" do
    assert Sum.of([1, 2, 3, 4]) == 10
  end

  @tag :pending
  test "Sum.of/1 returns 0 for the empty list" do
    assert Sum.of([]) == 0
  end

  @tag :pending
  test "Sum.of/1 handles negative integers" do
    assert Sum.of([-1, 1, -2, 2]) == 0
  end
end
