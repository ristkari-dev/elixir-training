defmodule Async do
  @moduledoc "Start two tasks; return whichever finishes first."

  @doc """
  Run two zero-arity functions concurrently. Return the result of
  whichever completes first.
  """
  def race(_fun_a, _fun_b), do: raise("TODO: Task.async both, receive the first {ref, value}")
end
