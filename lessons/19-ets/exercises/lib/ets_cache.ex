defmodule ETSCache do
  @moduledoc "A cache backed by a public ETS table owned by a GenServer."
  use GenServer

  @table :ets_cache

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc "Store value under key."
  def put(_key, _value), do: raise("TODO: :ets.insert(@table, {key, value})")

  @doc "Fetch the value for key, or nil."
  def get(_key), do: raise("TODO: :ets.lookup and match [{^key, value}] / []")

  @doc "Remove key from the table."
  def delete(_key), do: raise("TODO: :ets.delete(@table, key)")

  # init is provided — study how the table is created.
  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end
end
