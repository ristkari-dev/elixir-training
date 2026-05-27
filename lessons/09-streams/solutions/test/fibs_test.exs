defmodule FibsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Fibs.take/1 returns the first six numbers" do
    assert Fibs.take(6) == [0, 1, 1, 2, 3, 5]
  end

  @tag :pending
  test "Fibs.take/1 returns [] for n=0" do
    assert Fibs.take(0) == []
  end

  @tag :pending
  test "Fibs.take/1 returns [0] for n=1" do
    assert Fibs.take(1) == [0]
  end
end
