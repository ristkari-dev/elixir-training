defmodule Tracker.Issues do
  @moduledoc "The Issues context: the boundary for issue business logic."

  # Drill 2 replaces this module's storage with Ecto. Until then the changeset
  # below is the lesson-24 schemaless kind, so the board still renders its
  # form — but nothing is ever stored.
  @types %{title: :string, status: :string}

  def list_issues(_project_id) do
    # TODO (drill 2): return this project's issues, oldest first, from the DB.
    []
  end

  def change_issue(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, [:title])
    |> Ecto.Changeset.validate_required([:title])
  end

  def create_issue(project_id, attrs) do
    changeset = change_issue(attrs)

    if changeset.valid? do
      # TODO (drill 2): insert the issue with Repo.insert/1 and return it.
      # This placeholder is never stored, so it vanishes on the next page load.
      {:ok,
       %{
         id: 0,
         title: Ecto.Changeset.get_field(changeset, :title),
         status: "open",
         project_id: project_id
       }}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  def toggle_issue(_id) do
    # TODO (drill 2): load the issue, flip its status, save it, return it.
    %{id: 0, title: "", status: "open", project_id: 0}
  end
end
