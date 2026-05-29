defmodule Tracker.Projects do
  @moduledoc "The Projects context: the boundary for project business logic."
  alias Tracker.ProjectStore

  @types %{name: :string, status: :string}

  # These functions are stubs. Implement them so the project pages and the
  # Tracker.ProjectsTest pass. Each one should wrap ProjectStore and/or the
  # schemaless changeset — the web layer must never touch the store directly.
  #
  # The stub bodies below return placeholder values so the carried controller
  # code still compiles; they do NOT do the real work, so the context tests
  # in test/tracker/projects_test.exs fail until you write the real bodies.
  # See HINTS.md for the full module.

  # TODO: return ProjectStore.list/0
  def list_projects, do: ProjectStore.list()

  # TODO: ProjectStore.get/1, raising if there's no project with that id
  def get_project!(id), do: ProjectStore.get(id)

  # TODO: a schemaless changeset — cast/4 over {data, @types} + validate_required([:name])
  def change_project(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, [])
  end

  # TODO: build change_project(attrs); if valid, apply_changes + ProjectStore.add -> {:ok, p};
  # otherwise -> {:error, changeset}
  def create_project(attrs) do
    changeset = change_project(attrs)

    if changeset.valid? do
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end
end
