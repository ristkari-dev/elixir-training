defmodule MapperTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Mapper.double_all/1 doubles every element" do
    assert Mapper.double_all([1, 2, 3]) == [2, 4, 6]
  end

  @tag :pending
  test "Mapper.double_all/1 returns [] for the empty list" do
    assert Mapper.double_all([]) == []
  end

  @tag :pending
  test "Mapper.double_all/1 handles a singleton" do
    assert Mapper.double_all([5]) == [10]
  end
end
