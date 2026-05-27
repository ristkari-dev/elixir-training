defmodule LogStats do
  @moduledoc "File-based stream drill — count ERROR lines in a log."

  @doc """
  Open `path` as a line stream; count lines containing the substring "ERROR".

  Returns an integer.
  """
  def count_errors(_path),
    do: raise("TODO: File.stream! the path, Stream.filter contains? ERROR, Enum.count")
end
