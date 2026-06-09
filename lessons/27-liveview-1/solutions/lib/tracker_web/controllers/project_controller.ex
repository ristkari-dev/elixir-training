defmodule TrackerWeb.ProjectController do
  use TrackerWeb, :controller

  alias Tracker.Projects

  def index(conn, _params) do
    render(conn, :index, projects: Projects.list_projects(conn.assigns.current_scope))
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(String.to_integer(id))
    render(conn, :show, project: project)
  end

  def new(conn, _params) do
    render(conn, :new, form: Phoenix.Component.to_form(Projects.change_project(), as: :project))
  end

  def create(conn, %{"project" => params}) do
    case Projects.create_project(conn.assigns.current_scope, params) do
      {:ok, _project} ->
        conn |> put_flash(:info, "Project created.") |> redirect(to: ~p"/projects")

      {:error, changeset} ->
        render(conn, :new, form: Phoenix.Component.to_form(changeset, as: :project))
    end
  end
end
