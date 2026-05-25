defmodule StepsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Steps.run/1 returns the final value when all steps succeed" do
    # step1: 1 + 1 = 2
    # step2: 2 * 2 = 4
    # step3: 4 * 4 = 16
    assert Steps.run(1) == {:ok, 16}
  end

  @tag :pending
  test "Steps.run/1 short-circuits at step 2" do
    assert Steps.run(:fail_at_2) == {:error, :step2_failed}
  end

  @tag :pending
  test "Steps.run/1 short-circuits at step 1" do
    assert Steps.run(:fail_at_1) == {:error, :step1_failed}
  end
end
