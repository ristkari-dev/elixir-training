defmodule TickerTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "advances the counter over time" do
    pid = start_supervised!({Ticker, interval: 20})
    Process.sleep(70)
    # at least 2 ticks should have fired in 70ms at a 20ms interval
    assert Ticker.count(pid) >= 2
  end

  @tag :pending
  test "starts at zero" do
    pid = start_supervised!({Ticker, interval: 10_000})
    assert Ticker.count(pid) == 0
  end
end
