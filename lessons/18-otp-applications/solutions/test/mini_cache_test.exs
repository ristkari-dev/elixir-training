defmodule MiniCacheTest do
  # async: false — MiniCache.Server is a singleton named process started
  # by the application; tests share it, so they must not run in parallel.
  use ExUnit.Case, async: false

  setup do
    # Clear any leftover state from a prior test.
    for key <- [:a, :b, :c], do: MiniCache.delete(key)
    :ok
  end

  @tag :pending
  test "put then get round-trips a value" do
    MiniCache.put(:a, 1)
    assert MiniCache.get(:a) == 1
  end

  @tag :pending
  test "get returns nil for a missing key" do
    assert MiniCache.get(:missing) == nil
  end

  @tag :pending
  test "delete removes a key" do
    MiniCache.put(:b, 2)
    MiniCache.delete(:b)
    assert MiniCache.get(:b) == nil
  end

  @tag :pending
  test "size reflects the number of stored keys" do
    MiniCache.put(:a, 1)
    MiniCache.put(:c, 3)
    assert MiniCache.size() >= 2
  end

  @tag :pending
  test "the cache empties after the Server is killed and restarted" do
    MiniCache.put(:a, 1)
    assert MiniCache.get(:a) == 1

    old_pid = Process.whereis(MiniCache.Server)
    Process.exit(old_pid, :kill)
    wait_for_new_pid(MiniCache.Server, old_pid)

    assert MiniCache.get(:a) == nil
  end

  defp wait_for_new_pid(name, old_pid, attempts \\ 100)
  defp wait_for_new_pid(_name, _old_pid, 0), do: flunk("server did not restart")

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
