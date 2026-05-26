defmodule GreetTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Greet.hello/1 greets a single name" do
    assert Greet.hello("Aki") == "Hello, Aki!"
  end

  @tag :pending
  test "Greet.hello/1 works with any name" do
    assert Greet.hello("World") == "Hello, World!"
  end
end
