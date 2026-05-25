defmodule MyMathTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "MyMath.double/1 doubles a positive integer" do
    assert MyMath.double(7) == 14
  end

  @tag :pending
  test "MyMath.double/1 doubles zero" do
    assert MyMath.double(0) == 0
  end

  @tag :pending
  test "MyMath.area_of_rectangle/2 returns w * h" do
    assert MyMath.area_of_rectangle(3, 4) == 12
  end

  @tag :pending
  test "MyMath.area_of_rectangle/2 returns 0 for a degenerate rectangle" do
    assert MyMath.area_of_rectangle(0, 5) == 0
  end
end
