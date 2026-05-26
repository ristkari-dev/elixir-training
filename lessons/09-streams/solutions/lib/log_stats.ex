defmodule LogStats do
  @moduledoc "File-based stream drill — count ERROR lines in a log."

  @doc """
  Open `path` as a line stream; count lines containing the substring "ERROR".

  Returns an integer.
  """
  def count_errors(path) do
    path
    |> File.stream!()
    |> Stream.filter(&String.contains?(&1, "ERROR"))
    |> Enum.count()
  end
end
