defmodule StatusTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Status.ok?/1 is true for :ok" do
    assert Status.ok?(:ok) == true
  end

  @tag :pending
  test "Status.ok?/1 is false for :error" do
    assert Status.ok?(:error) == false
  end

  @tag :pending
  test "Status.ok?/1 is false for a non-atom" do
    assert Status.ok?("ok") == false
  end
end
