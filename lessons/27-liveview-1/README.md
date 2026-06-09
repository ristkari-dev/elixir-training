# Lesson 27: LiveView (the live issue board)

By the end of this lesson, each project has a live **issue board** at `/projects/:id/board`: you add an issue and toggle its status, and the page updates instantly — no reload, no JavaScript you wrote. This is your first **LiveView**.

Issues are a new in-memory concept (a `Tracker.IssueStore` Agent, like `ProjectStore`). They stay in memory until lesson 29 — the same build-then-persist bridge you used for projects.

## What you should be able to do

After this lesson you should be able to:

- Explain what a LiveView is: a stateful process per connection that renders HTML on the server and pushes diffs over a websocket.
- Write the LiveView lifecycle: `mount/3` (set up assigns), `render/1` (HEEx from assigns), `handle_event/3` (respond to `phx-` events).
- Wire a LiveView behind authentication with `live_session` + an `on_mount` hook.

## Key ideas

**What LiveView is.** A LiveView is a process — think of it like a GenServer (lesson 15) that holds your page's state. The first request renders HTML over plain HTTP (the "dead" render); then the browser opens a websocket and the *same* LiveView keeps running on the server. After every event it re-renders from its assigns and pushes only the diff to the browser. You write Elixir; LiveView handles the wire.

**The lifecycle.** `mount(params, session, socket)` runs first — set up `socket.assigns`. `render(assigns)` returns HEEx built from those assigns. `handle_event(name, params, socket)` runs when the browser sends a `phx-` event (e.g. `phx-submit`, `phx-click`); it returns `{:noreply, assign(socket, ...)}`, and the page re-renders from the new assigns. The whole UI is a function of the assigns.

> 💡 **First time seeing this?** There's no controller, no separate template file, and no API. `render/1` lives in the same module as `mount`/`handle_event`, and the "request/response" is replaced by a long-lived process reacting to events.

**A new in-memory `Issue`.** `Tracker.IssueStore` is an Agent holding issue maps `%{id, project_id, title, status}`; `Tracker.Issues` is the context boundary (`list_issues/1`, `create_issue/2`, `toggle_issue/1`, `change_issue/1`), exactly the shape you built for projects in lesson 25. Issues belong to a project; the board only loads for a project you own.

**LiveView auth (provided).** Lesson 26 generated *controller-based* auth, so there was no `on_mount` hook. A LiveView's connected mount runs over the websocket and can't read `conn.assigns`, so we added a small `on_mount` to `TrackerWeb.UserAuth`: it reads the session's `user_token`, looks the user up, and assigns `current_scope` to the socket (redirecting to log in if there's no user). The board route lives inside `live_session :require_authenticated, on_mount: [{TrackerWeb.UserAuth, :require_authenticated}]`. Study it as "how a LiveView knows who's logged in" — it's provided, not a drill.

## The drills

The board (`mount`/`render`), the `IssueStore`, the `Issues` context, the route, and the auth are done for you. Implement the two `handle_event` callbacks in `lib/tracker_web/live/project_board_live.ex`:

1. **`"add_issue"`** — the form submits `%{"issue" => params}`. Create the issue with `Tracker.Issues.create_issue(socket.assigns.project.id, params)`; on `{:ok, _}` re-assign the board, on `{:error, changeset}` re-assign the form so errors show.
2. **`"toggle"`** — the toggle button sends `phx-value-id`, arriving as `%{"id" => id}` (a string). `Tracker.Issues.toggle_issue(String.to_integer(id))`, then re-assign `:issues`.

Run `mix test --include pending` (with Postgres up) to see the two failing LiveView tests; make them pass.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=27-liveview-1` from the repo root).
3. From the repo root, `docker compose up -d postgres` (the auth tests need the database).
4. Open `exercises/` and run `mix test --include pending` — see the two failing drill tests. Make them pass.
5. Stuck? Read `HINTS.md` one hint at a time.
6. Compare against `solutions/` only after you have a working answer.

## Common mistakes

- **Postgres isn't running.** The auth tests fail to connect — `docker compose up -d postgres` from the repo root first.
- **Returning the wrong shape from `handle_event`.** It must be `{:noreply, socket}` (LiveView's "no reply, here's the new state"), not the socket alone.
- **Reaching for `current_user`.** It's `socket.assigns.current_scope.user`.
- **Selecting "the only element" in a test.** The in-memory `IssueStore` is an app-started singleton — its state does *not* roll back between tests like the database does. Target a specific `#issue-<id>` element, never a bare `button`.

## Going further

- `mount/3` runs *twice* for the first page load — once for the dead HTTP render and once for the connected websocket mount. Add `IO.inspect(connected?(socket))` in `mount` and watch.
- The form re-renders with validation errors on a blank title. Where does that come from? (Hint: `change_issue/1` + the `{:error, changeset}` branch.)

## Links

- [Phoenix.LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
- [LiveView — bindings (`phx-click`, `phx-submit`)](https://hexdocs.pm/phoenix_live_view/bindings.html)
- [Phoenix.LiveViewTest](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
