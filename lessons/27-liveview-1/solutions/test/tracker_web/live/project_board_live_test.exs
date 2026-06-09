defmodule TrackerWeb.ProjectBoardLiveTest do
  # async: false — IssueStore/ProjectStore are app-started singletons whose
  # state does not roll back with the SQL sandbox. Each test makes a fresh
  # user + project; assertions target a specific issue by id, never "the only
  # element on the board".
  use TrackerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Tracker.AccountsFixtures

  alias Tracker.Accounts.Scope

  defp create_project(user) do
    {:ok, project} = Tracker.Projects.create_project(Scope.for_user(user), %{"name" => "Apollo"})
    project
  end

  test "redirects to log in when not authenticated", %{conn: conn} do
    user = user_fixture()
    project = create_project(user)

    assert {:error, {:redirect, %{to: path}}} = live(conn, ~p"/projects/#{project.id}/board")
    assert path == ~p"/users/log-in"
  end

  describe "as the owner" do
    setup :register_and_log_in_user

    test "adding an issue shows it on the board", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")

      html = view |> form("form", issue: %{title: "Fix login"}) |> render_submit()
      assert html =~ "Fix login"
    end

    test "toggling an issue flips its status", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, issue} = Tracker.Issues.create_issue(project.id, %{"title" => "Ship it"})
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert has_element?(view, "#issue-#{issue.id} .status", "open")

      view |> element("#issue-#{issue.id} button[phx-click=toggle]") |> render_click()
      assert has_element?(view, "#issue-#{issue.id} .status", "closed")
    end

    test "cannot open another user's board", %{conn: conn} do
      other = user_fixture()
      project = create_project(other)

      assert {:error, {:redirect, %{to: "/projects"}}} =
               live(conn, ~p"/projects/#{project.id}/board")
    end
  end
end
