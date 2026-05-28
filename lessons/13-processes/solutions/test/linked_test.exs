defmodule LinkedTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "the caller receives an EXIT signal when the linked child crashes" do
    pid = Linked.crash()
    assert_receive {:EXIT, ^pid, _reason}, 500
  end
end
