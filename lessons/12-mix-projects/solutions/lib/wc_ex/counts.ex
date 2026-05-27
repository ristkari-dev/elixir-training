defmodule WcEx.Counts do
  @moduledoc "Accumulator struct for line/word/char counts."

  defstruct lines: 0, words: 0, chars: 0

  @doc """
  Update the running counts with one line of text.

      iex> WcEx.Counts.add(%WcEx.Counts{}, "hello world\\n")
      %WcEx.Counts{lines: 1, words: 2, chars: 12}
  """
  def add(%__MODULE__{lines: l, words: w, chars: c}, line) do
    %__MODULE__{
      lines: l + 1,
      words: w + (line |> String.split() |> length()),
      chars: c + String.length(line)
    }
  end
end
