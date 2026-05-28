defmodule AsyncTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "returns the faster task's result" do
    slow = fn ->
      Process.sleep(100)
      :slow
    end

    fast = fn ->
      Process.sleep(10)
      :fast
    end

    assert Async.race(slow, fast) == :fast
  end

  @tag :pending
  test "works regardless of argument order" do
    slow = fn ->
      Process.sleep(100)
      :slow
    end

    fast = fn ->
      Process.sleep(10)
      :fast
    end

    assert Async.race(fast, slow) == :fast
  end
end
