defmodule Coords do
  @moduledoc "Coordinate-tuple drills for lesson 02."

  @doc """
  Return true if the coordinate is the origin {0, 0}.

      iex> Coords.origin?({0, 0})
      true
      iex> Coords.origin?({1, 2})
      false
  """
  def origin?(_point), do: raise("TODO: match {0, 0} then use a catch-all clause")
end
