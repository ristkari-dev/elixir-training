defmodule Pipeline do
  @moduledoc "A single |> chain composing filter, map, and reduce."

  @doc """
  Return the sum of squares of the even integers in the list, in one pipeline.

      iex> Pipeline.pipeline([1, 2, 3, 4])
      20
  """
  def pipeline(_list), do: raise("TODO: list |> Enum.filter |> Enum.map |> Enum.sum")
end
