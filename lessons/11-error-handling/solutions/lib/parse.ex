defmodule Parse do
  @moduledoc "Parse helpers that return tagged tuples."

  @doc """
  Parse a string as an integer. Returns `{:ok, n}` for a clean integer
  string; `{:error, :invalid}` for anything else.

      iex> Parse.integer("42")
      {:ok, 42}
      iex> Parse.integer("oops")
      {:error, :invalid}
      iex> Parse.integer("42abc")
      {:error, :invalid}
  """
  def integer(s) do
    case Integer.parse(s) do
      {n, ""} -> {:ok, n}
      _ -> {:error, :invalid}
    end
  end
end
