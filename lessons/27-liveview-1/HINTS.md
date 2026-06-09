# Hints for Lesson 27: LiveView

Read one hint at a time. Try the exercise again before reading the next.
Make sure Postgres is running first (`docker compose up -d postgres` from the
repo root — the auth tests need it). Two drills, both in
`lib/tracker_web/live/project_board_live.ex`.

## Drill 1: `handle_event("add_issue", ...)`

### Hint 1

The add form is `<.form for={@form} phx-submit="add_issue">`, so submitting it
sends an `"add_issue"` event with `%{"issue" => params}`. Create the issue
through the context: `Tracker.Issues.create_issue(socket.assigns.project.id, params)`.

### Hint 2

`create_issue/2` returns `{:ok, issue}` or `{:error, changeset}`. On success,
re-assign the whole board (there's a private `assign_board/2` helper that sets
`:issues` and a fresh `:form`). On error, re-assign just the form so the
validation errors render: `to_form(changeset, as: :issue)`.

### Hint 3

```elixir
def handle_event("add_issue", %{"issue" => params}, socket) do
  case Issues.create_issue(socket.assigns.project.id, params) do
    {:ok, _issue} ->
      {:noreply, assign_board(socket, socket.assigns.project)}

    {:error, changeset} ->
      {:noreply, assign(socket, :form, to_form(changeset, as: :issue))}
  end
end
```

## Drill 2: `handle_event("toggle", ...)`

### Hint 1

The toggle button is `<button phx-click="toggle" phx-value-id={issue.id}>`, so
clicking it sends a `"toggle"` event with `%{"id" => id}`. The `id` arrives as
a **string** — parse it with `String.to_integer/1`.

### Hint 2

Toggle through the context (`Tracker.Issues.toggle_issue/1`), then re-assign
`:issues` so the list re-renders with the new status:
`assign(socket, :issues, Issues.list_issues(socket.assigns.project.id))`.

### Hint 3

```elixir
def handle_event("toggle", %{"id" => id}, socket) do
  Issues.toggle_issue(String.to_integer(id))
  {:noreply, assign(socket, :issues, Issues.list_issues(socket.assigns.project.id))}
end
```
