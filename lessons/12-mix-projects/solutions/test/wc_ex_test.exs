defmodule WcExTest do
  use ExUnit.Case, async: true

  alias WcEx.Counts

  @fixture Path.join(__DIR__, "fixtures/lorem.txt")

  @tag :pending
  test "WcEx.count_file/1 returns a Counts struct" do
    assert %Counts{} = WcEx.count_file(@fixture)
  end

  @tag :pending
  test "WcEx.count_file/1 counts the right number of lines" do
    %Counts{lines: lines} = WcEx.count_file(@fixture)
    assert lines == 10
  end

  @tag :pending
  test "WcEx.count_file/1 counts a positive number of words" do
    %Counts{words: words} = WcEx.count_file(@fixture)
    assert words > 50
  end
end
