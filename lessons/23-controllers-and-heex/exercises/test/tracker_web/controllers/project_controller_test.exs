defmodule TrackerWeb.ProjectControllerTest do
  use TrackerWeb.ConnCase, async: true

  @tag :pending
  test "GET /projects lists the projects", %{conn: conn} do
    conn = get(conn, ~p"/projects")
    body = html_response(conn, 200)
    assert body =~ "Apollo"
    assert body =~ "Gemini"
  end
end
