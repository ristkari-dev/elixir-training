defmodule CounterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "starts at the given value and returns it" do
    {:ok, pid} = Counter.start_link(5)
    assert Counter.get(pid) == 5
  end

  @tag :pending
  test "increments" do
    {:ok, pid} = Counter.start_link(0)
    Counter.inc(pid)
    Counter.inc(pid)
    assert Counter.get(pid) == 2
  end

  @tag :pending
  test "resets" do
    {:ok, pid} = Counter.start_link(10)
    Counter.reset(pid)
    assert Counter.get(pid) == 0
  end
end
