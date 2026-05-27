defmodule SafeDivTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "SafeDiv.divide/2 returns {:ok, q} for normal division" do
    assert SafeDiv.divide(10, 2) == {:ok, 5.0}
  end

  @tag :pending
  test "SafeDiv.divide/2 returns {:error, :div_by_zero} when divisor is 0" do
    assert SafeDiv.divide(1, 0) == {:error, :div_by_zero}
  end

  @tag :pending
  test "SafeDiv.divide/2 handles negative numerators" do
    assert SafeDiv.divide(-6, 3) == {:ok, -2.0}
  end
end
