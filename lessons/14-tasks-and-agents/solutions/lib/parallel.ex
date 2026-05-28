defmodule Parallel do
  @moduledoc "Run zero-arity work functions concurrently."

  @doc """
  Given a list of zero-arity functions, run them concurrently with
  Task.async_stream and return their results in the original order.

      iex> Parallel.fetch_all([fn -> 1 end, fn -> 2 end])
      [1, 2]
  """
  def fetch_all(funs) do
    funs
    |> Task.async_stream(fn f -> f.() end)
    |> Enum.map(fn {:ok, result} -> result end)
  end
end
