defmodule MiniCache.Server do
  @moduledoc "GenServer holding the cache state as a map."
  use GenServer

  # Client API — done for you.
  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def delete(key), do: GenServer.cast(__MODULE__, {:delete, key})
  def size, do: GenServer.call(__MODULE__, :size)

  # Callbacks — implement these.
  @impl true
  def init(_state), do: raise("TODO: return {:ok, %{}}")

  @impl true
  def handle_cast(_msg, _state), do: raise("TODO: handle {:put, k, v} and {:delete, k}")

  @impl true
  def handle_call(_msg, _from, _state), do: raise("TODO: handle {:get, k} and :size")
end
