# Hints for Lesson 28: LiveView 2

Read one hint at a time. Try the exercise again before reading the next.
Make sure Postgres is running first (`docker compose up -d postgres` from the
repo root). Two drills, both in `lib/tracker_web/live/project_board_live.ex`.

## Drill 1: broadcast + local insert in `add_issue`/`toggle`

### Hint 1

After the data change succeeds, do two things: tell the *other* tabs with
`Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic(socket.assigns.project.id), {:issue, issue})`,
and update *your own* tab with `stream_insert(socket, :issues, issue)`.

### Hint 2

`add_issue`'s `{:ok, issue}` branch: broadcast, `stream_insert`, and reset the
form. `broadcast_from(self())` skips your own process, so you won't get a
duplicate.

### Hint 3

```elixir
def handle_event("add_issue", %{"issue" => params}, socket) do
  case Issues.create_issue(socket.assigns.project.id, params) do
    {:ok, issue} ->
      Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic(socket.assigns.project.id), {:issue, issue})

      {:noreply,
       socket
       |> stream_insert(:issues, issue)
       |> assign(:form, to_form(Issues.change_issue(), as: :issue))}

    {:error, changeset} ->
      {:noreply, assign(socket, :form, to_form(changeset, as: :issue))}
  end
end

def handle_event("toggle", %{"id" => id}, socket) do
  issue = Issues.toggle_issue(String.to_integer(id))
  Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic(socket.assigns.project.id), {:issue, issue})
  {:noreply, stream_insert(socket, :issues, issue)}
end
```

## Drill 2: `handle_info`

### Hint 1

The broadcast from another tab arrives as `{:issue, issue}`. Insert it into the
stream so this tab updates.

### Hint 2

`stream_insert(socket, :issues, issue)` inserts-or-updates by dom id, so it
handles both new issues and status changes.

### Hint 3

```elixir
def handle_info({:issue, issue}, socket) do
  {:noreply, stream_insert(socket, :issues, issue)}
end
```
