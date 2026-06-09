defmodule Tracker.ProjectStore do
  @moduledoc "In-memory project storage backed by an Agent. Replaced by Postgres in lesson 29."
  use Agent

  def start_link(_opts),
    do: Agent.start_link(fn -> %{items: [], next_id: 1} end, name: __MODULE__)

  def list(user_id) do
    __MODULE__
    |> Agent.get(& &1.items)
    |> Enum.filter(&(&1.user_id == user_id))
    |> Enum.reverse()
  end

  def add(user_id, attrs) do
    Agent.get_and_update(__MODULE__, fn %{items: items, next_id: id} ->
      project = attrs |> Map.put(:id, id) |> Map.put(:user_id, user_id)
      {project, %{items: [project | items], next_id: id + 1}}
    end)
  end

  def get(id), do: __MODULE__ |> Agent.get(& &1.items) |> Enum.find(&(&1.id == id))
end
