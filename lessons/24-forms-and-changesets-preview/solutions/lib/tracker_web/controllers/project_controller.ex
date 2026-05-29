defmodule TrackerWeb.ProjectController do
  use TrackerWeb, :controller

  alias Tracker.ProjectStore

  @types %{name: :string, status: :string}

  def index(conn, _params), do: render(conn, :index, projects: ProjectStore.list())

  def new(conn, _params) do
    render(conn, :new, form: Phoenix.Component.to_form(change(), as: :project))
  end

  def create(conn, %{"project" => params}) do
    changeset = change(params)

    if changeset.valid? do
      changeset |> Ecto.Changeset.apply_changes() |> ProjectStore.add()

      conn
      |> put_flash(:info, "Project created.")
      |> redirect(to: ~p"/projects")
    else
      render(conn, :new,
        form: Phoenix.Component.to_form(%{changeset | action: :insert}, as: :project)
      )
    end
  end

  defp change(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> Ecto.Changeset.validate_required([:name])
  end
end
