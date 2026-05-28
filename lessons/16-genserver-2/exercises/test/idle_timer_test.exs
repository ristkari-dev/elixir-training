defmodule IdleTimerTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "starts active" do
    pid = start_supervised!({IdleTimer, timeout: 10_000})
    assert IdleTimer.status(pid) == :active
  end

  @tag :pending
  test "becomes idle after the timeout elapses" do
    pid = start_supervised!({IdleTimer, timeout: 30})
    Process.sleep(70)
    assert IdleTimer.status(pid) == :idle
  end
end
