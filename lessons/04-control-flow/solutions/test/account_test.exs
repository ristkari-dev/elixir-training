defmodule AccountTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Account.status/1 returns :open for {:ok, positive balance}" do
    assert Account.status({:ok, 100}) == :open
  end

  @tag :pending
  test "Account.status/1 returns :empty for {:ok, 0}" do
    assert Account.status({:ok, 0}) == :empty
  end

  @tag :pending
  test "Account.status/1 returns :closed for any {:error, _}" do
    assert Account.status({:error, :closed}) == :closed
    assert Account.status({:error, "frozen"}) == :closed
  end
end
