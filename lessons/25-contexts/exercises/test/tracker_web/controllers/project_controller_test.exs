defmodule TrackerWeb.ProjectControllerTest do
  use TrackerWeb.ConnCase, async: false

  @tag :pending
  test "GET /projects renders the projects index", %{conn: conn} do
    conn = get(conn, ~p"/projects")
    assert html_response(conn, 200) =~ "Projects"
  end

  @tag :pending
  test "GET /projects/new renders the form", %{conn: conn} do
    conn = get(conn, ~p"/projects/new")
    assert html_response(conn, 200) =~ "New project"
  end

  @tag :pending
  test "POST /projects with valid params redirects and shows the project", %{conn: conn} do
    conn = post(conn, ~p"/projects", project: %{name: "Gemini"})
    assert redirected_to(conn) == ~p"/projects"
    assert recycle(conn) |> get(~p"/projects") |> html_response(200) =~ "Gemini"
  end

  @tag :pending
  test "POST /projects with a blank name re-renders the form", %{conn: conn} do
    conn = post(conn, ~p"/projects", project: %{name: ""})
    assert html_response(conn, 200) =~ "New project"
  end
end
