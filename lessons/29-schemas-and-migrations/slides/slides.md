# Lesson 29
## Schemas & migrations — the Agent is gone

Projects and issues move into Postgres. The web layer doesn't change a line.

---

## The migration

The database side. Generated, filled in by hand, run once.

--

### `mix ecto.gen.migration create_projects`

```elixir
def change do
  create table(:projects) do
    add :name, :string, null: false
    add :status, :string, null: false, default: "open"
    add :user_id, references(:users, on_delete: :delete_all), null: false

    timestamps type: :utc_datetime
  end

  create index(:projects, [:user_id])
end
```

`mix ecto.migrate` runs it and records the name in `schema_migrations`.
Already run? Editing the file does nothing — roll back, or migrate on top.

---

## The schema

The Elixir side. A struct that names a table. Creates nothing.

--

### `lib/tracker/projects/project.ex`

```elixir
defmodule Tracker.Projects.Project do
  use Ecto.Schema

  schema "projects" do
    field :name, :string
    field :status, :string, default: "open"
    field :user_id, :id

    timestamps type: :utc_datetime
  end
end
```

`%Project{}` is an ordinary struct — lesson 10's kind. Ecto adds `:id` for you.
`default: "open"` is the Elixir-side twin of the migration's `default: "open"`.

---

## field → column

Every `field` is a promise about a column.

--

### what `\d issues` shows (abridged)

```text
 title        | character varying(255) | not null
 status       | character varying(255) | not null | default 'open'
 project_id   | bigint                 | not null
 inserted_at  | timestamp(0) without time zone | not null
```

`:string` → `varchar(255)`. `:id` → `bigint`, matching `projects.id`'s
`bigserial`. `timestamps type: :utc_datetime` → `timestamp(0)`.

--

### not `timestamptz`

`:utc_datetime` is a guarantee **Ecto** enforces, in Elixir: it only ever
stores a `DateTime` whose zone is `Etc/UTC`.

So the column needs no time zone of its own. (The users table has one more
type worth a look: `:citext`, case-insensitive text.)

---

## Repo replaces the Agent

`Tracker.IssueStore` is deleted. Four functions do its job.

--

### the whole storage layer

```elixir
Repo.all(query)             # list_issues/1
Repo.insert(changeset)      # create_issue/2 → {:ok, issue} | {:error, changeset}
Repo.get!(Issue, id)        # raises Ecto.NoResultsError — a 404, not a 500
Repo.update!(changeset)     # toggle_issue/1 → the updated struct
```

Same context API as lesson 25 promised. `ProjectController` and
`ProjectBoardLive` are byte-identical to lesson 28.

--

### toggle, end to end

```elixir
def toggle_issue(id) do
  issue = Repo.get!(Issue, id)

  issue
  |> Changeset.change(status: flip(issue.status))
  |> Repo.update!()
end
```

`change/2` builds a changeset straight from values — no `cast`, because this
data came from us, not from a form.

---

## Ordering

A table has no inherent order. Toggling rewrites a row.

--

### one line of query, on loan from lesson 31

```elixir
from(i in Issue, where: i.project_id == ^project_id, order_by: [asc: i.id])
|> Repo.all()
```

Read it as "this project's rows, oldest first". **Lesson 31 explains this
DSL** — joins, composition, the lot. Today it's a line you copy.

Without `order_by`, the board reshuffles every time you toggle something.

---

## Why index `project_id`

Every board load asks for one project's issues.

--

### the filter you run constantly

```elixir
create index(:issues, [:project_id])   # its own line, after the table
```

No index: Postgres reads *every* row in `issues` to find one project's.
With it: straight to them.

`references/2` creates the foreign key, **not** the index. Forgetting this
line is a classic slow-app bug.

---

## Why not `mix phx.gen.schema`?

It would have written both files. We wrote them by hand.

--

### what the generator emits

```elixir
# mix phx.gen.schema Issues.Issue issues title:string status:string
def changeset(issue, attrs, user_scope) do
  issue
  |> cast(attrs, [:title, :status])
  |> validate_required([:title, :status])
  |> put_change(:user_id, user_scope.user.id)
end
```

A default scope is configured (lesson 26), so it writes a 3-arity changeset
that stamps `user_id` — not the API our contexts expose.

Beginners should watch the DSL get built line by line anyway.

---

## Phase 4 begun

Migration → schema → `Repo`. The data survives a restart.

--

### Next: lesson 30 — changesets-deep

Validations, constraints, `Ecto.Enum` — making bad data impossible.

```
make slides-dev LESSON=30-changesets-deep
```
