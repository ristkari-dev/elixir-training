defmodule SafeDiv do
  @moduledoc "Division returning a tagged tuple."

  @doc """
  Divide `a` by `b`. Returns `{:ok, q}` for normal division and
  `{:error, :div_by_zero}` when `b` is zero.

      iex> SafeDiv.divide(10, 2)
      {:ok, 5.0}
      iex> SafeDiv.divide(1, 0)
      {:error, :div_by_zero}
  """
  def divide(_a, 0), do: {:error, :div_by_zero}
  def divide(a, b), do: {:ok, a / b}
end
