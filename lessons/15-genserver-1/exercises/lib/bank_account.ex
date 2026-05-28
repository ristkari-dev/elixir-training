defmodule BankAccount do
  @moduledoc "A GenServer bank account with deposit/withdraw/balance."
  use GenServer

  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def deposit(pid, amount), do: GenServer.cast(pid, {:deposit, amount})
  def withdraw(pid, amount), do: GenServer.call(pid, {:withdraw, amount})
  def balance(pid), do: GenServer.call(pid, :balance)

  @impl true
  def init(_balance), do: raise("TODO: return {:ok, balance}")

  @impl true
  def handle_cast(_msg, _balance), do: raise("TODO: handle {:deposit, amount}")

  @impl true
  def handle_call(_msg, _from, _balance),
    do: raise("TODO: handle {:withdraw, amount} with a guard, and :balance")
end
