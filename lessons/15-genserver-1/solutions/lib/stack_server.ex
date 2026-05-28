defmodule StackServer do
  @moduledoc "A GenServer holding a stack (list)."
  use GenServer

  def start_link(initial \\ []), do: GenServer.start_link(__MODULE__, initial)
  def push(pid, value), do: GenServer.cast(pid, {:push, value})
  def pop(pid), do: GenServer.call(pid, :pop)
  def peek(pid), do: GenServer.call(pid, :peek)

  @impl true
  def init(stack), do: {:ok, stack}

  @impl true
  def handle_cast({:push, value}, stack), do: {:noreply, [value | stack]}

  @impl true
  def handle_call(:pop, _from, []), do: {:reply, {:error, :empty}, []}
  def handle_call(:pop, _from, [top | rest]), do: {:reply, {:ok, top}, rest}
  def handle_call(:peek, _from, []), do: {:reply, {:error, :empty}, []}
  def handle_call(:peek, _from, [top | _] = stack), do: {:reply, {:ok, top}, stack}
end
