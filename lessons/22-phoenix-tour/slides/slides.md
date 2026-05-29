# Lesson 22
## Phoenix Tour

You learned the plug contract by hand. Now `mix phx.new` assembles those
plugs into a real app — the **Tracker** you'll grow over lessons 22–25.

---

## mix phx.new

```
$ mix phx.new tracker
```

Generates a full web app: controllers, components, an assets pipeline,
config for dev/test/prod, and a complete database layer.

--

### That's a lot of files

```
lib/  config/  test/  assets/  priv/
```

You don't need to understand every file today. This tour points at the
handful that matter; the rest come into focus over the next lessons.

---

## Domain vs web

Two halves, one clear seam.

--

### lib/tracker — the domain

Business logic and data. Knows nothing about HTTP. Nearly empty now;
lesson 25 fills it with **contexts**.

### lib/tracker_web — the web layer

Everything that speaks HTTP: `Endpoint`, `Router`, controllers,
components, `Telemetry`. The `_web` suffix keeps web concerns out of
your domain.

---

## The supervision tree

Phoenix is an **OTP application** — the same shape as `MiniCache`
(lesson 18).

--

### application.ex starts a tree

```elixir
children = [
  TrackerWeb.Telemetry,
  {DNSCluster, query: ...},
  {Phoenix.PubSub, name: Tracker.PubSub},
  TrackerWeb.Endpoint
]
Supervisor.start_link(children, opts)
```

Telemetry, PubSub, the Endpoint — supervised children that start on boot.
The same `Supervisor.start_link` you wrote by hand. Not magic: OTP.

--

### Endpoint → Router → controller

The `Endpoint` is the top plug — Bandit calls it once per request. It runs
a plug stack, then hands off to the `Router`, which matches the path and
dispatches to a controller action.

```
$ mix phx.server   # boots on :4000, hot-reloads on save
$ mix phx.routes   # lists every path → controller → action
```

---

## Router → controller → action

The one line you write this lesson.

--

### A route names an action

```elixir
scope "/", TrackerWeb do
  pipe_through :browser

  get "/", PageController, :home
  get "/ping", PageController, :ping
end
```

`get "/ping", PageController, :ping` = "GET `/ping` → call
`PageController.ping/2`." The route is wired; you write the action.

--

### The drill

```elixir
def ping(conn, _params), do: text(conn, "pong")
```

`text/2` sends a plain-text `200`. Visit `/ping` → `pong`.

--

### The dormant Repo

Phoenix generated a full database layer. **We're not using it yet** —
contexts hold data in memory. So the `Repo` is removed from the
supervision tree and the `test` alias no longer creates a database.

Lesson 26 switches it on when we add accounts and Postgres.

---

## Next: lesson 23 — controllers & HEEx

You wired a route to an action. Next: controllers that render real HTML
with HEEx templates.

```
make slides-dev LESSON=23-controllers-and-heex
```
