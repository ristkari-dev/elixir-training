defmodule AllForOneSup do
  @moduledoc "A one_for_all supervisor over three named workers."
  use Supervisor

  def start_link(_opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok),
    do: raise("TODO: three Worker children (ids :worker_a/b/c), strategy :one_for_all")
end
