defmodule BankAccount do
  @moduledoc "A GenServer bank account with deposit/withdraw/balance."
  use GenServer

  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def deposit(pid, amount), do: GenServer.cast(pid, {:deposit, amount})
  def withdraw(pid, amount), do: GenServer.call(pid, {:withdraw, amount})
  def balance(pid), do: GenServer.call(pid, :balance)

  @impl true
  def init(balance), do: {:ok, balance}

  @impl true
  def handle_cast({:deposit, amount}, balance), do: {:noreply, balance + amount}

  @impl true
  def handle_call({:withdraw, amount}, _from, balance) when amount <= balance do
    {:reply, {:ok, balance - amount}, balance - amount}
  end

  def handle_call({:withdraw, _amount}, _from, balance) do
    {:reply, {:error, :insufficient_funds}, balance}
  end

  def handle_call(:balance, _from, balance), do: {:reply, balance, balance}
end
