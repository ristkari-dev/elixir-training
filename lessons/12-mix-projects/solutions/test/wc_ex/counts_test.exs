defmodule WcEx.CountsTest do
  use ExUnit.Case, async: true

  alias WcEx.Counts

  @tag :pending
  test "Counts.add/2 increments lines, words, and chars" do
    counts = Counts.add(%Counts{}, "hello world\n")
    assert counts.lines == 1
    assert counts.words == 2
    assert counts.chars == String.length("hello world\n")
  end

  @tag :pending
  test "Counts.add/2 accumulates across calls" do
    counts = %Counts{} |> Counts.add("a b c\n") |> Counts.add("d e\n")
    assert counts.lines == 2
    assert counts.words == 5
  end

  @tag :pending
  test "Counts.add/2 handles an empty line" do
    counts = Counts.add(%Counts{}, "\n")
    assert counts.lines == 1
    assert counts.words == 0
    assert counts.chars == 1
  end
end
