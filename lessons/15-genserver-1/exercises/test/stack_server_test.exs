defmodule StackServerTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "push then pop returns the value" do
    {:ok, pid} = StackServer.start_link()
    StackServer.push(pid, :a)
    StackServer.push(pid, :b)
    assert StackServer.pop(pid) == {:ok, :b}
    assert StackServer.pop(pid) == {:ok, :a}
  end

  @tag :pending
  test "pop on an empty stack returns {:error, :empty}" do
    {:ok, pid} = StackServer.start_link()
    assert StackServer.pop(pid) == {:error, :empty}
  end

  @tag :pending
  test "peek returns the top without removing it" do
    {:ok, pid} = StackServer.start_link()
    StackServer.push(pid, :only)
    assert StackServer.peek(pid) == {:ok, :only}
    assert StackServer.peek(pid) == {:ok, :only}
  end
end
