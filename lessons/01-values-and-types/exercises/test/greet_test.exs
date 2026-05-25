defmodule GreetTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Greet.hello/1 greets a single name" do
    assert Greet.hello("Aki") == "Hello, Aki!"
  end

  @tag :pending
  test "Greet.hello/1 greets the empty string" do
    assert Greet.hello("") == "Hello, !"
  end
end
