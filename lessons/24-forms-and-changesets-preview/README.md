# Lesson 24: Forms and Changesets (preview)

In lesson 23 the Projects index rendered a hard-coded list. Now you'll make it **real**: a `New project` form that **creates** a project, and an index that reads what you've created. There's still no database — projects live in an in-memory **`ProjectStore`** (an `Agent`, exactly like the ones from Phase 2), started by the app's supervision tree. Postgres arrives in lesson 26.

To validate the submitted form you'll use a **changeset** — but a *schemaless* one. No Ecto schema, no Repo. Just `Ecto.Changeset.cast/4` over a plain `{data, types}` tuple, which is enough to cast fields and require a name. This is your first taste of the form + changeset pattern that powers every Phoenix CRUD page.

## What you should be able to do

After this lesson you should be able to:

- Render a form with `<.form for={@form} action={~p"/projects"}>` and `<.input field={@form[:name]} .../>`, where `@form` comes from `Phoenix.Component.to_form(changeset, as: :project)`.
- Handle the POST: read params as `%{"project" => params}`, validate them, and either add to the store + `put_flash` + `redirect`, or re-render the form showing errors.
- Validate **without a database** using a schemaless changeset — `cast/4` + `validate_required/2` over a `{data, types}` tuple — and read `changeset.valid?` / `Ecto.Changeset.apply_changes/1`.

## Key ideas

**A form is built from a `Phoenix.HTML.Form` struct.** You don't hand-write `<input name="...">`; you build a form struct and let the components render the fields. `to_form/2` turns a changeset (or a plain map) into that struct:

```elixir
def new(conn, _params) do
  render(conn, :new, form: Phoenix.Component.to_form(change(), as: :project))
end
```

In a controller, `to_form/2` is **not** imported — call it fully qualified as `Phoenix.Component.to_form/2`. The `as: :project` part is the important bit: it namespaces the inputs so the browser submits them under a `"project"` key. The template then reads each field off the form:

```heex
<.form for={@form} action={~p"/projects"}>
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:status]} label="Status" />
  <.button>Save</.button>
</.form>
```

`@form[:name]` is the `name` field; `<.input>` renders the right `<input>`, its label, and any errors for that field.

**Handling the POST.** Because of `as: :project`, the params arrive nested under `"project"`, so `create/2` matches them directly:

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

On success: `apply_changes/1` returns a plain map of the cast fields, you store it, flash a message, and **redirect** (the Post/Redirect/Get pattern — a refresh won't re-submit). On failure: you re-render `:new`. The one subtlety is `%{changeset | action: :insert}` — a changeset only shows its errors once it has an `:action` set, so without it the re-rendered form would look blank instead of flagging the missing name.

**Schemaless changesets — validation with no DB.** A changeset doesn't need an Ecto schema. Give `cast/4` a `{data, types}` tuple and it works on a bare map:

```elixir
defp change(attrs \\ %{}) do
  {%{status: "open"}, %{name: :string, status: :string}}
  |> Ecto.Changeset.cast(attrs, [:name, :status])
  |> Ecto.Changeset.validate_required([:name])
end
```

The first element (`%{status: "open"}`) is the **default data**; the second (`%{name: :string, status: :string}`) declares the **field types**. `cast/4` pulls the listed keys out of `attrs`, casts them to those types, and `validate_required/2` flags a blank name. `change()` with no args is an empty form; `change(params)` validates a submission. No schema, no Repo, no Postgres — and the exact same API you'll use with a real schema later.

**The store is an `Agent`.** `Tracker.ProjectStore` keeps a list of projects in process state and is started in `lib/tracker/application.ex`, right alongside the PubSub and Endpoint — a direct callback to the OTP work in Phase 2. `add/1` appends with an auto-incrementing id; `list/0` returns them. Because it's process state, **everything is lost on restart** — that's exactly the gap Postgres fills in lesson 26.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=24-forms-and-changesets-preview` from the repo root to view).
3. Open `exercises/` and read `lib/tracker_web/controllers/project_controller.ex`. `index/2` is done (it reads `ProjectStore.list/0`); `new/2` and `create/2` raise `TODO`. The `change/1` helper, the `new.html.heex` template, and the route are written for you.
4. Run `mix test --include pending`. Three tests fail: render the form, create on valid params, re-render on a blank name. Implement `new/2` and `create/2`.
5. Stuck? Read `HINTS.md` one hint at a time.
6. Compare against `solutions/` only after you have a working answer.

## Try it

From `exercises/` (or `solutions/`):

```
mix phx.server
```

Visit `http://localhost:4000/projects`, click **New project**, and submit. With a name you'll bounce back to the index with the new row; with a blank name the form re-renders with an error. Restart the server and the list is empty again — the store is in memory.

## Common mistakes

- **Forgetting `as: :project`.** Without it, `to_form/2` names the inputs differently and the params arrive under the wrong key — your `%{"project" => params}` match in `create/2` never fires (you get a function-clause/`MatchError`). The `as:` in the controller and the `"project"` in the match must agree.
- **Not setting `changeset.action`.** A changeset only renders its errors once it has an action. If you re-render with the raw changeset, the form comes back looking valid (no error next to the blank name). Set `%{changeset | action: :insert}` (or use `apply_action/2`) on the invalid branch.
- **Expecting data to survive a restart.** The `ProjectStore` is an in-memory `Agent`. Restart the server and the list resets. That's by design here — persistence is lesson 26's job.

## Links

- [Phoenix — Components and HEEx (`<.form>`, `<.input>`)](https://hexdocs.pm/phoenix/components.html)
- [`Phoenix.Component.to_form/2`](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#to_form/2)
- [`Ecto.Changeset` — schemaless changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html#module-schemaless-changesets)
- [`Agent`](https://hexdocs.pm/elixir/Agent.html)
