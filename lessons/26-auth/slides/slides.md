# Lesson 26
## Auth — the database, switched on

Real users in Postgres, generated auth, and per-user projects.

---

## The database, switched on

Lesson 22 generated a database layer and kept it *dormant*. Now it's live.

--

### Three switches

- `Tracker.Repo` joins the supervision tree.
- The `test` alias is back to
  `["ecto.create --quiet", "ecto.migrate --quiet", "test"]`.
- `ConnCase`/`DataCase` check out the **SQL sandbox**.

```
docker compose up -d postgres   # from the repo root
mix ecto.setup                  # create + migrate
```

--

### The SQL sandbox

Every test runs inside a transaction that is **rolled back** at the end.
Tests never see each other's rows. Fast and isolated.

---

## phx.gen.auth (controller-based)

```
mix phx.gen.auth Accounts User users
# "LiveView based authentication system?"  -> n
```

--

### What it builds

- `Accounts` context + `User` / `UserToken` / `UserNotifier`
- a `users` migration
- `TrackerWeb.UserAuth` — the auth plugs
- session / registration / settings **controllers** (not LiveView — that's
  lesson 27)

You study it; you don't hand-write it. Generators are first-class in Phoenix.

---

## Scopes: current_scope.user

```elixir
pipeline :browser do
  # ...
  plug :fetch_current_scope_for_user
end
```

--

### The logged-in user

`conn.assigns.current_scope` holds a `Tracker.Accounts.Scope` (or `nil`).
The user is `current_scope.user` — **not** a bare `current_user`.

Contexts take a `scope` so they can enforce ownership:

```elixir
def list_projects(scope), do: ProjectStore.list(scope.user.id)
```

---

## The drills

--

### 1. Protect the route

```elixir
scope "/", TrackerWeb do
  pipe_through [:browser, :require_authenticated_user]

  resources "/projects", ProjectController, only: [...]
end
```

Logged out → redirected to `~p"/users/log-in"`.

--

### 2. Scope the store

`ProjectStore.list/1` filters by `user_id`; `add/2` records `:user_id`.
Each user sees only their own projects.

Users persist in Postgres; projects stay in memory until **lesson 29**.

---

## Next: lesson 27 — LiveView

Server-rendered interactivity: `mount`, `render`, `handle_event`.

```
make slides-dev LESSON=27-liveview-1
```
