defmodule Point do
  @moduledoc "A 2D point with a Euclidean-distance function."

  defstruct [:x, :y]

  @doc """
  Build a new point.

      iex> Point.new(1, 2)
      %Point{x: 1, y: 2}
  """
  def new(x, y), do: %__MODULE__{x: x, y: y}

  @doc """
  Euclidean distance between two points.

      iex> Point.distance(Point.new(0, 0), Point.new(3, 4))
      5.0
  """
  def distance(%Point{x: ax, y: ay}, %Point{x: bx, y: by}) do
    :math.sqrt(:math.pow(bx - ax, 2) + :math.pow(by - ay, 2))
  end
end

defimpl String.Chars, for: Point do
  def to_string(%Point{x: x, y: y}), do: "(#{x}, #{y})"
end
