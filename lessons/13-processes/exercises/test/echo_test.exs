defmodule EchoTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Echo replies with {:echo, msg}" do
    pid = Echo.start()
    send(pid, {self(), "hello"})
    assert_receive {:echo, "hello"}, 500
  end

  @tag :pending
  test "Echo keeps serving multiple messages" do
    pid = Echo.start()
    send(pid, {self(), "one"})
    assert_receive {:echo, "one"}, 500
    send(pid, {self(), "two"})
    assert_receive {:echo, "two"}, 500
  end
end
