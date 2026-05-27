defmodule Point do
  @moduledoc "A 2D point with a Euclidean-distance function."

  defstruct [:x, :y]

  @doc """
  Build a new point.

      iex> Point.new(1, 2)
      %Point{x: 1, y: 2}
  """
  def new(_x, _y), do: raise("TODO: return %__MODULE__{x: x, y: y}")

  @doc """
  Euclidean distance between two points.

      iex> Point.distance(Point.new(0, 0), Point.new(3, 4))
      5.0
  """
  def distance(_a, _b), do: raise("TODO: :math.sqrt(:math.pow(dx, 2) + :math.pow(dy, 2))")
end

defimpl String.Chars, for: Point do
  def to_string(%Point{x: _x, y: _y}), do: raise("TODO: return \"(x, y)\" as a string")
end
