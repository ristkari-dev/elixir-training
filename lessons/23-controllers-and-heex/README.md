# Lesson 23: Controllers and HEEx

In lesson 22 you wired a route to a one-line action that returned plain text. Now you'll write a real **page**: a controller action that picks the data, hands it to a **HEEx template**, and renders HTML through the Tracker layout. You'll build the **Projects index** — a table of projects rendered from a hard-coded list, using the Phoenix 1.8 core components.

There's still no database. The projects are a literal list in the controller for now; a real in-memory store arrives in lesson 24, and Postgres in lesson 26. Today is about the render path: action → assigns → template → HTML.

## What you should be able to do

After this lesson you should be able to:

- Write a controller action `index(conn, params)` that selects data and calls `render(conn, :index, projects: ...)`, passing data into the template as **assigns**.
- Read and write a **HEEx template** — `index.html.heex` embedded by a `ProjectHTML` view module — using `{...}` to interpolate Elixir into markup.
- Use the Phoenix 1.8 **core components** — wrap the page in `<Layouts.app flash={@flash}>`, give it a `<.header>`, and render rows with `<.table>` and `<:col :let={...}>` — and link routes with the `~p"/projects"` **verified route**.

## Key ideas

A controller action is a plug-shaped function: `index(conn, _params)`. It does two things — decides *what* data the page needs, and hands that data to a template. The handoff is `render/3`:

```elixir
def index(conn, _params) do
  projects = [%{id: 1, name: "Apollo", status: "open"}, ...]
  render(conn, :index, projects: projects)
end
```

`render(conn, :index, projects: projects)` says "render the `:index` template, and make `projects` available inside it." Each keyword you pass becomes an **assign**, reachable in the template as `@projects`. `@flash` is an assign too — Phoenix puts it there for you.

**Where does the `:index` template live?** Phoenix looks it up in the controller's matching HTML view module. `TrackerWeb.ProjectController` pairs with `TrackerWeb.ProjectHTML`:

```elixir
defmodule TrackerWeb.ProjectHTML do
  use TrackerWeb, :html
  embed_templates "project_html/*"
end
```

`embed_templates "project_html/*"` compiles every `.html.heex` file in `controllers/project_html/` into a function on this module. So `:index` resolves to `index.html.heex`.

**HEEx** is HTML with Elixir holes. You write markup, and `{...}` drops a value in:

```heex
<:col :let={project} label="Name">{project.name}</:col>
```

(`{...}` interpolates a value into an attribute or a tag body — it's the everyday tool. There's also `<%= ... %>` for blocks, but you rarely need it with the core components.)

**The core components** ship in `lib/tracker_web/components/core_components.ex` — the same ones the generated app uses. This lesson uses three:

- `<Layouts.app flash={@flash}>...</Layouts.app>` wraps your content in the app shell (navbar, flash messages, the centered `<main>`). Every full HTML page wraps in it.
- `<.header>Projects</.header>` renders a page title (with an optional `<:actions>` slot for buttons).
- `<.table id="projects" rows={@projects}>` renders a table; each `<:col :let={project} label="...">` declares a column. The `:let={project}` binds the current row so the column body can read `{project.name}`.

**Verified routes** — `~p"/projects"` — are how you write paths. The `~p` sigil checks at compile time that the path actually exists in your router, so a typo'd link fails the build instead of 404ing at runtime. The route itself is declared once: `resources "/projects", ProjectController, only: [:index]` generates the `GET /projects` → `:index` mapping (run `mix phx.routes` to see it).

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=23-controllers-and-heex` from the repo root to view).
3. Open `exercises/` and read `lib/tracker_web/controllers/project_controller.ex` (a stub that raises), `project_html.ex`, and `project_html/index.html.heex` (the template is written for you).
4. Run `mix test --include pending`. One test fails: `GET /projects` should list the projects. Implement `index/2` so it assigns a hard-coded `projects` list and renders `:index`.
5. Stuck? Read `HINTS.md` one hint at a time.
6. Compare against `solutions/` only after you have a working answer.

## Try it

From `exercises/` (or `solutions/`):

```
mix phx.server
```

Visit `http://localhost:4000/projects`. In the solution you'll see a two-row table (Apollo, Gemini); in the exercise it errors until you implement the action. Run `mix phx.routes` and find the `GET /projects` line.

## Common mistakes

- **Forgetting `:let` on a `<:col>`.** `<:col label="Name">{project.name}</:col>` won't compile — `project` isn't in scope. The `:let={project}` is what binds the current row for that column's body. Every `<:col>` that reads the row needs its own `:let`.
- **Linking a path that isn't in the router.** `~p"/projects"` only works because `resources "/projects", ProjectController, only: [:index]` is declared. Reference a path the router doesn't know and the `~p` sigil fails at compile time — by design. Add the route first (and check with `mix phx.routes`).
- **Mismatching the assign name.** `render(conn, :index, projects: ...)` makes `@projects`; if the template says `@project` (or you forget to pass it), you get a missing-assign error. The keyword in `render/3` and the `@name` in the template must match.

## Links

- [Phoenix — Controllers](https://hexdocs.pm/phoenix/controllers.html)
- [Phoenix — Components and HEEx](https://hexdocs.pm/phoenix/components.html)
- [Phoenix.Component — function components, slots, `:let`](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html)
- [Verified routes (`~p`)](https://hexdocs.pm/phoenix/Phoenix.VerifiedRoutes.html)
