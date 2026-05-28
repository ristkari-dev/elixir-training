defmodule Atomic do
  @moduledoc "Atomic counters via :ets.update_counter."
  use GenServer

  @table :atomic_counters

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Atomically add `by` to the counter at `key`, returning the new value.
  Missing keys start at 0.
  """
  def bump(key, by \\ 1), do: :ets.update_counter(@table, key, by, {key, 0})

  @doc "Read the current value at key (0 if missing)."
  def value(key) do
    case :ets.lookup(@table, key) do
      [{^key, v}] -> v
      [] -> 0
    end
  end

  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end
end
