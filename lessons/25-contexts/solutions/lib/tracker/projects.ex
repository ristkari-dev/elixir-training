defmodule Tracker.Projects do
  @moduledoc "The Projects context: the boundary for project business logic."
  alias Tracker.ProjectStore

  @types %{name: :string, status: :string}

  def list_projects, do: ProjectStore.list()

  def get_project!(id) do
    ProjectStore.get(id) || raise "no project with id #{inspect(id)}"
  end

  def change_project(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> Ecto.Changeset.validate_required([:name])
  end

  def create_project(attrs) do
    changeset = change_project(attrs)

    if changeset.valid? do
      project = changeset |> Ecto.Changeset.apply_changes() |> ProjectStore.add()
      {:ok, project}
    else
      {:error, %{changeset | action: :insert}}
    end
  end
end
