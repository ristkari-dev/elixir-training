defmodule Greeter do
  @moduledoc "Multi-clause greeting drill for lesson 03."

  @doc """
  Return a greeting. If the name is "world", greet "world" specially.

      iex> Greeter.hello("world")
      "Hello, world!"
      iex> Greeter.hello("Aki")
      "Hello, Aki!"
  """
  def hello(_name), do: raise("TODO: two clauses — \"world\" literal + name catch-all")
end
