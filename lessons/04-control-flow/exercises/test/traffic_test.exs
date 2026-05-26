defmodule TrafficTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Traffic.action/1 returns 'stop' for :red" do
    assert Traffic.action(:red) == "stop"
  end

  @tag :pending
  test "Traffic.action/1 returns 'slow' for :yellow" do
    assert Traffic.action(:yellow) == "slow"
  end

  @tag :pending
  test "Traffic.action/1 returns 'go' for :green" do
    assert Traffic.action(:green) == "go"
  end
end
