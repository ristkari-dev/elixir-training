defmodule Tracker.Repo.Migrations.CreateIssues do
  use Ecto.Migration

  def change do
    create table(:issues) do
      add :title, :string, null: false
      add :status, :string, null: false, default: "open"
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps type: :utc_datetime
    end

    create index(:issues, [:project_id])
  end
end
