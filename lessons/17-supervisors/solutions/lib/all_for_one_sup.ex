defmodule AllForOneSup do
  @moduledoc "A one_for_all supervisor over three named workers."
  use Supervisor

  def start_link(_opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok) do
    children = [
      Supervisor.child_spec({Worker, :worker_a}, id: :worker_a),
      Supervisor.child_spec({Worker, :worker_b}, id: :worker_b),
      Supervisor.child_spec({Worker, :worker_c}, id: :worker_c)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
