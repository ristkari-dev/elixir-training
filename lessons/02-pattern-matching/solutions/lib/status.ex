defmodule Status do
  @moduledoc "Status-tag pattern drills for lesson 02."

  @doc """
  Return the value from an `{:ok, value}` tuple, or nil for `{:error, _}`.

      iex> Status.unwrap({:ok, 42})
      42
      iex> Status.unwrap({:error, "nope"})
      nil
  """
  def unwrap({:ok, value}), do: value
  def unwrap({:error, _}), do: nil
end
