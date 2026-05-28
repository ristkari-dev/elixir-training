defmodule LocalnodeTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "info returns the node name and alive status" do
    {name, alive?} = Localnode.info()
    assert is_atom(name)
    assert is_boolean(alive?)
  end

  @tag :pending
  test "echo_via_rpc round-trips through :rpc.call on the current node" do
    assert Localnode.echo_via_rpc(:hello) == ":hello"
  end
end
