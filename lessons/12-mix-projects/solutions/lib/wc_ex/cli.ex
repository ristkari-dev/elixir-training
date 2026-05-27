defmodule WcEx.CLI do
  @moduledoc "Escript entry point — wired up via mix.exs :escript option."

  alias WcEx.Counts

  @doc """
  Entry point. Receives argv as a list of strings. The first arg is the path.
  Prints `<lines>\\t<words>\\t<chars>\\t<path>` to stdout.
  """
  def main([path | _]) do
    %Counts{lines: l, words: w, chars: c} = WcEx.count_file(path)
    IO.puts("#{l}\t#{w}\t#{c}\t#{path}")
  end

  def main([]) do
    IO.puts(:stderr, "usage: wc_ex FILE")
    System.halt(1)
  end
end
