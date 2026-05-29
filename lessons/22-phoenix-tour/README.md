# Lesson 22: Phoenix Tour

In lesson 21 you learned the plug contract by hand. Now you'll run `mix phx.new` and watch Phoenix assemble those same plugs into a full web application — the **Tracker** app you'll grow over the next four lessons. This lesson is mostly a guided tour: read the generated layout, find the supervision tree, start the dev server. The only code you write is a one-line route, so the moving parts have somewhere to land.

## What you should be able to do

After this lesson you should be able to:

- Run `mix phx.new` and explain what each top-level directory in the generated project is for.
- Point to the **supervision tree** in `application.ex` and name what it starts (PubSub, the Endpoint, …) — recognising it as the OTP application from Phase 2.
- Start the dev server with `mix phx.server`, list routes with `mix phx.routes`, and add a route that maps a path to a controller action.

## Key ideas

A Phoenix project is two halves with a clear seam between them:

- **`lib/tracker` — the domain.** Your business logic and data live here, with no knowledge that a web request ever happened. Right now it's nearly empty; lesson 25 fills it with *contexts*.
- **`lib/tracker_web` — the web layer.** Everything that knows about HTTP: the `Endpoint`, the `Router`, controllers, components, and `Telemetry`. The `_web` suffix is the convention that keeps web concerns out of your domain.

The pieces in the web layer are the plugs from lesson 21, grown up:

- **`Endpoint`** is the top plug — the single entry point the web server (Bandit) calls once per request. It runs a stack of plugs (parsing, sessions, static files) and finally hands off to the **`Router`**, which matches the path and dispatches to a controller action.
- **`Telemetry`** collects metrics about your app; you'll see it wired into the supervision tree.

**Phoenix is an OTP application** — exactly the shape you built in lesson 18 (`MiniCache`). Open `lib/tracker/application.ex` and you'll find a `start/2` callback starting a supervision tree:

```elixir
children = [
  TrackerWeb.Telemetry,
  {DNSCluster, query: ...},
  {Phoenix.PubSub, name: Tracker.PubSub},
  TrackerWeb.Endpoint
]
```

These are the supervised children that start when the app boots: a telemetry process, the PubSub system (for real-time messaging later), and the `Endpoint` that serves HTTP. It's the same `Supervisor.start_link(children, opts)` you wrote by hand — Phoenix is not magic, it's OTP.

A couple of generator conveniences worth knowing:

- **`mix phx.server`** boots the app and starts serving on `http://localhost:4000`. In development, Phoenix watches your files and **hot-reloads** code on the next request — no restart needed.
- **`mix phx.routes`** prints every route the router knows, the path → controller → action mapping. Run it whenever you're unsure what's wired up.

> 💡 **First time seeing this?** `mix phx.new tracker` generates a *lot* of files — controllers, components, an assets pipeline, an Ecto database layer, config for three environments. That's normal. You don't need to understand every file today; this lesson points you at the handful that matter and the rest will come into focus over the next lessons.

## The dormant Repo (important)

Phoenix generated a full database layer — `lib/tracker/repo.ex`, migrations, an SQL sandbox in the test setup. **We're not using it yet.** For lessons 22–25 the Tracker app holds all its data *in memory* (in contexts and processes, the way you learned in Phase 2), so there's no Postgres to install or run.

To keep the Repo dormant, this lesson makes three changes to the generated app:

- The `Tracker.Repo` line is removed from the supervision tree in `application.ex`, so the Repo never starts.
- The `test` alias in `mix.exs` no longer runs `ecto.create` / `ecto.migrate` — it's just `test: ["test"]`.
- The SQL sandbox is removed from the connection test setup (`ConnCase`) and `test/test_helper.exs`. (`test/support/data_case.ex` still carries sandbox code, left in place but dormant until lesson 26 turns the database on.)

The Repo *files* are left in place, dormant. **Lesson 26 switches the database on** when we add user accounts and need real persistence. Until then, the app boots and the tests run with no database at all.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=22-phoenix-tour` from the repo root to view).
3. Open `exercises/` and explore: read `lib/tracker_web/router.ex`, `lib/tracker/application.ex`, and `lib/tracker_web/controllers/page_controller.ex`.
4. Run `mix test --include pending`. One test fails: `GET /ping` should return `"pong"`. Implement the `ping/2` action in `PageController` to make it pass. (The route is already wired for you.)
5. Stuck? Read `HINTS.md` one hint at a time.
6. Compare against `solutions/` only after you have a working answer.

## Try it

From `exercises/` (or `solutions/`):

```
mix phx.server
```

Visit `http://localhost:4000` — the default Phoenix welcome page. Then visit `http://localhost:4000/ping`. In the solution it returns `pong`; in the exercise it errors until you implement the action. Run `mix phx.routes` to see both routes listed.

## Common mistakes

- **Expecting `/ping` to work before implementing the action.** The route is wired (`get "/ping", PageController, :ping`), but a route only *names* a controller action — you still have to write the `ping/2` function. A route to a missing action is an error.
- **Forgetting the route maps a path to a controller action.** `get "/ping", PageController, :ping` says "when a GET comes in for `/ping`, call `TrackerWeb.PageController.ping/2`." The path, the controller module, and the action name are three separate things that must line up.

## Links

- [Phoenix — up and running](https://hexdocs.pm/phoenix/up_and_running.html)
- [Phoenix — directory structure](https://hexdocs.pm/phoenix/directory_structure.html)
