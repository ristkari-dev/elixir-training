defmodule BankAccountTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "deposit increases the balance" do
    {:ok, pid} = BankAccount.start_link(0)
    BankAccount.deposit(pid, 100)
    assert BankAccount.balance(pid) == 100
  end

  @tag :pending
  test "withdraw within balance succeeds" do
    {:ok, pid} = BankAccount.start_link(100)
    assert BankAccount.withdraw(pid, 30) == {:ok, 70}
    assert BankAccount.balance(pid) == 70
  end

  @tag :pending
  test "withdraw beyond balance fails and leaves the balance unchanged" do
    {:ok, pid} = BankAccount.start_link(50)
    assert BankAccount.withdraw(pid, 100) == {:error, :insufficient_funds}
    assert BankAccount.balance(pid) == 50
  end
end
