defmodule KV do
  @moduledoc "Parse a 'key=value' line into a tuple."

  @doc """
  Split `"key=value"` on the first `=` and return `{key, value}`.

      iex> KV.parse_line("name=Aki")
      {"name", "Aki"}
      iex> KV.parse_line("greeting=hello=world")
      {"greeting", "hello=world"}
  """
  def parse_line(line) do
    [key, value] = String.split(line, "=", parts: 2)
    {key, value}
  end
end
