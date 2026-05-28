defmodule Linked do
  @moduledoc "Demonstrates process links and trapping exits."

  @doc """
  Set the current process to trap exits, then spawn_link a child that
  crashes. Because exits are trapped, the caller receives an
  `{:EXIT, child_pid, reason}` message instead of crashing too.
  Returns the child pid.
  """
  def crash do
    Process.flag(:trap_exit, true)
    spawn_link(fn -> raise "boom" end)
  end
end
