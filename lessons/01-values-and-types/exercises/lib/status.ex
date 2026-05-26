defmodule Status do
  @moduledoc "Status-tag helpers used in lesson 01."

  @doc """
  Return true if `x` is the atom `:ok`, otherwise false.

      iex> Status.ok?(:ok)
      true
      iex> Status.ok?(:error)
      false
  """
  def ok?(_x), do: raise("TODO: implement Status.ok?/1 — compare x against the atom :ok with ==")
end
