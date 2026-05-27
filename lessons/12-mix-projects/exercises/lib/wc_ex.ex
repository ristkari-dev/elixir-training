defmodule WcEx do
  @moduledoc "Tiny word-counter — Phase 1 capstone."

  alias WcEx.Counts

  @doc """
  Stream a file line-by-line and return a %Counts{}.
  """
  def count_file(_path),
    do: raise("TODO: File.stream! |> Enum.reduce(%Counts{}, &Counts.add(&2, &1))")
end
