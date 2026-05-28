defmodule Async do
  @moduledoc "Start two tasks; return whichever finishes first."

  @doc """
  Run two zero-arity functions concurrently. Return the result of
  whichever completes first.
  """
  def race(fun_a, fun_b) do
    task_a = Task.async(fun_a)
    task_b = Task.async(fun_b)
    result = race_loop(task_a, task_b)
    Task.shutdown(task_a, :brutal_kill)
    Task.shutdown(task_b, :brutal_kill)
    result
  end

  defp race_loop(task_a, task_b) do
    receive do
      {ref, value} when ref == task_a.ref or ref == task_b.ref -> value
    end
  end
end
