defmodule StackServer do
  @moduledoc "A GenServer holding a stack (list)."
  use GenServer

  def start_link(initial \\ []), do: GenServer.start_link(__MODULE__, initial)
  def push(pid, value), do: GenServer.cast(pid, {:push, value})
  def pop(pid), do: GenServer.call(pid, :pop)
  def peek(pid), do: GenServer.call(pid, :peek)

  @impl true
  def init(_stack), do: raise("TODO: return {:ok, stack}")

  @impl true
  def handle_cast(_msg, _stack), do: raise("TODO: handle {:push, value}")

  @impl true
  def handle_call(_msg, _from, _stack), do: raise("TODO: handle :pop and :peek")
end
