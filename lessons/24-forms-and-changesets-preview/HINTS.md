# Hints for Lesson 24: Forms and Changesets (preview)

Read these one at a time. Try the exercise after each hint before reading the next.
The drill is two actions: `new/2` renders the form, and `create/2` validates the
submission and either stores it (then redirects) or re-renders with errors. The
`change/1` helper, the `new.html.heex` template, and the route are written for you.

## Hint 1

`new/2` just needs to render the `:new` template with an empty form. The template
expects a `@form` assign built from a changeset. The provided `change/0` helper gives
you an empty changeset; turn it into a form with `to_form/2`.

In a controller `to_form/2` is **not** imported, so call it fully qualified:
`Phoenix.Component.to_form(change(), as: :project)`. The `as: :project` namespaces the
inputs — it's what makes the browser submit params under a `"project"` key (which
`create/2` will match on). Assign it as `form:`.

## Hint 2

`create/2` receives the submitted params. Thanks to `as: :project`, match them as
`%{"project" => params}` in the function head. Build a changeset with `change(params)`
and branch on `changeset.valid?`:

- **valid:** turn the changeset into a plain map with `Ecto.Changeset.apply_changes/1`,
  hand it to `ProjectStore.add/1`, then `put_flash(:info, "...")` and
  `redirect(to: ~p"/projects")`.
- **invalid:** re-render `:new`. For the errors to actually show next to the fields,
  the changeset needs an action — re-render with `%{changeset | action: :insert}` wrapped
  in `to_form/2`.

## Hint 3

Full actions:

```elixir
def new(conn, _params) do
  render(conn, :new, form: Phoenix.Component.to_form(change(), as: :project))
end

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

The `change/1` helper (already in the controller) is the schemaless changeset:

```elixir
defp change(attrs \\ %{}) do
  {%{status: "open"}, %{name: :string, status: :string}}
  |> Ecto.Changeset.cast(attrs, [:name, :status])
  |> Ecto.Changeset.validate_required([:name])
end
```

No schema, no Repo — `cast/4` over a `{data, types}` tuple is enough to validate the
form. `apply_changes/1` then gives you a plain map to store in the in-memory `Agent`.
