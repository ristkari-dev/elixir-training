defmodule MiniCache.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    # TODO: put MiniCache.Server in this list so the app supervises it on
    # boot. Until you do, the app starts but the cache isn't running, and
    # MiniCache.get/1 fails with "no process".
    children = []
    Supervisor.start_link(children, strategy: :one_for_one, name: MiniCache.Supervisor)
  end
end
