defmodule ETSCache do
  @moduledoc "A cache backed by a public ETS table owned by a GenServer."
  use GenServer

  @table :ets_cache

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc "Store value under key."
  def put(key, value), do: :ets.insert(@table, {key, value})

  @doc "Fetch the value for key, or nil."
  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  @doc "Remove key from the table."
  def delete(key), do: :ets.delete(@table, key)

  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end
end
