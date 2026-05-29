# Lesson 24
## Forms and Changesets (preview)

Lesson 23 rendered a hard-coded list. Today the Tracker gets a **New project**
form that actually creates one — validated, stored in memory, no database yet.

---

## Forms with &lt;.form&gt; / &lt;.input&gt;

A form is a struct. Build it, let the components render it.

--

### to_form/2 builds the form

```elixir
def new(conn, _params) do
  render(conn, :new, form: Phoenix.Component.to_form(change(), as: :project))
end
```

In a controller `to_form/2` isn't imported — call it fully qualified.
`as: :project` namespaces the inputs (params arrive under `"project"`).

--

### The template reads fields off @form

```heex
<.form for={@form} action={~p"/projects"}>
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:status]} label="Status" />
  <.button>Save</.button>
</.form>
```

`@form[:name]` is the field; `<.input>` renders the input, label, and errors.

---

## Schemaless changesets

Validate without a database.

--

### cast/4 over a {data, types} tuple

```elixir
defp change(attrs \\ %{}) do
  {%{status: "open"}, %{name: :string, status: :string}}
  |> Ecto.Changeset.cast(attrs, [:name, :status])
  |> Ecto.Changeset.validate_required([:name])
end
```

Default data + field types — no schema, no Repo. `cast/4` casts the listed
keys; `validate_required/2` flags a blank name. Same API as a real schema later.

---

## Handling POST: valid vs invalid

Match the params, branch on `changeset.valid?`.

--

### create/2

```elixir
def create(conn, %{"project" => params}) do
  changeset = change(params)

  if changeset.valid? do
    changeset |> Ecto.Changeset.apply_changes() |> ProjectStore.add()

    conn
    |> put_flash(:info, "Project created.")
    |> redirect(to: ~p"/projects")
  else
    render(conn, :new, form: Phoenix.Component.to_form(%{changeset | action: :insert}, as: :project))
  end
end
```

--

### The two gotchas

- **Valid:** `apply_changes/1` → a plain map → store → flash → **redirect**
  (Post/Redirect/Get — a refresh won't re-submit).
- **Invalid:** re-render. Set `%{changeset | action: :insert}` or the errors
  won't show — a changeset only renders errors once it has an action.

---

## The in-memory ProjectStore

An `Agent` — straight back to Phase 2.

--

### Started by the supervision tree

```elixir
children = [
  TrackerWeb.Telemetry,
  {DNSCluster, ...},
  {Phoenix.PubSub, name: Tracker.PubSub},
  Tracker.ProjectStore,
  TrackerWeb.Endpoint
]
```

`add/1` appends with an auto-incrementing id; `list/0` returns them.
Process state — **lost on restart**. That's the gap Postgres fills next.

---

## Next: lesson 25 — contexts

The controller talks straight to the store today. Next we put a **context**
between them — a `Projects` module that owns `list_projects/0`, `create_project/1`,
and the changeset — so the web layer stops reaching into storage directly.

```
make slides-dev LESSON=25-contexts
```
