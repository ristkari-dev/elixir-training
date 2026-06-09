defmodule Tracker.IssueStore do
  @moduledoc "In-memory issue storage backed by an Agent. Replaced by Postgres in lesson 29."
  use Agent

  def start_link(_opts),
    do: Agent.start_link(fn -> %{items: [], next_id: 1} end, name: __MODULE__)

  def list(project_id) do
    __MODULE__
    |> Agent.get(& &1.items)
    |> Enum.filter(&(&1.project_id == project_id))
    |> Enum.reverse()
  end

  def add(project_id, attrs) do
    Agent.get_and_update(__MODULE__, fn %{items: items, next_id: id} ->
      issue =
        attrs
        |> Map.put(:id, id)
        |> Map.put(:project_id, project_id)
        |> Map.put_new(:status, "open")

      {issue, %{items: [issue | items], next_id: id + 1}}
    end)
  end

  def toggle(id) do
    Agent.get_and_update(__MODULE__, fn %{items: items} = state ->
      items =
        Enum.map(items, fn
          %{id: ^id} = issue -> %{issue | status: flip(issue.status)}
          issue -> issue
        end)

      {Enum.find(items, &(&1.id == id)), %{state | items: items}}
    end)
  end

  def get(id), do: __MODULE__ |> Agent.get(& &1.items) |> Enum.find(&(&1.id == id))

  defp flip("open"), do: "closed"
  defp flip(_), do: "open"
end
