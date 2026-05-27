defmodule ParseTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Parse.integer/1 returns {:ok, n} for a clean integer string" do
    assert Parse.integer("42") == {:ok, 42}
  end

  @tag :pending
  test "Parse.integer/1 returns {:error, :invalid} for non-numeric input" do
    assert Parse.integer("oops") == {:error, :invalid}
  end

  @tag :pending
  test "Parse.integer/1 returns {:error, :invalid} for trailing garbage" do
    assert Parse.integer("42abc") == {:error, :invalid}
  end

  @tag :pending
  test "Parse.integer/1 handles negative integers" do
    assert Parse.integer("-7") == {:ok, -7}
  end
end
