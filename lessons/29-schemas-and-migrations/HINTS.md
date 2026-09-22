# Hints for Lesson 29: Schemas & migrations

Read one hint at a time. Try the exercise again before reading the next.
Make sure Postgres is running (`docker compose up -d postgres` from the repo
root) and that you've run `mix ecto.setup` in `exercises/` — this lesson has its
own database. Two drills, 10 pending tests. Projects are already done end to
end; they're the worked example for both drills.

## Drill 1: The `create_issues` migration

### Hint 1

Generate the file with `mix ecto.gen.migration create_issues`, then fill in
`change/0`. Inside it you need `create table(:issues)` with three `add` calls, a
`timestamps` line, and a `create index(...)` after the table. The foreign key
comes from `references/2`. `priv/repo/migrations/*_create_projects.exs` is the
same shape one table over.

### Hint 2

`title` is a `:string` that can't be null. `status` is a `:string` that can't be
null and defaults to `"open"`. `project_id` is
`references(:projects, on_delete: :delete_all)` and also can't be null. The
timestamps line is `timestamps type: :utc_datetime`, matching every other table
in this app. Then, outside the `create table` block:

```elixir
create index(:issues, [:project_id])
```

Run it with `mix ecto.migrate`. If you got the table body wrong and it already
ran, `mix ecto.rollback` before you edit — and the test database is separate
(`MIX_ENV=test mix ecto.rollback`).

### Hint 3

```elixir
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
```

## Drill 2: The `Issue` schema and the `Issues` context

### Hint 1

Two files. `lib/tracker/issues/issue.ex` is a new module that does
`use Ecto.Schema` and declares `schema "issues"` with a `field` per column you
just migrated (except `id`, which Ecto adds) — copy the shape of
`lib/tracker/projects/project.ex`.

Then rewrite `lib/tracker/issues.ex` against `Repo`, deleting the placeholder
data the stub returns: `Repo.all/1` for `list_issues/1`, `Repo.insert/1` for
`create_issue/2`, and `Repo.get!/2` + `Ecto.Changeset.change/2` + `Repo.update!/1`
for `toggle_issue/1`. `change_issue/1` stops being a `{data, types}` changeset
and casts into `%Issue{}` instead.

### Hint 2

The schema needs `default: "open"` on `status`, so a form that leaves it blank
still produces an open issue, and `field :project_id, :id` — a plain id column,
not an association.

In the context, `project_id` is never cast. Set it on the struct and pipe that
into the changeset:

```elixir
def create_issue(project_id, attrs) do
  %Issue{project_id: project_id}
  |> changeset(attrs)
  |> Repo.insert()
end
```

`list_issues/1` needs `import Ecto.Query` at the top of the module, and the same
one-line query `list_projects/1` uses — filter on `project_id`, order by `id`
ascending. `toggle_issue/1` returns the updated struct itself (not a tuple), so
the LiveView can `stream_insert` it: `Repo.update!/1` gives you exactly that.

### Hint 3

`lib/tracker/issues/issue.ex`:

```elixir
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
```

`lib/tracker/issues.ex`:

```elixir
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

  def change_issue(attrs \\ %{}), do: changeset(%Issue{}, attrs)

  def create_issue(project_id, attrs) do
    %Issue{project_id: project_id}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def toggle_issue(id) do
    issue = Repo.get!(Issue, id)

    issue
    |> Changeset.change(status: flip(issue.status))
    |> Repo.update!()
  end

  defp changeset(issue, attrs) do
    issue
    |> Changeset.cast(attrs, [:title])
    |> Changeset.validate_required([:title])
  end

  defp flip("open"), do: "closed"
  defp flip(_), do: "open"
end
```
