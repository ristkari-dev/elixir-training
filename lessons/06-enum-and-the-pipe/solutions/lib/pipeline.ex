defmodule Pipeline do
  @moduledoc "A single |> chain composing filter, map, and reduce."

  @doc """
  Return the sum of squares of the even integers in the list, in one pipeline.

      iex> Pipeline.pipeline([1, 2, 3, 4])
      20
  """
  def pipeline(list) do
    list
    |> Enum.filter(&(rem(&1, 2) == 0))
    |> Enum.map(&(&1 * &1))
    |> Enum.sum()
  end
end
