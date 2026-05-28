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
  def init(_timeout),
    do: raise("TODO: return {:ok, %{status: :active, timeout: timeout}, timeout}")

  @impl true
  def handle_cast(:touch, _state), do: raise("TODO: set status :active, return with timeout")

  @impl true
  def handle_call(:status, _from, _state), do: raise("TODO: reply status, return with timeout")

  @impl true
  def handle_info(:timeout, _state), do: raise("TODO: set status :idle")
end
