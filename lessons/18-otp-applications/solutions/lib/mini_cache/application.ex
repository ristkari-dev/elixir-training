defmodule MiniCache.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [MiniCache.Server]
    Supervisor.start_link(children, strategy: :one_for_one, name: MiniCache.Supervisor)
  end
end
