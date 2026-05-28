defmodule KVAgentTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, agent} = KVAgent.start_link()
    %{agent: agent}
  end

  @tag :pending
  test "put then get round-trips a value", %{agent: agent} do
    KVAgent.put(agent, :name, "Aki")
    assert KVAgent.get(agent, :name) == "Aki"
  end

  @tag :pending
  test "get returns nil for a missing key", %{agent: agent} do
    assert KVAgent.get(agent, :missing) == nil
  end
end
