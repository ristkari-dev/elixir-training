defmodule WcEx.Counts do
  @moduledoc "Accumulator struct for line/word/char counts."

  defstruct lines: 0, words: 0, chars: 0

  @doc """
  Update the running counts with one line of text.

      iex> WcEx.Counts.add(%WcEx.Counts{}, "hello world\\n")
      %WcEx.Counts{lines: 1, words: 2, chars: 12}
  """
  def add(_counts, _line),
    do: raise("TODO: lines + 1, words + String.split count, chars + String.length")
end
