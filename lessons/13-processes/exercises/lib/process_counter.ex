defmodule ProcessCounter do
  @moduledoc "A hand-rolled stateful counter process (pre-GenServer)."

  @doc """
  Spawn a counter process starting at `initial`. It responds to:
  `:inc` (increment), `{:get, from}` (send `{:count, n}` to `from`),
  and `:reset` (back to 0).
  """
  def start(_initial \\ 0), do: raise("TODO: spawn a process running loop(initial)")
end
