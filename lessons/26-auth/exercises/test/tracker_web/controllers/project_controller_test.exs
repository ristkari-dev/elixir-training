defmodule TrackerWeb.ProjectControllerTest do
  # async: false — Tracker.ProjectStore is an app-started singleton shared
  # across tests. Each test logs in a freshly-registered user, so their
  # projects never collide; assert on per-user visibility, not global counts.
  use TrackerWeb.ConnCase, async: false

  alias Tracker.Accounts.Scope
  import Tracker.AccountsFixtures

  describe "unauthenticated access" do
    @tag :pending
    test "GET /projects redirects to the log-in page", %{conn: conn} do
      conn = get(conn, ~p"/projects")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "authenticated access" do
    setup :register_and_log_in_user

    test "GET /projects renders the projects index", %{conn: conn} do
      conn = get(conn, ~p"/projects")
      assert html_response(conn, 200) =~ "Projects"
    end

    test "GET /projects/new renders the form", %{conn: conn} do
      conn = get(conn, ~p"/projects/new")
      assert html_response(conn, 200) =~ "New project"
    end

    test "POST /projects with valid params redirects and shows the project", %{conn: conn} do
      conn = post(conn, ~p"/projects", project: %{name: "Gemini"})
      assert redirected_to(conn) == ~p"/projects"
      assert recycle(conn) |> get(~p"/projects") |> html_response(200) =~ "Gemini"
    end

    test "POST /projects with a blank name re-renders the form", %{conn: conn} do
      conn = post(conn, ~p"/projects", project: %{name: ""})
      assert html_response(conn, 200) =~ "New project"
    end

    @tag :pending
    test "a user sees only their own projects", %{conn: conn} do
      other = user_fixture()

      {:ok, _} =
        Tracker.Projects.create_project(Scope.for_user(other), %{"name" => "OtherSecret"})

      conn = post(conn, ~p"/projects", project: %{name: "MineAlone"})
      body = recycle(conn) |> get(~p"/projects") |> html_response(200)

      assert body =~ "MineAlone"
      refute body =~ "OtherSecret"
    end
  end
end
