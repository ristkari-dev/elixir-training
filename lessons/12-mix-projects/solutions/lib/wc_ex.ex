defmodule WcEx do
  @moduledoc "Tiny word-counter — Phase 1 capstone."

  alias WcEx.Counts

  @doc """
  Stream a file line-by-line and return a %Counts{}.
  """
  def count_file(path) do
    path
    |> File.stream!()
    |> Enum.reduce(%Counts{}, &Counts.add(&2, &1))
  end
end
