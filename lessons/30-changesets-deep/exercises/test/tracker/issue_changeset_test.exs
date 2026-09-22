defmodule Tracker.IssueChangesetTest do
  # Every rule an issue has to satisfy, and where each one is enforced.
  # One check per test: a rejected statement rolls back to its savepoint,
  # and mixing two checks in one test muddies which one failed.
  use Tracker.DataCase, async: true

  alias Tracker.Issues
  alias Tracker.Accounts.Scope
  alias Tracker.Repo
  import Tracker.AccountsFixtures

  defp project do
    scope = Scope.for_user(user_fixture())
    {:ok, project} = Tracker.Projects.create_project(scope, %{"name" => "Apollo"})
    project
  end

  # --- validations: Elixir side, before any SQL runs ---

  @tag :pending
  test "a title longer than 120 characters is rejected" do
    long = String.duplicate("x", 121)
    assert {:error, changeset} = Issues.create_issue(project().id, %{"title" => long})
    assert errors_on(changeset).title == ["should be at most 120 character(s)"]
  end

  @tag :pending
  test "a title with no letter or number is rejected" do
    assert {:error, changeset} = Issues.create_issue(project().id, %{"title" => "!!!"})
    assert errors_on(changeset).title == ["needs at least one letter or number"]
  end

  @tag :pending
  test "surrounding whitespace is trimmed before the rules run" do
    assert {:ok, issue} = Issues.create_issue(project().id, %{"title" => "  Fix login  "})
    assert issue.title == "Fix login"
  end

  @tag :pending
  test "a status outside the enum is rejected at cast time" do
    changeset = Issues.change_issue(%{"title" => "Fine", "status" => "sideways"})
    refute changeset.valid?
    assert errors_on(changeset).status == ["is invalid"]
  end

  # --- constraints: Postgres side, only after every validation passes ---

  @tag :pending
  test "a duplicate title in the same project is rejected" do
    project = project()
    {:ok, _} = Issues.create_issue(project.id, %{"title" => "Fix login"})

    assert {:error, changeset} = Issues.create_issue(project.id, %{"title" => "Fix login"})
    assert errors_on(changeset).title == ["has already been taken"]
  end

  test "the same title in a different project is fine" do
    {:ok, _} = Issues.create_issue(project().id, %{"title" => "Fix login"})
    assert {:ok, _} = Issues.create_issue(project().id, %{"title" => "Fix login"})
  end

  @tag :pending
  test "an issue for a project that does not exist is rejected" do
    assert {:error, changeset} = Issues.create_issue(999_999, %{"title" => "Orphan"})
    assert errors_on(changeset).project_id == ["does not exist"]
  end

  @tag :pending
  test "the unique index really exists in the database" do
    %{rows: rows} = Repo.query!("SELECT indexname FROM pg_indexes WHERE tablename = 'issues'")
    assert ["issues_project_id_title_index"] in rows
  end
end
