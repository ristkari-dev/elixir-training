# Lesson 28 `liveview-2` — Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-06-09
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Parent design:** [Elixir course design](2026-05-21-elixir-course-design.md)
**Predecessor:** [Lesson 27 liveview-1 design](2026-06-07-phase-3b-ii-liveview-1-design.md)

## Purpose

Lesson 28 adds two real-time primitives to the issue board built in lesson 27:
**LiveView streams** (efficient list rendering) and **Phoenix.PubSub** (live
updates across browser tabs). After this lesson, adding or toggling an issue in
one tab updates every other tab viewing the same project's board, live, with no
reload. This is the final lesson of Phase 3.

## Scope

**In scope:** lesson 28 only (`28-liveview-2`).

**Out of scope (later, separate specs):**
- Live comments and a `Comment` domain — deferred to Phase 4 lesson 32
  (`associations`, "Issue ↔ Comment"), where comments are built properly in
  Postgres rather than as a throwaway in-memory store.
- `LiveComponent`s (mentioned in the master design's lesson-28 line, dropped
  here as unnecessary surface for this audience — function components already
  cover composition).
- Presence / typing indicators / who's-online.
- Migrating issues to Postgres (lesson 29).

By the end of lesson 28, the project board:
- renders its issue list as a LiveView stream,
- broadcasts issue changes over PubSub, and
- updates live in every tab subscribed to that project's board.

## Decision locked during brainstorming

**Comments out of scope.** Lesson 28 focuses on the two genuinely new
primitives (streams, PubSub). A `Comment` domain would be an in-memory throwaway
that Phase 4 lesson 32 rebuilds in Postgres; deferring it keeps lesson 28 tight
and avoids duplicated work. (Diverges from the master design's "live comments"
line for 28, by design.)

## Conventions & mechanics

### Versions

- Pinned toolchain (repo `.tool-versions`): Elixir 1.19.5-otp-28 / Erlang
  29.0.1. Phoenix `~> 1.8` (1.8.7), `phoenix_live_view ~> 1.1`. **No new Hex
  dependencies** — `Phoenix.PubSub` (named `Tracker.PubSub`) is already in the
  supervision tree from `phx.new`, and the `/live` socket is wired.
- `mix.lock` committed for both `exercises/` and `solutions/`.

### Threading from lesson 27

- `28-liveview-2/exercises/` and `solutions/` are full committed copies of
  lesson 27's `solutions/` plus this lesson's changes.
- Lesson 27's tests are replaced/extended by lesson 28's (the board's
  add/toggle behavior is rewired through streams + PubSub, so the
  `ProjectBoardLive` test changes). Generated auth and the projects/issues
  context tests remain green.
- The exercise is derived from the finished solution by stubbing the drill
  holes and tagging the drill tests `@tag :pending`, keeping the two dirs
  identical except for those.
- Module prefixes stay `Tracker` / `TrackerWeb`. The Postgres service from
  lesson 26 remains required (auth tests are DB-backed).

### Streams

The lesson-27 board renders the issue list with `assign(:issues, ...)` and
`:for={issue <- @issues}`. Lesson 28 converts it to a **stream**:

- `mount` calls `stream(socket, :issues, Issues.list_issues(project.id))`
  instead of `assign(:issues, ...)`.
- `render` iterates the stream:
  ```heex
  <ul id="issues" phx-update="stream">
    <li :for={{dom_id, issue} <- @streams.issues} id={dom_id}>
      <span class="title">{issue.title}</span>
      <span class="status">{issue.status}</span>
      <button phx-click="toggle" phx-value-id={issue.id}>Toggle</button>
    </li>
  </ul>
  ```
  The container needs a DOM `id` and `phx-update="stream"`; each row's `id` is
  the stream-provided `dom_id` (e.g. `issues-3`).
- Updates use `stream_insert(socket, :issues, issue)` — insert-or-update by DOM
  id — rather than re-assigning the whole list. README explains *why*: the
  server stops holding and re-diffing the full collection; it sends per-item
  operations, so a large board stays cheap.

### PubSub multi-tab updates

- A per-project topic: `"board:#{project_id}"`.
- `mount` subscribes when connected:
  ```elixir
  if connected?(socket), do: Phoenix.PubSub.subscribe(Tracker.PubSub, "board:#{project.id}")
  ```
  (Subscribing only on the connected mount avoids subscribing twice / on the
  dead render.)
- On add and toggle, the LiveView updates its **own** stream directly and
  broadcasts to the **other** tabs with `broadcast_from(self())` (which excludes
  the caller):
  ```elixir
  Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), "board:#{project_id}", {:issue, issue})
  # ... and locally:
  stream_insert(socket, :issues, issue)
  ```
- A `handle_info({:issue, issue}, socket)` clause applies broadcasts from other
  tabs to the stream:
  ```elixir
  def handle_info({:issue, issue}, socket) do
    {:noreply, stream_insert(socket, :issues, issue)}
  end
  ```
- **Two-path, not single-path.** The caller updates its own tab synchronously
  (local `stream_insert`) and tells the others via `broadcast_from(self())`.
  A single-path "broadcast to everyone including self, only `handle_info`
  updates" makes the caller's own update an async self-message — a beat of UI
  lag and, more importantly, flaky tests (the assertion races the self-broadcast).
  `broadcast_from(self())` excludes the caller, so there's no double-insert.

### The drill (hand-written, `@tag :pending`)

Provided (working): `mount` (subscribe + stream), `render` (the
`phx-update="stream"` markup), the `Issues` context, `IssueStore`, the route,
and the LiveView auth — all carried/adapted from lesson 27.

The **drill is the real-time wiring** — three holes the learner fills, all in
`lib/tracker_web/live/project_board_live.ex`:

1. `handle_event("add_issue", ...)` — after `Issues.create_issue/2` succeeds,
   `broadcast_from(self())` `{:issue, issue}` to the topic AND `stream_insert`
   it locally (and re-set the form).
2. `handle_event("toggle", ...)` — `Issues.toggle_issue/1`, then
   `broadcast_from(self())` `{:issue, updated_issue}` AND `stream_insert` it
   locally.
3. `handle_info({:issue, issue}, socket)` — `stream_insert(socket, :issues, issue)`.

Exercise stubs (typed-placeholder, compile-clean under
`--warnings-as-errors`, per the Phoenix-era stub convention):
- `handle_event` clauses perform the data change (create/toggle) and reset the
  form but do NOT broadcast or `stream_insert` — each with a `# TODO:` comment —
  so nothing appears on any tab. (The broadcast is inlined, not a private
  helper, so there is no unused-function warning when the drill is stubbed.)
- `handle_info({:issue, _issue}, socket)` returns `{:noreply, socket}` with a
  `# TODO:` (so it compiles, since `mount` subscribes and messages will
  arrive), updating nothing.

Because the data is still written, the `Issues`/`IssueStore` and projects tests
stay green; only the board's live behavior is broken until the learner wires
the broadcast + `handle_info`.

### Testing

`Phoenix.LiveViewTest`, DB-backed via the generated `TrackerWeb.ConnCase` (SQL
sandbox) with `register_and_log_in_user`, `async: false` (the in-memory
`IssueStore`/`ProjectStore` singletons don't roll back). Tests in
`test/tracker_web/live/project_board_live_test.exs`:

- **auth (not pending):** unauthenticated `live(...)` redirects to
  `~p"/users/log-in"`.
- **not-yours (not pending):** the owner check redirects to `~p"/projects"`.
- **add (`@tag :pending`):** mount the board, `render_submit` the add form with
  a title, assert the new title appears (the caller's own tab updates via its
  local `stream_insert`).
- **toggle (`@tag :pending`):** with an issue present, `render_click` that
  issue's toggle, assert its status flips (target `#issues-<id> .status`).
- **multi-tab (`@tag :pending`) — the headline:** mount the same project's board
  in two `live/2` sessions (both as the owner); `render_submit` an add in the
  first; assert the new title appears in the **second** view's rendered HTML
  (cross-tab PubSub). This proves the broadcast path.

**Isolation:** target a specific `#issues-<id>` element, never a bare selector;
each test makes a fresh user + project so issue ids/contents never collide.

**Synchronizing across tabs:** the caller's own tab updates synchronously (local
`stream_insert` in the event handler), so `render(view)` after `render_submit` /
`has_element?` after `render_click` reflect it immediately. The **cross-tab**
update arrives at the other tab as a `handle_info` message; the multi-tab test
asserts with `render(tab_b)` *after* the action, and that synchronous round-trip
flushes tab B's mailbox (local PubSub dispatch has already queued the message by
the time the action returns). Verified against a live two-tab socket at plan
time.

### Drill model & test conventions

- `test/test_helper.exs`: exercises `ExUnit.start(exclude: [pending: true])`
  then the `Sandbox.mode` line; solutions plain `ExUnit.start()` then the same.
- Solutions pass `mix test --include pending` with zero failures and zero
  warnings, against Postgres. Exercises pass `mix test` (pending excluded),
  compile warning-free, and the three drill tests fail until implemented.
- Exercise derived from the finished solution by reverting the two
  `handle_event` clauses to non-broadcasting stubs, the `handle_info` to a
  no-op stub, and tagging the three drill tests pending.

## CI / tooling impact

- No new dependencies; the Postgres service from lesson 26 covers the DB.
  `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are unchanged in shape.
- LiveView/stream code is `mix format`-clean (run `mix format` after
  authoring). Credo and ExCoveralls remain deferred to lesson 34.
- `tools/build_index` and the Cloud Run deploy are unchanged; lesson 28
  contributes its `slides/`.

## Risks

1. **Testing cross-tab PubSub in `LiveViewTest`.** Two `live/2` sessions in one
   test, one broadcasts, the other must receive via `handle_info` and update.
   Mitigation: prototype the full lesson against a real socket + two live
   sessions at plan time (the prototype-first discipline used for lessons
   26–27), confirming the second view re-renders.
2. **Streams + the in-memory store.** Mitigation: target `#issues-<id>`,
   `async: false`, fresh per-test user+project — proven in lesson 27.
3. **Broadcasting from the LiveView vs. the context.** This lesson broadcasts
   from the LiveView's `handle_event` (visible, all in one module) rather than
   from the `Issues` context, to keep the subscribe/broadcast/receive path
   together for teaching. (Real apps often broadcast from the context; noted in
   "going further".)

## Success criteria

- Lesson `28-liveview-2` exists with README, HINTS, slides, exercises,
  solutions.
- Every `solutions/` project (incl. lesson 28) passes `mix test --include
  pending` with zero failures and zero warnings, against Postgres.
- Lesson 28's `exercises/` compiles (no warnings under `--warnings-as-errors`)
  and its non-pending tests pass; the three drill tests fail until implemented.
- `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are green in CI with the Postgres service.
- The board renders issues as a stream; adding/toggling an issue in one tab
  updates a second tab viewing the same board, live.
- After merge, the slide site publishes lesson 28. Phase 3 is complete.
