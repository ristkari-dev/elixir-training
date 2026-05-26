defmodule GreeterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Greeter.hello/1 matches the literal \"world\"" do
    assert Greeter.hello("world") == "Hello, world!"
  end

  @tag :pending
  test "Greeter.hello/1 falls through to a generic greeting" do
    assert Greeter.hello("Aki") == "Hello, Aki!"
  end
end
