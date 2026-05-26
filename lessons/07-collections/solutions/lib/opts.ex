defmodule Opts do
  @moduledoc "Keyword-list lookup with a default."

  @doc """
  Look up `key` in a keyword-list `opts`; return `default` if absent.

      iex> Opts.get([host: "elixir.dev"], :host, "localhost")
      "elixir.dev"
      iex> Opts.get([], :host, "localhost")
      "localhost"
  """
  def get(opts, key, default), do: Keyword.get(opts, key, default)
end
