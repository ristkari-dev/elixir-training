defmodule TrackerWeb.ProjectBoardLiveTest do
  # Each test makes a fresh user + project; assertions target a specific issue
  # by its stream dom id (#issues-<id>), never "the only element on the board".
  use TrackerWeb.ConnCase, async: true

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

    @tag :pending
    test "adding an issue shows it on the board and stores it", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")
      view |> form("form", issue: %{title: "Fix login"}) |> render_submit()
      assert render(view) =~ "Fix login"

      # Reload the board: a stored issue is still there.
      {:ok, reloaded, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert render(reloaded) =~ "Fix login"
    end

    @tag :pending
    test "toggling an issue flips its status", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, issue} = Tracker.Issues.create_issue(project.id, %{"title" => "Ship it"})
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert has_element?(view, "#issues-#{issue.id} .status", "open")

      view |> element("#issues-#{issue.id} button[phx-click=toggle]") |> render_click()
      assert has_element?(view, "#issues-#{issue.id} .status", "closed")
    end

    @tag :pending
    test "a second tab sees a new issue live", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, tab_a, _} = live(conn, ~p"/projects/#{project.id}/board")
      {:ok, tab_b, _} = live(conn, ~p"/projects/#{project.id}/board")

      tab_a |> form("form", issue: %{title: "Broadcast me"}) |> render_submit()

      assert render(tab_b) =~ "Broadcast me"

      # And it was stored, not just pushed across the wire.
      {:ok, reloaded, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert render(reloaded) =~ "Broadcast me"
    end

    test "cannot open another user's board", %{conn: conn} do
      other = user_fixture()
      project = create_project(other)

      assert {:error, {:redirect, %{to: "/projects"}}} =
               live(conn, ~p"/projects/#{project.id}/board")
    end
  end
end
