defmodule Tracker.Projects do
  @moduledoc "The Projects context: the boundary for project business logic."
  import Ecto.Query

  alias Ecto.Changeset
  alias Tracker.Projects.Project
  alias Tracker.Repo

  def list_projects(scope) do
    # Query syntax is lesson 31. Read it as: this user's rows, oldest first.
    from(p in Project, where: p.user_id == ^scope.user.id, order_by: [asc: p.id])
    |> Repo.all()
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def change_project(attrs \\ %{}), do: changeset(%Project{}, attrs)

  def create_project(scope, attrs) do
    %Project{user_id: scope.user.id}
    |> changeset(attrs)
    |> Repo.insert()
  end

  defp changeset(project, attrs) do
    project
    |> Changeset.cast(attrs, [:name, :status])
    |> Changeset.validate_required([:name])
  end
end
