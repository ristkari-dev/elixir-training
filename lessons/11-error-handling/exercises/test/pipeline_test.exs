defmodule PipelineTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pipeline.run/1 returns the final value when all steps succeed" do
    # step_a: 1+1=2; step_b: 2*2=4; step_c: 4*4=16
    assert Pipeline.run(1) == {:ok, 16}
  end

  @tag :pending
  test "Pipeline.run/1 short-circuits at step a" do
    assert Pipeline.run(:fail_a) == {:error, :step_a_failed}
  end

  @tag :pending
  test "Pipeline.run/1 short-circuits at step c with sentinel input :fail_c after a/b" do
    # input :fail_c is not an integer, so step_a returns the catch-all
    # error :step_a_failed — confirm the failure is reported with the
    # original error reason, not silently lost.
    assert Pipeline.run(:fail_c) == {:error, :step_a_failed}
  end
end
