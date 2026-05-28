defmodule Worker do
  @moduledoc "A trivial GenServer worker used to demo supervision strategies."
  use GenServer

  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: name)

  @impl true
  def init(name), do: {:ok, name}
end
