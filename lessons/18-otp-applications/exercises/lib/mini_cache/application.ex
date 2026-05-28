defmodule MiniCache.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args),
    do:
      raise(
        "TODO: Supervisor.start_link([MiniCache.Server], strategy: :one_for_one, name: MiniCache.Supervisor)"
      )
end
