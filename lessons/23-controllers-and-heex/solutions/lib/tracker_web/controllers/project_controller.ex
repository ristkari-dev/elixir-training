defmodule TrackerWeb.ProjectController do
  use TrackerWeb, :controller

  def index(conn, _params) do
    projects = [
      %{id: 1, name: "Apollo", status: "open"},
      %{id: 2, name: "Gemini", status: "open"}
    ]

    render(conn, :index, projects: projects)
  end
end
