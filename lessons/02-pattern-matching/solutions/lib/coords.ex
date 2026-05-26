defmodule Coords do
  @moduledoc "Coordinate-tuple drills for lesson 02."

  @doc """
  Return true if the coordinate is the origin {0, 0}.

      iex> Coords.origin?({0, 0})
      true
      iex> Coords.origin?({1, 2})
      false
  """
  def origin?({0, 0}), do: true
  def origin?(_), do: false
end
