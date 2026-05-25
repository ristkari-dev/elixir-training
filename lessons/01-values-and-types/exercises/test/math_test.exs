defmodule MathTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Math.add/2 sums two positive integers" do
    assert Math.add(2, 3) == 5
  end

  @tag :pending
  test "Math.add/2 handles a negative addend" do
    assert Math.add(-1, 1) == 0
  end

  @tag :pending
  test "Math.add/2 returns 0 for 0 + 0" do
    assert Math.add(0, 0) == 0
  end
end
