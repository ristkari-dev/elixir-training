defmodule Tracker.Issues do
  @moduledoc "The Issues context: the boundary for issue business logic."
  alias Tracker.IssueStore

  @types %{title: :string, status: :string}

  def list_issues(project_id), do: IssueStore.list(project_id)

  def change_issue(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, [:title])
    |> Ecto.Changeset.validate_required([:title])
  end

  def create_issue(project_id, attrs) do
    changeset = change_issue(attrs)

    if changeset.valid? do
      issue = changeset |> Ecto.Changeset.apply_changes() |> then(&IssueStore.add(project_id, &1))
      {:ok, issue}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  def toggle_issue(id), do: IssueStore.toggle(id)
end
