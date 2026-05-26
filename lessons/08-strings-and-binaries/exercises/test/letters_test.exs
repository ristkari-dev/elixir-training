defmodule LettersTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Letters.vowel_count/1 counts vowels in a short string" do
    assert Letters.vowel_count("Aki") == 2
  end

  @tag :pending
  test "Letters.vowel_count/1 is case-insensitive" do
    assert Letters.vowel_count("HELLO") == 2
  end

  @tag :pending
  test "Letters.vowel_count/1 returns 0 for a vowel-less string" do
    assert Letters.vowel_count("bcdfg") == 0
  end

  @tag :pending
  test "Letters.title_case/1 capitalizes each word" do
    assert Letters.title_case("hello world") == "Hello World"
  end

  @tag :pending
  test "Letters.title_case/1 returns single word capitalized" do
    assert Letters.title_case("elixir") == "Elixir"
  end
end
