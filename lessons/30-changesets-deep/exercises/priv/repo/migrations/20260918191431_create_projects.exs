defmodule Tracker.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :status, :string, null: false, default: "open"
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps type: :utc_datetime
    end

    create index(:projects, [:user_id])
  end
end
