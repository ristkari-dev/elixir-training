defmodule NumbersTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Numbers.classify/1 returns :negative for negative integers" do
    assert Numbers.classify(-3) == :negative
  end

  @tag :pending
  test "Numbers.classify/1 returns :zero for 0" do
    assert Numbers.classify(0) == :zero
  end

  @tag :pending
  test "Numbers.classify/1 returns :positive for positive integers" do
    assert Numbers.classify(7) == :positive
  end

  @tag :pending
  test "Numbers.classify/1 handles negative floats" do
    assert Numbers.classify(-0.5) == :negative
  end
end
