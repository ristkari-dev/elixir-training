defmodule KVTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "KV.parse_line/1 splits at the first =" do
    assert KV.parse_line("name=Aki") == {"name", "Aki"}
  end

  @tag :pending
  test "KV.parse_line/1 keeps later = in the value" do
    assert KV.parse_line("greeting=hello=world") == {"greeting", "hello=world"}
  end

  @tag :pending
  test "KV.parse_line/1 handles empty value" do
    assert KV.parse_line("empty=") == {"empty", ""}
  end
end
