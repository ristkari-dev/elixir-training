defmodule Box do
  @moduledoc "A box with enforced width and height keys."

  @enforce_keys [:width, :height]
  defstruct [:width, :height]

  @doc """
  Return the area of the box.

      iex> Box.area(%Box{width: 3, height: 4})
      12
  """
  def area(%Box{width: w, height: h}), do: w * h
end
