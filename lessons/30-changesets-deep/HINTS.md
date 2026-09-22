# Hints for Lesson 30: Changesets deep dive

Read one hint at a time. Try the exercise again before reading the next.
Make sure Postgres is running (`docker compose up -d postgres` from the repo
root) and that you've run `mix ecto.setup` in `exercises/` — this lesson has its
own database. Two drills, 9 pending tests. Projects are done end to end;
`lib/tracker/projects/project.ex` is the worked example for both drills.

## Drill 1: `Issue.changeset/2`

### Hint 1

The private `changeset/2` currently at the bottom of `lib/tracker/issues.ex`
moves into `lib/tracker/issues/issue.ex` and becomes **public**, which means
that file needs `import Ecto.Changeset` next to its `use Ecto.Schema`.
`Tracker.Issues` then calls `Issue.changeset/2` in the two places it used to
call its own — and keeps every public function name, arity and return shape
exactly as it is.

While it's open, the schema's `status` field stops being a `:string`. The type
that takes a list of allowed values is `Ecto.Enum`.

Four new names in the changeset pipeline: `update_change/3` for the trim,
`validate_length/3` for the cap, `validate_change/3` inside a private
`validate_title/1`, and `:status` joining `:title` in the `cast/4` list.
Everything is one table over in `project.ex`.

### Hint 2

The field is `field :status, Ecto.Enum, values: [:open, :closed], default: :open`.
No migration: the column stays a string, Elixir just sees atoms now. Follow the
atoms all the way — `flip/1` in `lib/tracker/issues.ex` still matches the
strings `"open"` and `"closed"`, and if you leave it that way `toggle_issue/1`
raises `Ecto.ChangeError` from `Repo.update!/1`.

The pipeline order is load-bearing. `update_change(:title, &String.trim/1)`
goes **immediately after `cast/4`**, before `validate_required/2` and
`validate_length(:title, max: 120)`, because it rewrites the change those later
steps read. No `min:` on the title.

`validate_change/3` takes the field and a function of `(field, value)` that
returns `[]` when the value is fine, or a keyword list of errors when it isn't:

```elixir
defp validate_title(changeset) do
  validate_change(changeset, :title, fn :title, title ->
    # return [] or [title: "needs at least one letter or number"]
  end)
end
```

`String.match?(title, ~r/[[:alnum:]]/)` is the test for "has a letter or a
digit". Pipe the whole thing in as `|> validate_title()`.

### Hint 3

`lib/tracker/issues/issue.ex` — the two constraint lines are drill 2's, so
they're not here yet:

```elixir
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
  end

  defp validate_title(changeset) do
    validate_change(changeset, :title, fn :title, title ->
      if String.match?(title, ~r/[[:alnum:]]/),
        do: [],
        else: [title: "needs at least one letter or number"]
    end)
  end
end
```

In `lib/tracker/issues.ex`, delete the private `changeset/2`, call the schema's
instead, and flip atoms. Keep `alias Ecto.Changeset` — `toggle_issue/1` still
uses it:

```elixir
  def change_issue(attrs \\ %{}), do: Issue.changeset(%Issue{}, attrs)

  def create_issue(project_id, attrs) do
    %Issue{project_id: project_id}
    |> Issue.changeset(attrs)
    |> Repo.insert()
  end

  # Not user input: an internal flip of a value we control, so it skips
  # Issue.changeset/2 and every validation in it.
  def toggle_issue(id) do
    issue = Repo.get!(Issue, id)

    issue
    |> Changeset.change(status: flip(issue.status))
    |> Repo.update!()
  end

  defp flip(:open), do: :closed
  defp flip(_), do: :open
```

## Drill 2: The issue constraints

### Hint 1

Two halves, and both are needed. The database half is a migration:
`mix ecto.gen.migration add_unique_issue_title_index`, then one `create
unique_index(...)` line in `change/0`. The Elixir half is two declarations at
the end of `Issue.changeset/2`: `unique_constraint/3` and
`foreign_key_constraint/3`.

Neither half enforces anything on its own. The index is what actually rejects a
duplicate; the declaration is only what turns the rejection into
`{:error, changeset}` instead of a raised `Ecto.ConstraintError`. Declare a
constraint with no index behind it and nothing happens at all — no error, and
duplicates save.

The foreign key needs **no** migration: `references(:projects, ...)` created it
back in lesson 29. Only its declaration is missing.

`priv/repo/migrations/*_add_unique_project_name_index.exs` and the last two
lines of `Project.changeset/2` are the worked example.

### Hint 2

Uniqueness here is per project, not global: two different projects may each have
an issue called "Fix login". So the index covers **two** columns,
`[:project_id, :title]`, in that order.

That order is doing two jobs. It derives the constraint name — Ecto infers
`issues_project_id_title_index` from the changeset side and `mix ecto.migrate`
builds the same string from the migration side, so they match with no `:name`
option, *provided you write the columns the same way in both places*. And it
decides which field the error lands on: Ecto takes the **first** element, which
would be `:project_id`, a column no form has an input for. `error_key: :title`
is what puts the message where a person can see it.

Both declarations go at the **end** of the pipeline, after the validations.
`foreign_key_constraint(:project_id)` needs no options: the name Ecto infers,
`issues_project_id_fkey`, is already Postgres's own default.

Run `mix ecto.migrate` after generating the migration — and remember the test
database is separate, though `mix test` migrates it for you.

### Hint 3

`priv/repo/migrations/<timestamp>_add_unique_issue_title_index.exs`:

```elixir
defmodule Tracker.Repo.Migrations.AddUniqueIssueTitleIndex do
  use Ecto.Migration

  def change do
    create unique_index(:issues, [:project_id, :title])
  end
end
```

And the two lines at the end of `Issue.changeset/2`:

```elixir
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
```

Write the declaration but forget the migration and nothing raises and nothing
warns: `Repo.insert/1` only consults your declarations when the adapter reports
a violation, and an index that doesn't exist never reports one. The duplicate
just saves, and two tests go red — the duplicate one and the `pg_indexes` one,
which is there precisely because no amount of Elixir can fake it.
