defmodule AllForOneSupTest do
  # async: false — workers register under fixed names.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(AllForOneSup)
    :ok
  end

  @tag :pending
  test "killing one worker restarts all three (one_for_all)" do
    a1 = Process.whereis(:worker_a)
    b1 = Process.whereis(:worker_b)
    c1 = Process.whereis(:worker_c)

    Process.exit(a1, :kill)

    assert wait_until_all_changed(%{worker_a: a1, worker_b: b1, worker_c: c1})
  end

  defp wait_until_all_changed(olds, attempts \\ 100)
  defp wait_until_all_changed(_olds, 0), do: flunk("workers did not all restart")

  defp wait_until_all_changed(olds, attempts) do
    all_changed? =
      Enum.all?(olds, fn {name, old} ->
        pid = Process.whereis(name)
        is_pid(pid) and pid != old
      end)

    if all_changed? do
      true
    else
      Process.sleep(10)
      wait_until_all_changed(olds, attempts - 1)
    end
  end
end
