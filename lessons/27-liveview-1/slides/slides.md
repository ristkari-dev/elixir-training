# Lesson 27
## LiveView — the live issue board

Add and toggle issues live, in one tab, no page reload.

---

## What LiveView is

A stateful process per connection that renders HTML on the server.

--

### Dead render → websocket → diffs

```
GET /board     →  full HTML  (the "dead" render)
                  ↓
browser opens a websocket
                  ↓
same LiveView keeps running on the server
                  ↓
event → re-render → push only the diff
```

A LiveView is a process — like a GenServer that holds your page's state.

---

## The lifecycle

```elixir
def mount(params, session, socket)        # set up assigns
def render(assigns)                        # HEEx from assigns
def handle_event(name, params, socket)     # react to phx- events
```

--

### The UI is a function of the assigns

```elixir
def handle_event("toggle", %{"id" => id}, socket) do
  Issues.toggle_issue(String.to_integer(id))
  {:noreply, assign(socket, :issues, Issues.list_issues(...))}
end
```

Change the assigns, return `{:noreply, socket}` → LiveView re-renders and pushes
the diff. No controller, no API, no JS you wrote.

---

## In-memory issues

```elixir
Tracker.IssueStore   # an Agent, like ProjectStore
Tracker.Issues       # the context boundary
```

`%{id, project_id, title, status}`. Issues belong to a project; they stay in
memory until **lesson 29**.

---

## The events

```heex
<.form for={@form} phx-submit="add_issue"> ... </.form>

<button phx-click="toggle" phx-value-id={issue.id}>Toggle</button>
```

--

### Bindings → events

- `phx-submit="add_issue"` → `handle_event("add_issue", %{"issue" => params}, socket)`
- `phx-click="toggle"` + `phx-value-id` → `handle_event("toggle", %{"id" => id}, socket)`

`id` arrives as a **string** — `String.to_integer/1` it.

---

## LiveView auth

The websocket mount can't read `conn.assigns`. So:

```elixir
# router
live_session :require_authenticated,
  on_mount: [{TrackerWeb.UserAuth, :require_authenticated}] do
  live "/projects/:id/board", ProjectBoardLive
end
```

--

### on_mount fills the socket

`on_mount` reads the session's `user_token`, looks up the user, and assigns
`current_scope` to the **socket** (redirecting to log in if absent). Provided
for you — lesson 26 chose controller-based auth, which generated no hook.

---

## Next: lesson 28 — streams & PubSub

Efficient lists with streams; multi-tab live updates by broadcasting.

```
make slides-dev LESSON=28-liveview-2
```
