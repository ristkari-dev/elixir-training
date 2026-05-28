defmodule ETSCacheTest do
  # async: false — named table + named server.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(ETSCache)
    :ok
  end

  @tag :pending
  test "put then get round-trips a value" do
    ETSCache.put(:a, 1)
    assert ETSCache.get(:a) == 1
  end

  @tag :pending
  test "get returns nil for a missing key" do
    assert ETSCache.get(:missing) == nil
  end

  @tag :pending
  test "delete removes a key" do
    ETSCache.put(:b, 2)
    ETSCache.delete(:b)
    assert ETSCache.get(:b) == nil
  end
end
