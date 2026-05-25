defmodule CoordsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Coords.origin?/1 is true for {0, 0}" do
    assert Coords.origin?({0, 0}) == true
  end

  @tag :pending
  test "Coords.origin?/1 is false for {1, 2}" do
    assert Coords.origin?({1, 2}) == false
  end

  @tag :pending
  test "Coords.origin?/1 is false for {0, 1}" do
    assert Coords.origin?({0, 1}) == false
  end
end
