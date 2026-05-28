defmodule Counter do
  @moduledoc "A GenServer that holds an integer count."
  use GenServer

  # Client API
  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def inc(pid), do: GenServer.cast(pid, :inc)
  def get(pid), do: GenServer.call(pid, :get)
  def reset(pid), do: GenServer.cast(pid, :reset)

  # Callbacks
  @impl true
  def init(initial), do: {:ok, initial}

  @impl true
  def handle_cast(:inc, count), do: {:noreply, count + 1}
  def handle_cast(:reset, _count), do: {:noreply, 0}

  @impl true
  def handle_call(:get, _from, count), do: {:reply, count, count}
end
