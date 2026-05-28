defmodule ProcessCounterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "starts at the given initial value" do
    pid = ProcessCounter.start(5)
    send(pid, {:get, self()})
    assert_receive {:count, 5}, 500
  end

  @tag :pending
  test "increments on :inc" do
    pid = ProcessCounter.start(0)
    send(pid, :inc)
    send(pid, :inc)
    send(pid, {:get, self()})
    assert_receive {:count, 2}, 500
  end

  @tag :pending
  test "resets on :reset" do
    pid = ProcessCounter.start(10)
    send(pid, :reset)
    send(pid, {:get, self()})
    assert_receive {:count, 0}, 500
  end
end
