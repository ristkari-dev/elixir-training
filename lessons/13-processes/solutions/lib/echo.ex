defmodule Echo do
  @moduledoc "A process that echoes messages back to the sender."

  @doc """
  Spawn an echo process. It waits for `{from, msg}` and sends back
  `{:echo, msg}` to `from`, then waits again.
  """
  def start, do: spawn(fn -> loop() end)

  defp loop do
    receive do
      {from, msg} ->
        send(from, {:echo, msg})
        loop()
    end
  end
end
