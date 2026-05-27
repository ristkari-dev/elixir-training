defmodule OptsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Opts.get/3 returns the existing value" do
    assert Opts.get([host: "x"], :host, "localhost") == "x"
  end

  @tag :pending
  test "Opts.get/3 returns the default for a missing key" do
    assert Opts.get([], :host, "localhost") == "localhost"
  end

  @tag :pending
  test "Opts.get/3 returns the default for a different missing key" do
    assert Opts.get([port: 4000], :host, "localhost") == "localhost"
  end
end
