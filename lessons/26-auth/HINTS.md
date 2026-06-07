# Hints for Lesson 26: Auth

Read one hint at a time. Try the exercise again before reading the next.
Make sure Postgres is running first (`docker compose up -d postgres` from the
repo root). Two drills: protect the route, then scope the store.

## Drill 1: Protect the `/projects` routes

### Hint 1

The generated router already has a scope that requires a logged-in user — look
for `pipe_through [:browser, :require_authenticated_user]` (it wraps
`/users/settings`). The `/projects` resources need to live in a scope like that
instead of the public `pipe_through :browser` one.

### Hint 2

Move the `resources "/projects", ...` line out of the public scope and into a
new authenticated scope:

```elixir
scope "/", TrackerWeb do
  pipe_through [:browser, :require_authenticated_user]

  resources "/projects", ProjectController, only: [:index, :show, :new, :create]
end
```

### Hint 3

Delete the `resources "/projects"` line from the `pipe_through :browser` scope
(leaving just `/` and `/ping` there), and add the authenticated scope above.
`require_authenticated_user` redirects logged-out visitors to `~p"/users/log-in"`.

## Drill 2: Scope the store to the owner

### Hint 1

`Tracker.ProjectStore.list/1` and `add/2` receive a `user_id` but ignore it.
`list/1` should return only the projects owned by that user; `add/2` should
record the owner on the project it stores. (The `Projects` context already calls
these with `scope.user.id`.)

### Hint 2

`list/1` filters the items; `add/2` puts `:user_id` on the map before storing:

```elixir
def list(user_id) do
  __MODULE__ |> Agent.get(& &1.items) |> Enum.filter(&(&1.user_id == user_id)) |> Enum.reverse()
end
```

### Hint 3

And the full `add/2` — record `:user_id` alongside `:id`:

```elixir
def add(user_id, attrs) do
  Agent.get_and_update(__MODULE__, fn %{items: items, next_id: id} ->
    project = attrs |> Map.put(:id, id) |> Map.put(:user_id, user_id)
    {project, %{items: [project | items], next_id: id + 1}}
  end)
end
```
