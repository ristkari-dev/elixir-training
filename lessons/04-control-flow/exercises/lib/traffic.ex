defmodule Traffic do
  @moduledoc "Traffic-light case drill for lesson 04."

  @doc """
  Return the action for a traffic-light atom.

      iex> Traffic.action(:red)
      "stop"
      iex> Traffic.action(:green)
      "go"
  """
  def action(_light), do: raise("TODO: use a `case` matching :red, :yellow, :green")
end
