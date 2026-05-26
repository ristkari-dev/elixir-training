defmodule ApplyHelperTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "ApplyHelper.twice/2 calls f twice with the increment function" do
    assert ApplyHelper.twice(fn x -> x + 1 end, 0) == 2
  end

  @tag :pending
  test "ApplyHelper.twice/2 works with the & shorthand" do
    assert ApplyHelper.twice(&(&1 * 2), 3) == 12
  end

  @tag :pending
  test "ApplyHelper.twice/2 with identity returns the input" do
    assert ApplyHelper.twice(fn x -> x end, 42) == 42
  end
end
