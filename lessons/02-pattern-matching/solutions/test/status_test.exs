defmodule StatusTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Status.unwrap/1 returns the value from :ok" do
    assert Status.unwrap({:ok, 42}) == 42
  end

  @tag :pending
  test "Status.unwrap/1 returns nil from :error" do
    assert Status.unwrap({:error, "nope"}) == nil
  end

  @tag :pending
  test "Status.unwrap/1 returns the value when it's a string" do
    assert Status.unwrap({:ok, "hi"}) == "hi"
  end
end
