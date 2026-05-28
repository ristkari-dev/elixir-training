defmodule SupCounter do
  @moduledoc "A named counter GenServer, supervised in lesson 17."
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  def inc, do: GenServer.cast(__MODULE__, :inc)
  def get, do: GenServer.call(__MODULE__, :get)

  @impl true
  def init(count), do: {:ok, count}

  @impl true
  def handle_cast(:inc, count), do: {:noreply, count + 1}

  @impl true
  def handle_call(:get, _from, count), do: {:reply, count, count}
end
