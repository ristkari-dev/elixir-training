defmodule Tracker.ProjectsTest do
  use ExUnit.Case, async: false

  alias Tracker.Projects

  @tag :pending
  test "create_project/1 with valid attrs stores and returns it" do
    assert {:ok, project} = Projects.create_project(%{"name" => "Apollo"})
    assert project.name == "Apollo"
    assert project.id
    assert Enum.any?(Projects.list_projects(), &(&1.id == project.id))
  end

  @tag :pending
  test "create_project/1 with a blank name returns an error changeset" do
    assert {:error, changeset} = Projects.create_project(%{"name" => ""})
    refute changeset.valid?
  end

  @tag :pending
  test "get_project!/1 raises for a missing id" do
    assert_raise RuntimeError, fn -> Projects.get_project!(999) end
  end
end
