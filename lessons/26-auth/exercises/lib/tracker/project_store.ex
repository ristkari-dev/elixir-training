defmodule Tracker.ProjectStore do
  @moduledoc "In-memory project storage backed by an Agent. Replaced by Postgres in lesson 29."
  use Agent

  def start_link(_opts),
    do: Agent.start_link(fn -> %{items: [], next_id: 1} end, name: __MODULE__)

  # TODO: return only the projects whose :user_id matches user_id.
  def list(_user_id) do
    __MODULE__ |> Agent.get(& &1.items) |> Enum.reverse()
  end

  # TODO: store the project with its :user_id so list/1 can filter by owner.
  def add(_user_id, attrs) do
    Agent.get_and_update(__MODULE__, fn %{items: items, next_id: id} ->
      project = Map.put(attrs, :id, id)
      {project, %{items: [project | items], next_id: id + 1}}
    end)
  end

  def get(id), do: __MODULE__ |> Agent.get(& &1.items) |> Enum.find(&(&1.id == id))
end
