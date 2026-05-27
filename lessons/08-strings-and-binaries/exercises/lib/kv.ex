defmodule KV do
  @moduledoc "Parse a 'key=value' line into a tuple."

  @doc """
  Split `"key=value"` on the first `=` and return `{key, value}`.

      iex> KV.parse_line("name=Aki")
      {"name", "Aki"}
      iex> KV.parse_line("greeting=hello=world")
      {"greeting", "hello=world"}
  """
  def parse_line(_line), do: raise("TODO: String.split with parts: 2 and pattern-match [k, v]")
end
