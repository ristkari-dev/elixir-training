# Lesson 25: Contexts

In lesson 24 the `ProjectController` did everything itself: it built the schemaless changeset, branched on `changeset.valid?`, called `Ecto.Changeset.apply_changes/1`, and talked straight to `Tracker.ProjectStore`. That works, but it smears business logic across the web layer — the controller knows how projects are validated *and* how they're stored.

This lesson introduces a **context**: `Tracker.Projects`, a plain module that is the **boundary** for everything project-related. The controller stops reaching into storage and changesets and instead calls a small, intention-revealing API — `list_projects/0`, `get_project!/1`, `change_project/1`, `create_project/1`. The store is unchanged; this lesson is about the *boundary*, not persistence. That boundary is what lets lesson 29 swap the in-memory `Agent` for Postgres without the controller noticing.

This closes **Phase 3a**. Next is Phase 3b — auth, Postgres, and LiveView.

## What you should be able to do

After this lesson you should be able to:

- Explain why the web layer should call a domain **context** (`Tracker.Projects`) instead of touching the store or building changesets itself.
- Implement the context API: `list_projects/0`, `get_project!/1`, `change_project/1`, and `create_project/1` (returning `{:ok, project}` or `{:error, changeset}`).
- Refactor a controller to **delegate** to the context, including a `show/2` action that parses the URL id and calls `get_project!/1`.

## Key ideas

**A context is a boundary.** Phoenix calls these modules "contexts": a context groups related functionality behind a public API and hides how it's implemented. `Tracker.Projects` owns two things the controller used to own — **changeset construction** and **talking to the store** — so the web layer can stay thin. A good rule of thumb: a controller action should read like a sentence about *what* happens, not *how* it's stored or validated.

**The Projects API.** The whole boundary is four functions:

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

`create_project/1` returns the conventional `{:ok, project}` / `{:error, changeset}` tuple — the same shape Phoenix generators produce, and the same shape you'll keep using once a real schema and `Repo` are behind it. The `!` on `get_project!/1` is the usual convention: it **raises** when there's no such project rather than returning `nil`. Here the missing-id case raises a plain `RuntimeError` (`ProjectStore.get(id) || raise "..."`).

**The controller just delegates.** Every action now calls the context and nothing else:

```elixir
def index(conn, _params), do: render(conn, :index, projects: Projects.list_projects())

def show(conn, %{"id" => id}) do
  project = Projects.get_project!(String.to_integer(id))
  render(conn, :show, project: project)
end

def new(conn, _params) do
  render(conn, :new, form: Phoenix.Component.to_form(Projects.change_project(), as: :project))
end

def create(conn, %{"project" => params}) do
  case Projects.create_project(params) do
    {:ok, _project} ->
      conn |> put_flash(:info, "Project created.") |> redirect(to: ~p"/projects")

    {:error, changeset} ->
      render(conn, :new, form: Phoenix.Component.to_form(changeset, as: :project))
  end
end
```

Note `show/2`: the id arrives from the URL as a **string**, so it calls `String.to_integer(id)` before handing it to `get_project!/1` (the store keys projects by integer id). And `to_form/2` is still called fully qualified as `Phoenix.Component.to_form/2` — it isn't imported in a controller.

**Same API, swappable store.** Because the controller depends only on `Tracker.Projects`, the in-memory `ProjectStore` is now an implementation detail behind the boundary. In lesson 29 the store is replaced by Postgres (an Ecto schema + `Repo`), and `Tracker.Projects` keeps the exact same function names and return shapes — so the web layer doesn't change at all. That's the whole point of the boundary.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=25-contexts` from the repo root to view).
3. Open `exercises/` and read `lib/tracker_web/controllers/project_controller.ex` — it's already written and delegates to `Tracker.Projects`. Your job is the context in `lib/tracker/projects.ex`, whose four functions are stubbed.
4. Run `mix test --include pending`. The context tests in `test/tracker/projects_test.exs` (and the controller tests, which now route through the context) fail. Implement the four functions.
5. Stuck? Read `HINTS.md` one hint at a time.
6. Compare against `solutions/` only after you have a working answer.

## Common mistakes

- **Leaking `Ecto`/store calls back into the controller.** The point of the context is that `Ecto.Changeset.*` and `ProjectStore.*` calls live in `Tracker.Projects` *only*. If you find yourself typing `ProjectStore` or `Ecto.Changeset` in the controller, push it into the context.
- **Forgetting `String.to_integer/1` in `show`.** The id in `~p"/projects/:id"` is a string; the store keys by integer. `get_project!("1")` won't find `%{id: 1}`. Parse it first. Note the two distinct failure modes: a non-numeric id like `/projects/abc` raises `ArgumentError` from `String.to_integer/1` *before* the context is reached, while a well-formed but missing id like `/projects/999` reaches `get_project!/1` and raises `RuntimeError`.
- **Returning the wrong shape from `create_project/1`.** It must be `{:ok, project}` or `{:error, changeset}` — the controller's `case` matches on exactly those. Also keep the `%{changeset | action: :insert}` so the re-rendered form actually shows its errors.

## Links

- [Phoenix — Contexts](https://hexdocs.pm/phoenix/contexts.html)
- [`Ecto.Changeset` — schemaless changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-schemaless-changesets)
- [`Phoenix.Component.to_form/2`](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#to_form/2)
