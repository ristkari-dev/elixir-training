defmodule Tracker.Projects.Project do
  @moduledoc "A project row, and the rules a project has to satisfy."
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :status, Ecto.Enum, values: [:open, :closed], default: :open
    field :user_id, :id

    timestamps type: :utc_datetime
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :status])
    |> update_change(:name, &String.trim/1)
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 80)
    |> validate_name()
    |> unique_constraint([:user_id, :name], error_key: :name)
  end

  # A validation is just changeset -> changeset, so `|>` composes ours with
  # Ecto's. validate_change/3 is the primitive underneath.
  defp validate_name(changeset) do
    validate_change(changeset, :name, fn :name, name ->
      if String.match?(name, ~r/[[:alnum:]]/),
        do: [],
        else: [name: "needs at least one letter or number"]
    end)
  end
end
