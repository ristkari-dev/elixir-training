defmodule Letters do
  @moduledoc "String-processing drills for lesson 08."

  @doc """
  Count the vowels in a string (case-insensitive).

      iex> Letters.vowel_count("Hello, Aki!")
      4
  """
  def vowel_count(s) do
    s
    |> String.downcase()
    |> String.graphemes()
    |> Enum.count(&(&1 in ["a", "e", "i", "o", "u"]))
  end

  @doc """
  Title-case a sentence — capitalize each word.

      iex> Letters.title_case("hello, lovely day")
      "Hello, Lovely Day"
  """
  def title_case(s) do
    s
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
