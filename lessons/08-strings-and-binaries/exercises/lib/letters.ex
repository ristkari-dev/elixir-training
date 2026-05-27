defmodule Letters do
  @moduledoc "String-processing drills for lesson 08."

  @doc """
  Count the vowels in a string (case-insensitive).

      iex> Letters.vowel_count("Hello, Aki!")
      4
  """
  def vowel_count(_s), do: raise("TODO: lowercase, graphemes, Enum.count with vowel membership")

  @doc """
  Title-case a sentence — capitalize each word.

      iex> Letters.title_case("hello, lovely day")
      "Hello, Lovely Day"
  """
  def title_case(_s), do: raise("TODO: String.split on space, map String.capitalize, join")
end
