defmodule PointTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Point.new/2 builds a struct" do
    assert Point.new(1, 2) == %Point{x: 1, y: 2}
  end

  @tag :pending
  test "Point.distance/2 returns 0 for the same point" do
    p = Point.new(7, 8)
    assert Point.distance(p, p) == 0.0
  end

  @tag :pending
  test "Point.distance/2 computes a 3-4-5 triangle" do
    assert Point.distance(Point.new(0, 0), Point.new(3, 4)) == 5.0
  end

  @tag :pending
  test "String.Chars for Point formats as (x, y)" do
    assert to_string(Point.new(1, 2)) == "(1, 2)"
  end
end
