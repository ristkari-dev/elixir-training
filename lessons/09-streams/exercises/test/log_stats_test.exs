defmodule LogStatsTest do
  use ExUnit.Case, async: true

  @sample_path Path.join(__DIR__, "fixtures/sample.log")

  @tag :pending
  test "LogStats.count_errors/1 counts ERROR lines in the fixture" do
    assert LogStats.count_errors(@sample_path) == 5
  end

  @tag :pending
  test "LogStats.count_errors/1 returns 0 for a fixture without ERROR" do
    path = Path.join(__DIR__, "fixtures/no_errors.log")
    File.write!(path, "INFO ok\nDEBUG fine\n")

    try do
      assert LogStats.count_errors(path) == 0
    after
      File.rm!(path)
    end
  end
end
