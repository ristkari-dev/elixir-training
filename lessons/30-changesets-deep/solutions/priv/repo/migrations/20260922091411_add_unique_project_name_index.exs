defmodule Tracker.Repo.Migrations.AddUniqueProjectNameIndex do
  use Ecto.Migration

  def change do
    create unique_index(:projects, [:user_id, :name])
  end
end
