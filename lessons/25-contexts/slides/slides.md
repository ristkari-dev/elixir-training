# Lesson 25
## Contexts

In lesson 24 the controller did everything: built the changeset, branched on
`valid?`, and talked straight to the store. Today we put a **boundary** between
the web layer and the domain — a `Tracker.Projects` context.

---

## Why contexts (the boundary)

A controller shouldn't know *how* a project is validated or stored.

--

### Before: the controller knows everything

```elixir
def create(conn, %{"project" => params}) do
  changeset = change(params)               # builds the changeset
  if changeset.valid? do
    changeset |> Ecto.Changeset.apply_changes() |> ProjectStore.add()  # talks to storage
    ...
  end
end
```

Validation logic *and* storage logic, smeared across the web layer.

--

### After: a context owns the domain

`Tracker.Projects` is a plain module — the **public API** for projects. It owns
changeset construction and the store; the controller just calls it.

> A controller action should read like *what* happens, not *how* it's stored.

---

## The Projects API

Four functions — the whole boundary.

--

### list / get / change / create

```elixir
def list_projects, do: ProjectStore.list()

def get_project!(id) do
  ProjectStore.get(id) || raise "no project with id #{inspect(id)}"
end

def change_project(attrs \\ %{}) do
  {%{status: "open"}, %{name: :string, status: :string}}
  |> Ecto.Changeset.cast(attrs, [:name, :status])
  |> Ecto.Changeset.validate_required([:name])
end
```

`get_project!/1` — the `!` convention: **raise** on a miss, don't return `nil`.

--

### create_project returns a tagged tuple

```elixir
def create_project(attrs) do
  changeset = change_project(attrs)

  if changeset.valid? do
    project = changeset |> Ecto.Changeset.apply_changes() |> ProjectStore.add()
    {:ok, project}
  else
    {:error, %{changeset | action: :insert}}
  end
end
```

`{:ok, project}` | `{:error, changeset}` — the same shape a real `Repo` returns.

---

## Controller delegates to the context

Each action calls the context and nothing else.

--

### Thin actions

```elixir
def index(conn, _params),
  do: render(conn, :index, projects: Projects.list_projects())

def show(conn, %{"id" => id}) do
  project = Projects.get_project!(String.to_integer(id))
  render(conn, :show, project: project)
end

def create(conn, %{"project" => params}) do
  case Projects.create_project(params) do
    {:ok, _project} -> conn |> put_flash(:info, "Project created.") |> redirect(to: ~p"/projects")
    {:error, changeset} -> render(conn, :new, form: Phoenix.Component.to_form(changeset, as: :project))
  end
end
```

--

### Two small gotchas

- `show/2`: the URL id is a **string** → `String.to_integer(id)` before `get_project!`.
- `to_form/2` isn't imported in a controller — call it `Phoenix.Component.to_form/2`.

---

## Same API, swappable store

The controller depends only on `Tracker.Projects`.

--

### The store is now an implementation detail

```text
Controller  ->  Tracker.Projects  ->  ProjectStore (Agent, in-memory)
                     ^ the boundary          ^ swappable
```

In **lesson 29** the `Agent` becomes Postgres (an Ecto schema + `Repo`).
`Tracker.Projects` keeps the same function names and return shapes — so the web
layer doesn't change at all. That's the whole point of the boundary.

---

## Wrap-up

- A **context** (`Tracker.Projects`) is the boundary: it owns changesets and storage.
- API: `list_projects/0`, `get_project!/1`, `change_project/1`, `create_project/1`.
- `create_project/1` → `{:ok, project}` | `{:error, changeset}`; `get_project!/1` raises on a miss.
- The controller just **delegates** — no `Ecto`/store calls leak into the web layer.

**Phase 3a done. Next: Phase 3b — auth, Postgres, LiveView.**
