defmodule Echo do
  @moduledoc "A process that echoes messages back to the sender."

  @doc """
  Spawn an echo process. It waits for `{from, msg}` and sends back
  `{:echo, msg}` to `from`, then waits again.
  """
  def start, do: raise("TODO: spawn a process running a receive loop that echoes {from, msg}")
end
