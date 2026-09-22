defmodule Tracker.Issues do
  @moduledoc "The Issues context: the boundary for issue business logic."
  import Ecto.Query

  alias Ecto.Changeset
  alias Tracker.Issues.Issue
  alias Tracker.Repo

  def list_issues(project_id) do
    # Query syntax is lesson 31. Read it as: this project's rows, oldest first.
    from(i in Issue, where: i.project_id == ^project_id, order_by: [asc: i.id])
    |> Repo.all()
  end

  def change_issue(attrs \\ %{}), do: Issue.changeset(%Issue{}, attrs)

  def create_issue(project_id, attrs) do
    %Issue{project_id: project_id}
    |> Issue.changeset(attrs)
    |> Repo.insert()
  end

  # Not user input: an internal flip of a value we control, so it skips
  # Issue.changeset/2 and every validation in it.
  def toggle_issue(id) do
    issue = Repo.get!(Issue, id)

    issue
    |> Changeset.change(status: flip(issue.status))
    |> Repo.update!()
  end

  defp flip(:open), do: :closed
  defp flip(_), do: :open
end
