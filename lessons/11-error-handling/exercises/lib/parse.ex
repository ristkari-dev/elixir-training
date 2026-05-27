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
  def integer(_s), do: raise("TODO: case Integer.parse(s) → {n, \"\"} / _ → :invalid")
end
