defmodule Header do
  @moduledoc "Binary pattern matching for a tiny header format."

  @doc """
  Parse a binary `<<version, length, rest::binary>>` into a tuple
  `{version, length, rest}`.

      iex> Header.parse(<<1, 4, "data">>)
      {1, 4, "data"}
  """
  def parse(<<version, length, rest::binary>>), do: {version, length, rest}
end
