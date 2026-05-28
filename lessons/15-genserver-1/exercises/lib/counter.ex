defmodule Counter do
  @moduledoc "A GenServer that holds an integer count."
  use GenServer

  # Client API — done for you.
  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def inc(pid), do: GenServer.cast(pid, :inc)
  def get(pid), do: GenServer.call(pid, :get)
  def reset(pid), do: GenServer.cast(pid, :reset)

  # Callbacks — implement these.
  @impl true
  def init(_initial), do: raise("TODO: return {:ok, initial}")

  @impl true
  def handle_cast(_msg, _count), do: raise("TODO: handle :inc and :reset")

  @impl true
  def handle_call(_msg, _from, _count), do: raise("TODO: handle :get")
end
