defmodule SimpleSupTest do
  # async: false — SupCounter registers under a fixed name, so parallel
  # tests would collide on it.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(SimpleSup)
    :ok
  end

  @tag :pending
  test "restarts the counter with fresh state after a crash" do
    SupCounter.inc()
    assert SupCounter.get() == 1

    old_pid = Process.whereis(SupCounter)
    Process.exit(old_pid, :kill)

    new_pid = wait_for_new_pid(SupCounter, old_pid)
    assert new_pid != old_pid
    assert SupCounter.get() == 0
  end

  defp wait_for_new_pid(name, old_pid, attempts \\ 100)
  defp wait_for_new_pid(_name, _old_pid, 0), do: flunk("process did not restart")

  defp wait_for_new_pid(name, old_pid, attempts) do
    case Process.whereis(name) do
      nil ->
        Process.sleep(10)
        wait_for_new_pid(name, old_pid, attempts - 1)

      ^old_pid ->
        Process.sleep(10)
        wait_for_new_pid(name, old_pid, attempts - 1)

      new_pid ->
        new_pid
    end
  end
end
