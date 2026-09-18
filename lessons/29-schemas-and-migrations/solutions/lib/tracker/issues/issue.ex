defmodule Tracker.Issues.Issue do
  @moduledoc "An issue row: an Elixir struct that mirrors the `issues` table."
  use Ecto.Schema

  schema "issues" do
    field :title, :string
    field :status, :string, default: "open"
    field :project_id, :id

    timestamps type: :utc_datetime
  end
end
