defmodule Tracker.IssuesTest do
  use Tracker.DataCase, async: true

  alias Tracker.Issues
  alias Tracker.Accounts.Scope
  import Tracker.AccountsFixtures

  defp create_project(name) do
    scope = Scope.for_user(user_fixture())
    {:ok, project} = Tracker.Projects.create_project(scope, %{"name" => name})
    project
  end

  test "create_issue/2 with a title stores an open issue" do
    project = create_project("Apollo")
    assert {:ok, issue} = Issues.create_issue(project.id, %{"title" => "Write tests"})
    assert issue.title == "Write tests"
    assert issue.status == "open"
    assert issue.project_id == project.id

    # It was stored, not just built: reading it back finds the same row.
    assert [stored] = Issues.list_issues(project.id)
    assert stored.id == issue.id
  end

  test "create_issue/2 with a blank title returns an error changeset" do
    project = create_project("Apollo")
    assert {:error, changeset} = Issues.create_issue(project.id, %{"title" => ""})
    refute changeset.valid?
  end

  test "list_issues/1 returns only that project's issues" do
    one = create_project("One")
    two = create_project("Two")
    {:ok, a} = Issues.create_issue(one.id, %{"title" => "A"})
    {:ok, b} = Issues.create_issue(two.id, %{"title" => "B"})

    ids = Enum.map(Issues.list_issues(one.id), & &1.id)
    assert a.id in ids
    refute b.id in ids
  end

  test "toggle_issue/1 flips status" do
    project = create_project("Apollo")
    {:ok, issue} = Issues.create_issue(project.id, %{"title" => "Toggle me"})
    assert Issues.toggle_issue(issue.id).status == "closed"
    assert Issues.toggle_issue(issue.id).status == "open"
  end
end
