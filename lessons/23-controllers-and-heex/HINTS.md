# Hints for Lesson 23: Controllers and HEEx

Read these one at a time. Try the exercise after each hint before reading the next.
The drill is the `GET /projects` page: make the `index/2` action render a list of projects.

## Drill: GET /projects lists the projects

### Hint 1

The route is already wired (`resources "/projects", ProjectController, only: [:index]`)
and the template is written for you (`project_html/index.html.heex`). Your job is the
action. `index/2` takes `(conn, _params)` and must do two things: build the data, then
hand it to the template. It hands off with `render/3` — `render(conn, :index, ...)` —
where the third argument is the **assigns** the template needs.

The template reads `@projects`, so the action must assign `projects:`. Each project is a
map with `name` and `status` keys (the table has a "Name" and a "Status" column).

### Hint 2

Build a list of two project maps and pass it as the `projects:` assign:

```elixir
def index(conn, _params) do
  projects = [
    %{id: 1, name: "Apollo", status: "open"},
    %{id: 2, name: "Gemini", status: "open"}
  ]

  render(conn, :index, projects: projects)
end
```

The keyword `projects: projects` is what becomes `@projects` inside the template. The
template iterates them: `<.table rows={@projects}>` renders one row per map, and each
`<:col :let={project} label="...">{project.name}</:col>` reads a field off the current row.

### Hint 3

Full controller:

```elixir
defmodule TrackerWeb.ProjectController do
  use TrackerWeb, :controller

  def index(conn, _params) do
    projects = [
      %{id: 1, name: "Apollo", status: "open"},
      %{id: 2, name: "Gemini", status: "open"}
    ]

    render(conn, :index, projects: projects)
  end
end
```

The matching template (already provided) wraps the table in the app layout:

```heex
<Layouts.app flash={@flash}>
  <.header>
    Projects
  </.header>

  <.table id="projects" rows={@projects}>
    <:col :let={project} label="Name">{project.name}</:col>
    <:col :let={project} label="Status">{project.status}</:col>
  </.table>
</Layouts.app>
```
