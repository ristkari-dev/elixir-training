defmodule Ticker do
  @moduledoc "A GenServer that increments a counter every interval ms."
  use GenServer

  def start_link(opts \\ []) do
    {interval, gen_opts} = Keyword.pop(opts, :interval, 100)
    GenServer.start_link(__MODULE__, interval, gen_opts)
  end

  def count(pid), do: GenServer.call(pid, :count)

  @impl true
  def init(interval) do
    schedule(interval)
    {:ok, %{count: 0, interval: interval}}
  end

  @impl true
  def handle_info(:tick, state) do
    schedule(state.interval)
    {:noreply, %{state | count: state.count + 1}}
  end

  @impl true
  def handle_call(:count, _from, state), do: {:reply, state.count, state}

  defp schedule(interval), do: Process.send_after(self(), :tick, interval)
end
