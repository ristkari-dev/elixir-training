defmodule Tracker.Projects.Project do
  @moduledoc "A project row: an Elixir struct that mirrors the `projects` table."
  use Ecto.Schema

  schema "projects" do
    field :name, :string
    field :status, :string, default: "open"
    field :user_id, :id

    timestamps type: :utc_datetime
  end
end
