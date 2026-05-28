defmodule SimpleSup do
  @moduledoc "A one_for_one supervisor over a single SupCounter."
  use Supervisor

  def start_link(_opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok) do
    children = [SupCounter]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
