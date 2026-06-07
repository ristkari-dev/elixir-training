defmodule Tracker.ProjectsTest do
  use Tracker.DataCase, async: false

  alias Tracker.Projects
  alias Tracker.Accounts.Scope
  import Tracker.AccountsFixtures

  setup do
    %{scope: Scope.for_user(user_fixture())}
  end

  @tag :pending
  test "create_project/2 with valid attrs stores and returns it", %{scope: scope} do
    assert {:ok, project} = Projects.create_project(scope, %{"name" => "Apollo"})
    assert project.name == "Apollo"
    assert project.id
    assert project.user_id == scope.user.id
    assert Enum.any?(Projects.list_projects(scope), &(&1.id == project.id))
  end

  test "create_project/2 with a blank name returns an error changeset", %{scope: scope} do
    assert {:error, changeset} = Projects.create_project(scope, %{"name" => ""})
    refute changeset.valid?
  end

  @tag :pending
  test "list_projects/1 returns only the scope's own projects", %{scope: scope} do
    other = Scope.for_user(user_fixture())
    {:ok, mine} = Projects.create_project(scope, %{"name" => "Mine"})
    {:ok, theirs} = Projects.create_project(other, %{"name" => "Theirs"})

    ids = Enum.map(Projects.list_projects(scope), & &1.id)
    assert mine.id in ids
    refute theirs.id in ids
  end

  test "get_project!/1 raises for a missing id" do
    assert_raise RuntimeError, fn -> Projects.get_project!(999_999) end
  end
end
