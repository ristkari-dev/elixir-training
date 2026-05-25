defmodule Greet do
  @moduledoc "Greeting helpers used in lesson 01."

  @doc """
  Return a greeting for the given name.

      iex> Greet.hello("Aki")
      "Hello, Aki!"
  """
  def hello(name), do: "Hello, " <> name <> "!"
end
