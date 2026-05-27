defmodule WcEx.CLITest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @fixture Path.join(__DIR__, "../fixtures/lorem.txt")

  @tag :pending
  test "WcEx.CLI.main/1 prints lines, words, chars, path" do
    output = capture_io(fn -> WcEx.CLI.main([@fixture]) end)
    assert output =~ "10\t"
    assert output =~ @fixture
  end
end
