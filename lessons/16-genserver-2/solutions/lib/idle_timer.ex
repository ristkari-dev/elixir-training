defmodule IdleTimer do
  @moduledoc "A GenServer that flips to :idle after a period of inactivity."
  use GenServer

  def start_link(opts \\ []) do
    {timeout, gen_opts} = Keyword.pop(opts, :timeout, 50)
    GenServer.start_link(__MODULE__, timeout, gen_opts)
  end

  def touch(pid), do: GenServer.cast(pid, :touch)
  def status(pid), do: GenServer.call(pid, :status)

  @impl true
  def init(timeout), do: {:ok, %{status: :active, timeout: timeout}, timeout}

  @impl true
  def handle_cast(:touch, state), do: {:noreply, %{state | status: :active}, state.timeout}

  @impl true
  def handle_call(:status, _from, state), do: {:reply, state.status, state, state.timeout}

  @impl true
  def handle_info(:timeout, state), do: {:noreply, %{state | status: :idle}}
end
