defmodule Tracker.Repo.Migrations.AddUniqueIssueTitleIndex do
  use Ecto.Migration

  def change do
    create unique_index(:issues, [:project_id, :title])
  end
end
