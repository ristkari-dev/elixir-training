defmodule MiniCache.Server do
  @moduledoc "GenServer holding the cache state as a map."
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def delete(key), do: GenServer.cast(__MODULE__, {:delete, key})
  def size, do: GenServer.call(__MODULE__, :size)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:put, key, value}, state), do: {:noreply, Map.put(state, key, value)}
  def handle_cast({:delete, key}, state), do: {:noreply, Map.delete(state, key)}

  @impl true
  def handle_call({:get, key}, _from, state), do: {:reply, Map.get(state, key), state}
  def handle_call(:size, _from, state), do: {:reply, map_size(state), state}
end
