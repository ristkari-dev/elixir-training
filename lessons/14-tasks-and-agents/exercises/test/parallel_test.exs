defmodule ParallelTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "runs functions and returns results in order" do
    funs = [fn -> 1 end, fn -> 2 end, fn -> 3 end]
    assert Parallel.fetch_all(funs) == [1, 2, 3]
  end

  @tag :pending
  test "actually runs concurrently (3x50ms work finishes well under 150ms)" do
    funs =
      for _ <- 1..3,
          do: fn ->
            Process.sleep(50)
            :done
          end

    {micros, results} = :timer.tc(fn -> Parallel.fetch_all(funs) end)
    assert results == [:done, :done, :done]
    assert micros < 120_000
  end

  @tag :pending
  test "returns [] for an empty list" do
    assert Parallel.fetch_all([]) == []
  end
end
