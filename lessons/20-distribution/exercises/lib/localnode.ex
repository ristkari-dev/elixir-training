defmodule Localnode do
  @moduledoc "Single-node helpers introducing the Node and :rpc APIs."

  @doc """
  Return `{node_name, alive?}` for the current node.

      iex> {name, alive?} = Localnode.info()
      iex> is_atom(name) and is_boolean(alive?)
      true
  """
  def info, do: raise("TODO: {Node.self(), Node.alive?()}")

  @doc """
  Round-trip a message through :rpc against the current node. Returns
  the inspected string.

      iex> Localnode.echo_via_rpc(:hello)
      ":hello"
  """
  def echo_via_rpc(_msg), do: raise("TODO: :rpc.call(Node.self(), Kernel, :inspect, [msg])")
end
