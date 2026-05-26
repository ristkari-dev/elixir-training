defmodule BoxTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Box.area/1 multiplies width by height" do
    assert Box.area(%Box{width: 3, height: 4}) == 12
  end

  @tag :pending
  test "Box.area/1 returns 0 for a zero dimension" do
    assert Box.area(%Box{width: 0, height: 7}) == 0
  end

  @tag :pending
  test "creating a Box without enforced keys raises" do
    assert_raise ArgumentError, fn -> struct!(Box, %{width: 1}) end
  end
end
