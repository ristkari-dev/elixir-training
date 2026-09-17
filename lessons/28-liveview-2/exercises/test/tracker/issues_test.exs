defmodule Tracker.IssuesTest do
  use Tracker.DataCase, async: false

  alias Tracker.Issues

  test "create_issue/2 with a title stores an open issue" do
    assert {:ok, issue} = Issues.create_issue(1, %{"title" => "Write tests"})
    assert issue.title == "Write tests"
    assert issue.status == "open"
    assert issue.project_id == 1
  end

  test "create_issue/2 with a blank title returns an error changeset" do
    assert {:error, changeset} = Issues.create_issue(1, %{"title" => ""})
    refute changeset.valid?
  end

  test "list_issues/1 returns only that project's issues" do
    {:ok, a} = Issues.create_issue(101, %{"title" => "A"})
    {:ok, b} = Issues.create_issue(102, %{"title" => "B"})

    ids = Enum.map(Issues.list_issues(101), & &1.id)
    assert a.id in ids
    refute b.id in ids
  end

  test "toggle_issue/1 flips status" do
    {:ok, issue} = Issues.create_issue(1, %{"title" => "Toggle me"})
    assert Issues.toggle_issue(issue.id).status == "closed"
    assert Issues.toggle_issue(issue.id).status == "open"
  end
end
