defmodule Tracker.Projects do
  @moduledoc "The Projects context: the boundary for project business logic."
  import Ecto.Query

  alias Tracker.Projects.Project
  alias Tracker.Repo

  def list_projects(scope) do
    # Query syntax is lesson 31. Read it as: this user's rows, oldest first.
    from(p in Project, where: p.user_id == ^scope.user.id, order_by: [asc: p.id])
    |> Repo.all()
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def change_project(attrs \\ %{}), do: Project.changeset(%Project{}, attrs)

  def create_project(scope, attrs) do
    %Project{user_id: scope.user.id}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end
end
