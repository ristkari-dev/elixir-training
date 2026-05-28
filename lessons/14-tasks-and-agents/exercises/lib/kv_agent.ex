defmodule KVAgent do
  @moduledoc "A key-value store backed by an Agent."

  @doc "Start an empty KV agent, returning {:ok, pid}."
  def start_link, do: raise("TODO: Agent.start_link(fn -> %{} end)")

  @doc "Store value under key."
  def put(_agent, _key, _value), do: raise("TODO: Agent.update")

  @doc "Fetch the value for key, or nil."
  def get(_agent, _key), do: raise("TODO: Agent.get")
end
