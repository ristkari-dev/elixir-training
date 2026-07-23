# Lesson 28
## LiveView 2 — streams + PubSub

The issue board goes real-time across tabs.

---

## Streams

Stop holding the whole list. Send per-item DOM operations.

--

### render

```heex
<ul id="issues" phx-update="stream">
  <li :for={{dom_id, issue} <- @streams.issues} id={dom_id}>
    {issue.title} — {issue.status}
  </li>
</ul>
```

`mount`: `stream(socket, :issues, Issues.list_issues(id))`.
Update: `stream_insert(socket, :issues, issue)`. Dom id is `issues-<id>`.

---

## PubSub

Already running (`Tracker.PubSub`). One topic per board.

--

### subscribe → broadcast → receive

```elixir
# mount
if connected?(socket), do: Phoenix.PubSub.subscribe(Tracker.PubSub, "board:#{id}")

# on change
Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), "board:#{id}", {:issue, issue})

# handle_info
def handle_info({:issue, issue}, socket), do: {:noreply, stream_insert(socket, :issues, issue)}
```

---

## broadcast_from(self())

Update your own tab directly. Tell the *others* via the broadcast.

--

### not `broadcast`

`broadcast` sends to everyone including you → your own update is an async
self-message → lag + flaky tests + double-insert.

`broadcast_from(self())` excludes you → your tab instant, others notified, no
duplicate.

---

## The two-tab test

```elixir
{:ok, tab_a, _} = live(conn, ~p"/projects/#{id}/board")
{:ok, tab_b, _} = live(conn, ~p"/projects/#{id}/board")

tab_a |> form("form", issue: %{title: "Broadcast me"}) |> render_submit()

assert render(tab_b) =~ "Broadcast me"
```

Two live sessions, one topic. The proof it's real-time.

---

## Phase 3 done

Plug → controllers → HEEx → contexts → auth → LiveView → streams + PubSub.

--

### Next: Phase 4 — Ecto

Move issues and projects from memory into Postgres.

```
make slides-dev LESSON=29-schemas-and-migrations
```
