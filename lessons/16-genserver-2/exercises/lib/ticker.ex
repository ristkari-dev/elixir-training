defmodule Ticker do
  @moduledoc "A GenServer that increments a counter every interval ms."
  use GenServer

  def start_link(opts \\ []) do
    {interval, gen_opts} = Keyword.pop(opts, :interval, 100)
    GenServer.start_link(__MODULE__, interval, gen_opts)
  end

  def count(pid), do: GenServer.call(pid, :count)

  @impl true
  def init(_interval),
    do: raise("TODO: schedule the first tick, return {:ok, %{count: 0, interval: interval}}")

  @impl true
  def handle_info(_msg, _state), do: raise("TODO: increment count, reschedule the next tick")

  @impl true
  def handle_call(:count, _from, state), do: {:reply, state.count, state}
end
