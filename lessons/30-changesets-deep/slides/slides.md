# Lesson 30
## Changesets deep dive — making bad data impossible

Two machines enforce your rules. Only one of them can see the other rows.

---

## The changeset moves house

Out of the context, into the schema. Public now, beside the fields it talks
about.

--

### `lib/tracker/projects/project.ex`

```elixir
defmodule Tracker.Projects.Project do
  use Ecto.Schema
  import Ecto.Changeset              # new

  schema "projects" do
    # the same fields as lesson 29 — but see `status`, next slide
  end

  def changeset(project, attrs) do   # was a defp in the context
    # cast, trim, validate, declare the constraints
  end
end
```

`Tracker.Projects` becomes a thin caller. Every context signature is unchanged,
so the controller and the LiveView don't move.

---

## `Ecto.Enum`

A **type**, not a validation. It rejects during `cast/4` itself.

--

### one field line, no migration

```elixir
field :status, Ecto.Enum, values: [:open, :closed], default: :open
```

String-backed: the column is still `varchar` holding `"open"`. Elixir sees
`:open`.

```elixir
changeset = Issues.change_issue(%{"title" => "Fine", "status" => "sideways"})
changeset.valid?              #=> false
errors_on(changeset).status   #=> ["is invalid"]
```

Don't add `validate_inclusion/3` beside it — a failed cast records no change,
so the validation could never run.

--

### and the form gets a dropdown

```heex
<.input
  field={@form[:status]}
  type="select"
  prompt="Choose a status"
  options={Ecto.Enum.values(Tracker.Projects.Project, :status)}
  label="Status"
/>
```

`prompt` is what renders the blank `<option>`. Choose it and `cast/4`
substitutes the schema default and records **no change** — so it saves as
`open`. Absent is not wrong.

This is the one web-layer line lesson 30 touches.

---

## Validations

Elixir-side. Each one is handed exactly one changeset, and can see nothing else.

--

### trim, *then* measure

```elixir
|> cast(attrs, [:name, :status])
|> update_change(:name, &String.trim/1)
|> validate_required([:name])
|> validate_length(:name, min: 2, max: 80)
```

`update_change/3` rewrites the change the later steps read.

Move the trim below the length check and `"  A  "` passes `min: 2` — then gets
stored as `"A"`.

--

### an error is a `{message, opts}` pair

```elixir
{"should be at most %{count} character(s)",
 [count: 120, validation: :length, kind: :max, type: :string]}
```

Stored **uninterpolated**. Two independent consumers fill in `%{count}`:

- tests: `errors_on/1` → its own `Regex.replace` over `opts`
- browser: `<.input>` → `translate_error/1` → Gettext → `errors.po`

Not a chain. Neither knows about the other.

---

## Write your own

A validation is just `changeset -> changeset`. That's why `|>` composes yours
with Ecto's.

--

### `validate_change/3` — the primitive

```elixir
defp validate_name(changeset) do
  validate_change(changeset, :name, fn :name, name ->
    if String.match?(name, ~r/[[:alnum:]]/),
      do: [],
      else: [name: "needs at least one letter or number"]
  end)
end
```

Return `[]` for fine, a keyword list for broken. Pipe it in as
`|> validate_name()`.

--

### `get_field` + `add_error` — the other spelling

```elixir
defp validate_email_changed(changeset) do
  if get_field(changeset, :email) && get_change(changeset, :email) == nil do
    add_error(changeset, :email, "did not change")
  else
    changeset
  end
end
```

Same shape, no wrapper. Shipped in `lib/tracker/accounts/user.ex` since
lesson 26 — you can read it now.

---

## Constraints

Postgres-side. The only thing that can see the other rows, at the instant it
writes them.

--

### the round trip

```elixir
# priv/repo/migrations/..._add_unique_project_name_index.exs
create unique_index(:projects, [:user_id, :name])

# lib/tracker/projects/project.ex
|> unique_constraint([:user_id, :name], error_key: :name)
```

Same columns, same order → both sides derive the same name,
`projects_user_id_name_index`. No `:name` option needed.

--

### the helper enforces nothing — it translates

```text
index, no declaration   → raises Ecto.ConstraintError
index + declaration     → {:error, changeset}
declaration, no index   → silence. the duplicate saves.
```

That third line is why `issue_changeset_test.exs` asks `pg_indexes` whether the
index is really there.

--

### `error_key` is not decoration

`unique_constraint([:user_id, :name])` attaches the error to the list's
**first** field — `:user_id`.

No form has a `user_id` input, and `<.input>` renders errors only for fields
that were submitted.

→ the form redisplays with **nothing shown at all**.

---

## The habit to unlearn

```elixir
if changeset.valid? do    # lessons 24, 25, 29
```

--

### a valid changeset can still fail

`Repo.insert/1` on an **invalid** changeset issues no SQL at all.

So Postgres only ever sees changesets that already passed every validation, and
a validation error and a constraint error can never arrive together.

And a changeset that passed every validation can still return
`{:error, changeset}` — `"has already been taken"` arrives only from Postgres.

Branch on `{:ok, _} | {:error, _}`, not on `valid?`.

--

### except NOT NULL, which just raises

`not_null_violation` has no entry in the Postgres→Ecto constraint mapping.
There is no `null_constraint/3` to declare.

```elixir
%Postgrex.Error{postgres: %{code: :not_null_violation, column: "title"}}
```

Unique and foreign-key violations become changeset errors **once declared**.
NOT NULL raises. That's the honest version.

--

### and one function opts out entirely

```elixir
issue
|> Changeset.change(status: flip(issue.status))   # toggle_issue/1
|> Repo.update!()
```

`change/2` neither casts nor validates — it stores what you give it. So a
leftover `status: "closed"` **string** is `valid?: true` with no errors, and
`Repo.update!/1` raises `Ecto.ChangeError` when the enum refuses to dump it.

Loud, but one layer from where you'd look.

---

## Two machines, one boundary

- Elixir: this changeset, these fields. Fast, precise messages.
- Postgres: every row, at write time. The only real guarantee.
- The changeset helper is the translator between them.

--

### Next: lesson 31 — queries

Joins, preloads, composition — the DSL you've been copying one line of.

```
make slides-dev LESSON=31-queries
```
