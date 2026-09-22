defmodule Tracker.IssuesTableTest do
  # This file checks the `issues` TABLE, not the Issue schema: it talks to
  # Postgres through raw inserts and SQL, so it says nothing about your
  # Elixir code. Each check gets its own test, because a rejected statement
  # aborts the surrounding sandbox transaction.
  use Tracker.DataCase, async: true

  alias Tracker.Accounts.Scope
  alias Tracker.Repo
  import Tracker.AccountsFixtures

  defp project_id do
    scope = Scope.for_user(user_fixture())
    {:ok, project} = Tracker.Projects.create_project(scope, %{"name" => "Apollo"})
    project.id
  end

  # insert_all with a table name (not a schema) autogenerates nothing, so the
  # timestamps `timestamps/1` made NOT NULL have to be filled in by hand.
  defp row(attrs) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    Enum.into(attrs, %{inserted_at: now, updated_at: now})
  end

  test "project_id must point at a project that exists" do
    error = catch_error(Repo.insert_all("issues", [row(title: "Orphan", project_id: 999_999)]))
    assert %Postgrex.Error{postgres: %{code: :foreign_key_violation}} = error
  end

  test "title cannot be null" do
    error = catch_error(Repo.insert_all("issues", [row(project_id: project_id())]))
    assert %Postgrex.Error{postgres: %{code: :not_null_violation, column: "title"}} = error
  end

  test "status defaults to open in the database" do
    {1, nil} =
      Repo.insert_all("issues", [row(title: "No status given", project_id: project_id())])

    assert %{rows: [["open"]]} = Repo.query!("SELECT status FROM issues")
  end

  test "project_id is indexed" do
    %{rows: rows} = Repo.query!("SELECT indexname FROM pg_indexes WHERE tablename = 'issues'")
    assert ["issues_project_id_index"] in rows
  end
end
