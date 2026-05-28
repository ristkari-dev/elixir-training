defmodule ProcessCounter do
  @moduledoc "A hand-rolled stateful counter process (pre-GenServer)."

  @doc """
  Spawn a counter process starting at `initial`. It responds to:
  `:inc` (increment), `{:get, from}` (send `{:count, n}` to `from`),
  and `:reset` (back to 0).
  """
  def start(initial \\ 0), do: spawn(fn -> loop(initial) end)

  defp loop(count) do
    receive do
      :inc ->
        loop(count + 1)

      {:get, from} ->
        send(from, {:count, count})
        loop(count)

      :reset ->
        loop(0)
    end
  end
end
