defmodule HeaderTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Header.parse/1 extracts version, length, and payload" do
    assert Header.parse(<<1, 4, "data">>) == {1, 4, "data"}
  end

  @tag :pending
  test "Header.parse/1 works with an empty payload" do
    assert Header.parse(<<2, 0>>) == {2, 0, ""}
  end

  @tag :pending
  test "Header.parse/1 handles a longer payload" do
    assert Header.parse(<<7, 11, "hello world">>) == {7, 11, "hello world"}
  end
end
