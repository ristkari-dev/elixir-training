defmodule WcEx.CLI do
  @moduledoc "Escript entry point — wired up via mix.exs :escript option."

  @doc """
  Entry point. Receives argv as a list of strings. The first arg is the path.
  Prints `<lines>\\t<words>\\t<chars>\\t<path>` to stdout.
  """
  def main(_argv),
    do: raise("TODO: destructure [path | _] = argv, count_file, format, IO.puts")
end
