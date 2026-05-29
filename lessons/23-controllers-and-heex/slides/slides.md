# Lesson 23
## Controllers and HEEx

A route names an action. An action picks data and renders a template.
Today: the Tracker **Projects index** — a real HTML page.

---

## Controller actions & render

An action is a plug-shaped function. Conn in, conn out.

--

### index/2

```elixir
def index(conn, _params) do
  projects = [
    %{id: 1, name: "Apollo", status: "open"},
    %{id: 2, name: "Gemini", status: "open"}
  ]

  render(conn, :index, projects: projects)
end
```

It does two things: decide *what* data the page needs, then hand it off.

--

### render/3

```elixir
render(conn, :index, projects: projects)
```

"Render the `:index` template, and make `projects` available in it."
Each keyword becomes an **assign** — `@projects` inside the template.

Still no database — the list is hard-coded for now (a store lands lesson 24).

---

## HEEx & assigns

HTML with Elixir holes.

--

### The view module finds the template

```elixir
defmodule TrackerWeb.ProjectHTML do
  use TrackerWeb, :html
  embed_templates "project_html/*"
end
```

`:index` resolves to `project_html/index.html.heex`. The controller and
its `*HTML` module are a pair.

--

### {...} drops a value in

```heex
{project.name}
```

`{...}` interpolates a value into an attribute or a tag body. Assigns
arrive as `@projects`, `@flash`, … — whatever the action passed (plus the
ones Phoenix sets for you).

---

## Layouts & core components

The generated app ships components. Reuse them.

--

### Layouts.app wraps the page

```heex
<Layouts.app flash={@flash}>
  ...your content...
</Layouts.app>
```

The app shell: navbar, flash messages, centered `<main>`. Every full HTML
page wraps in it.

--

### header + table

```heex
<.header>Projects</.header>

<.table id="projects" rows={@projects}>
  <:col :let={project} label="Name">{project.name}</:col>
  <:col :let={project} label="Status">{project.status}</:col>
</.table>
```

`<.table>` renders one row per item. `:let={project}` binds the current
row so the column body can read it. Forget `:let` and `project` isn't in scope.

---

## The projects index

Route → action → template → HTML.

--

### Wired with a verified route

```elixir
resources "/projects", ProjectController, only: [:index]
```

```heex
~p"/projects"
```

`resources ... only: [:index]` declares `GET /projects → :index`.
`~p` checks the path exists **at compile time** — a typo fails the build,
not the user. Run `mix phx.routes` to see it.

---

## Next: lesson 24 — a real store

The projects are hard-coded today. Next we move them into an in-memory
store and add a form to create one — `<.form>` + `to_form/2`,
schemaless-changeset validation, still no Postgres.

```
make slides-dev LESSON=24-forms-and-changesets-preview
```
