defmodule AtomicTest do
  # async: false — named table + named server.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(Atomic)
    :ok
  end

  @tag :pending
  test "bump returns the new value" do
    assert Atomic.bump(:x, 5) == 5
    assert Atomic.bump(:x, 3) == 8
  end

  @tag :pending
  test "bump increments atomically under concurrency" do
    tasks = for _ <- 1..100, do: Task.async(fn -> Atomic.bump(:hits) end)
    Enum.each(tasks, &Task.await/1)
    assert Atomic.value(:hits) == 100
  end
end
