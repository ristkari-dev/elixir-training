defmodule SignTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Sign.of/1 returns :negative for negative numbers" do
    assert Sign.of(-3) == :negative
  end

  @tag :pending
  test "Sign.of/1 returns :zero for 0" do
    assert Sign.of(0) == :zero
  end

  @tag :pending
  test "Sign.of/1 returns :positive for positive numbers" do
    assert Sign.of(7) == :positive
  end
end
