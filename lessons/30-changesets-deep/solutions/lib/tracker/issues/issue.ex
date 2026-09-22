defmodule Tracker.Issues.Issue do
  @moduledoc "An issue row, and the rules an issue has to satisfy."
  use Ecto.Schema
  import Ecto.Changeset

  schema "issues" do
    field :title, :string
    field :status, Ecto.Enum, values: [:open, :closed], default: :open
    field :project_id, :id

    timestamps type: :utc_datetime
  end

  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :status])
    |> update_change(:title, &String.trim/1)
    |> validate_required([:title])
    |> validate_length(:title, max: 120)
    |> validate_title()
    |> unique_constraint([:project_id, :title], error_key: :title)
    |> foreign_key_constraint(:project_id)
  end

  defp validate_title(changeset) do
    validate_change(changeset, :title, fn :title, title ->
      if String.match?(title, ~r/[[:alnum:]]/),
        do: [],
        else: [title: "needs at least one letter or number"]
    end)
  end
end
