defmodule PipelineTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pipeline.pipeline/1 sums squares of evens" do
    # evens: 2, 4 → squares: 4, 16 → sum: 20
    assert Pipeline.pipeline([1, 2, 3, 4]) == 20
  end

  @tag :pending
  test "Pipeline.pipeline/1 returns 0 when nothing is even" do
    assert Pipeline.pipeline([1, 3, 5]) == 0
  end

  @tag :pending
  test "Pipeline.pipeline/1 returns 0 for an empty list" do
    assert Pipeline.pipeline([]) == 0
  end
end
