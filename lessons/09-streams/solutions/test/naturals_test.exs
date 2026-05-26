defmodule NaturalsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Naturals.evens_below/1 returns evens up to but not including the bound" do
    assert Naturals.evens_below(10) == [0, 2, 4, 6, 8]
  end

  @tag :pending
  test "Naturals.evens_below/1 returns [] for bound 0" do
    assert Naturals.evens_below(0) == []
  end

  @tag :pending
  test "Naturals.evens_below/1 returns [0] for bound 1" do
    assert Naturals.evens_below(1) == [0]
  end
end
