defmodule KVAgent do
  @moduledoc "A key-value store backed by an Agent."

  @doc "Start an empty KV agent, returning {:ok, pid}."
  def start_link, do: Agent.start_link(fn -> %{} end)

  @doc "Store value under key."
  def put(agent, key, value), do: Agent.update(agent, &Map.put(&1, key, value))

  @doc "Fetch the value for key, or nil."
  def get(agent, key), do: Agent.get(agent, &Map.get(&1, key))
end
