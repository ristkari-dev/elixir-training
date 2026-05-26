defmodule Account do
  @moduledoc "Tagged-tuple case drill with guards for lesson 04."

  @doc """
  Map an account result to a status atom.

      iex> Account.status({:ok, 100})
      :open
      iex> Account.status({:ok, 0})
      :empty
      iex> Account.status({:error, :closed})
      :closed
  """
  def status(_result), do: raise("TODO: case with three patterns including a guard on balance")
end
