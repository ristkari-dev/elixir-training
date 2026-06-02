# Hints for Lesson 25: Contexts

Read these one at a time. Try the exercise after each hint before reading the next.
The controller is already written and delegates to `Tracker.Projects`. The drill is
the context: implement the four functions in `lib/tracker/projects.ex` so they wrap
`ProjectStore` and the schemaless changeset.

## Hint 1

Each context function is a thin wrapper:

- `list_projects/0` → just `ProjectStore.list()`.
- `get_project!/1` → `ProjectStore.get(id)`, but `!` means it must **raise** when there's
  no such project. `ProjectStore.get/1` returns `nil` for a miss, so reach for the
  `value || raise "..."` idiom.
- `change_project/1` → the same schemaless changeset you wrote in lesson 24
  (`cast/4` over a `{data, types}` tuple + `validate_required([:name])`), just moved here.

## Hint 2

`create_project/1` is the lesson-24 `create` logic minus the HTTP parts. Build the
changeset, then branch on `changeset.valid?`:

- **valid:** `apply_changes/1` → `ProjectStore.add/1` → return `{:ok, project}`.
- **invalid:** return `{:error, %{changeset | action: :insert}}` (the `action` is what
  makes the form show its errors when the controller re-renders it).

The controller already matches on `{:ok, _}` / `{:error, changeset}`, so the return
shape has to be exactly that.

## Hint 3

The full context:

```elixir
defmodule Tracker.Projects do
  @moduledoc "The Projects context: the boundary for project business logic."
  alias Tracker.ProjectStore

  @types %{name: :string, status: :string}

  def list_projects, do: ProjectStore.list()

  def get_project!(id) do
    ProjectStore.get(id) || raise "no project with id #{inspect(id)}"
  end

  def change_project(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> Ecto.Changeset.validate_required([:name])
  end

  def create_project(attrs) do
    changeset = change_project(attrs)

    if changeset.valid? do
      project = changeset |> Ecto.Changeset.apply_changes() |> ProjectStore.add()
      {:ok, project}
    else
      {:error, %{changeset | action: :insert}}
    end
  end
end
```

All the `Ecto.Changeset.*` and `ProjectStore.*` calls now live here — the controller
just calls these four functions. That boundary is what lets lesson 29 swap the store
for Postgres without touching the web layer.
