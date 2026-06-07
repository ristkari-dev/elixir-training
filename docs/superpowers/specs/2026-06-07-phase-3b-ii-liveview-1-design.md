# Phase 3b-ii — Lesson 27 `liveview-1` — Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-06-07
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Parent design:** [Elixir course design](2026-05-21-elixir-course-design.md)
**Predecessor:** [Phase 3b-i design](2026-06-02-phase-3b-i-auth-design.md)

## Purpose

Lesson 27 introduces **LiveView** — a stateful process per connection that
renders HTML on the server and pushes diffs over a websocket. It does so by
building a **live issue board** for a project: the page lists a project's
issues, lets you add an issue, and lets you toggle an issue's status, all
updating live in one browser tab with no page reload. Issues are a new
in-memory concept that migrates to Postgres in lesson 29. This is the
learner's first `mount` / `render` / `handle_event`.

## Scope

**In scope (this cycle):** lesson 27 only (`27-liveview-1`).

**Out of scope (later cycles, separate specs):**
- Streams, PubSub, multi-tab live updates, broadcasting, and live comments
  (lesson 28).
- Migrating issues (and projects) from in-memory to Postgres (lesson 29).
- `LiveComponent`s and `phx.gen.live` (the generator assumes an Ecto schema; we
  hand-write LiveView over the in-memory store).
- Associations, queries, `Ecto.Multi` (Phase 4).

By the end of lesson 27, Tracker has:
- a new in-memory `Issue` concept (issues belong to a project),
- a live board at `/projects/:id/board` that lists, adds, and toggles issues
  live in a single tab,
- LiveView routes protected so only the project's owner can view its board.

## Decisions locked during brainstorming

1. **Scope = lesson 27 only.** Lesson 27 (the LiveView paradigm + a single-tab
   live board) and lesson 28 (streams, PubSub, multi-tab, comments) are each
   dense; isolating 27 keeps the lesson-at-a-time rhythm and gives the new
   paradigm focused review.
2. **Board domain = issues within a project.** Introduce a minimal in-memory
   `Issue` concept (a new `IssueStore` Agent + `Issues` context), faithful to
   the master design's "project board: issues update live" and the
   issue-tracker premise. Issues migrate to Postgres in lesson 29 — the
   course's intended build-then-persist pattern.
3. **A new live route for the board** (`live "/projects/:id/board"`), linked
   from the existing project show page — additive, leaving the lesson-23–26
   controller pages intact. The board is not a conversion of the project show
   controller action.

## Conventions & mechanics

### Versions

- Pinned toolchain (repo `.tool-versions`): Elixir 1.19.5-otp-28 / Erlang
  29.0.1. Phoenix `~> 1.8` (1.8.7), `phoenix_live_view ~> 1.1`. No new Hex
  dependencies — LiveView and the `/live` socket are already in the generated
  app (the `:phoenix_live_view` compiler, the `socket "/live"` endpoint entry,
  and the dep are all present from lesson 22's `phx.new`).
- `mix.lock` committed for both `exercises/` and `solutions/`.

### Threading from lesson 26

- `27-liveview-1/exercises/` and `solutions/` are full committed copies of
  lesson 26's `solutions/` plus this lesson's additions.
- Lesson 26's carried tests stay green baseline. This lesson's drill tests are
  `@tag :pending`. Generated auth and the lesson-26 project tests remain green.
- Generate-once-derive-exercise is not needed here (no generator run) — but the
  exercise is still derived from the finished solution by reverting the drill
  holes, keeping the two dirs identical except for the stubs and pending tags.
- Module prefixes stay `Tracker` / `TrackerWeb`. The Postgres service from
  lesson 26 remains required (auth tests are DB-backed).

### New domain: in-memory issues

- **`Tracker.IssueStore`** — an `Agent`, mirroring `Tracker.ProjectStore`.
  State: `%{items: [], next_id: 1}` where each item is
  `%{id: integer, project_id: integer, title: String.t(), status: String.t()}`
  and `status` is `"open"` or `"closed"`. API:
  - `list(project_id)` — that project's issues, insertion order.
  - `add(project_id, attrs)` — store a new issue (status defaults to `"open"`),
    assign an `id`, return the issue.
  - `toggle(id)` — flip the issue's `status` between `"open"` and `"closed"`,
    return the updated issue.
  - `get(id)` — find by id (or `nil`).
  - Started in the supervision tree (`lib/tracker/application.ex`), like
    `ProjectStore`.
- **`Tracker.Issues`** context — the boundary (per lesson 25's pattern):
  - `list_issues(project_id)` → `IssueStore.list(project_id)`.
  - `create_issue(project_id, attrs)` — validate via a schemaless changeset
    (title required), on valid `IssueStore.add(project_id, applied_attrs)`
    returning `{:ok, issue}` | `{:error, changeset}`.
  - `toggle_issue(id)` → `IssueStore.toggle(id)`.
  - `change_issue(attrs \\ %{})` — the schemaless changeset for the form.

### The LiveView

- **`TrackerWeb.ProjectBoardLive`** (`lib/tracker_web/live/project_board_live.ex`).
- Route: `live "/projects/:id/board", ProjectBoardLive` inside an
  authenticated `live_session` (see auth below). Linked from
  `project_html/show.html.heex` (a "Board" link/button).
- `mount(%{"id" => id}, _session, socket)`:
  - load the project via `Tracker.Projects.get_project!/1` (parsing the id),
  - verify the current user owns it (the project's `:user_id` equals
    `socket.assigns.current_scope.user.id`); if not, `put_flash` + redirect to
    `~p"/projects"` and return without assigning the board,
  - assign `:project`, `:issues` (`Issues.list_issues(project.id)`), and a
    `:form` from `Issues.change_issue/0` via `to_form`.
- `render/1` — a HEEx board: the project name (`<.header>`), the issue list
  (each issue: title, status, a toggle button `phx-click="toggle"
  phx-value-id={issue.id}`), and an add-issue form (`<.form for={@form}
  phx-submit="add_issue">` with a title input + submit).
- `handle_event("add_issue", %{"issue" => params}, socket)`:
  `Issues.create_issue(project_id, params)`; on `{:ok, _}` re-assign the issue
  list and reset the form; on `{:error, changeset}` re-assign the form with
  errors.
- `handle_event("toggle", %{"id" => id}, socket)`: `Issues.toggle_issue` (parse
  id), re-assign the issue list.

### LiveView authentication (provided, not a drill)

Lesson 26 generated **controller-based** auth, so `TrackerWeb.UserAuth` has no
`on_mount` hook — only conn plugs. A LiveView's connected mount (over the
websocket) does not inherit `conn.assigns`, so lesson 27 adds the LiveView auth
hook itself, mirroring what LiveView-based `phx.gen.auth` generates:

- Add to `TrackerWeb.UserAuth`:
  - `on_mount(:require_authenticated, _params, session, socket)` — assign
    `current_scope` to the socket from the session's `user_token` (via
    `assign_new` + `Accounts.get_user_by_session_token/1` + `Scope.for_user/1`);
    if there's no user, `put_flash` + `redirect(to: ~p"/users/log-in")` and
    return `{:halt, socket}`, else `{:cont, socket}`.
  - a private helper to do the session→scope assignment.
- Wrap the board route in
  `live_session :require_authenticated, on_mount: [{TrackerWeb.UserAuth, :require_authenticated}] do ... end`.
- The live route's initial (dead) HTTP render also passes through the
  `:browser` pipeline; placing the `live_session` scope under
  `pipe_through [:browser]` (the `fetch_current_scope_for_user` plug runs there)
  plus the `on_mount` covers both the dead and connected renders.

This is **provided code** and is explained in the README/slides — it is the
"how does a LiveView know who is logged in" moment — but it is not a drill the
learner fills in.

### The drill (hand-written, `@tag :pending`)

Same "provided app + stubbed holes" model. Provided: the `ProjectBoardLive`
skeleton (`mount` + `render`), `IssueStore`, the `Issues` context, the
`on_mount` auth, the route, and the show-page link. The **two `handle_event`
callbacks are the holes** — the heart of server-rendered interactivity:

- `handle_event("add_issue", ...)` — exercise stub is a typed-placeholder that
  returns `{:noreply, socket}` without creating the issue (a `# TODO:` comment),
  so the board never gains the issue; the drill test fails until implemented.
- `handle_event("toggle", ...)` — exercise stub returns `{:noreply, socket}`
  without toggling; the drill test fails until implemented.

Exercise stubs must compile with zero warnings under
`mix compile --warnings-as-errors`; typed-placeholder stubs (not bare `raise`)
per the established Phoenix-era convention, since LiveView calls the callbacks.

### Testing

First lesson using **`Phoenix.LiveViewTest`**. Tests live in
`test/tracker_web/live/project_board_live_test.exs` and use the generated
`TrackerWeb.ConnCase` (DB-backed, SQL sandbox) with
`register_and_log_in_user`:

The drill is **purely the two `handle_event` callbacks**; the `Tracker.Issues`
context and `IssueStore` are provided working code. So only the two LiveView
interaction tests are `@tag :pending`; everything else passes in both dirs.

- **auth (not pending — passes in both dirs):** an unauthenticated
  `live(conn, ~p"/projects/:id/board")` redirects to `~p"/users/log-in"`
  (assert the `{:error, {:redirect, %{to: ...}}}` tuple).
- **add issue (`@tag :pending`):** mount the board for the user's project,
  `render_submit` the add-issue form with a title, assert the new title appears
  (`has_element?`/`=~`). Fails in the exercise because the stubbed
  `handle_event("add_issue", ...)` doesn't create the issue.
- **toggle (`@tag :pending`):** with an issue present, `render_click` the
  toggle and assert the status text flips. Fails in the exercise because the
  stubbed `handle_event("toggle", ...)` doesn't toggle.
- **context unit tests (not pending — pass in both dirs)** for `Tracker.Issues`
  (`test/tracker/issues_test.exs`): `create_issue/2` valid and blank-title,
  `list_issues/1` returns the project's issues, `toggle_issue/1` flips status.
  These exercise the provided context directly, independent of the LiveView
  drill.

**Test isolation:** `IssueStore` (like `ProjectStore`) is an app-started
singleton whose state does not roll back with the SQL sandbox. Each test
registers a fresh user and creates a fresh project, so issue ids/contents never
collide across tests. The LiveView tests run `async: false` and assert on *that
board's* contents, never on a global count.

### Drill model & test conventions

- `test/test_helper.exs`: exercises `ExUnit.start(exclude: [pending: true])`
  then the `Sandbox.mode` line; solutions plain `ExUnit.start()` then
  `Sandbox.mode`.
- Solutions pass `mix test --include pending` with zero failures and zero
  warnings, against Postgres. Exercises pass `mix test` (pending excluded),
  compile warning-free, and the two LiveView drill tests fail until
  implemented.
- The exercise is derived from the finished solution by reverting only the two
  `handle_event` callbacks to stubs and tagging the two LiveView tests pending.

## CI / tooling impact

- No new dependencies; the Postgres service added in lesson 26 covers the DB
  needs. `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are unchanged in shape.
- Generated/written LiveView code is `mix format`-clean (run `mix format` after
  authoring). Credo and ExCoveralls remain deferred to lesson 34.
- `tools/build_index` and the Cloud Run deploy are unchanged; lesson 27
  contributes its `slides/`.

## Risks

1. **LiveView auth wiring** (`on_mount` + `live_session`) is the subtlest part
   and depends on exact generated helper names
   (`Accounts.get_user_by_session_token/1`, the session key `"user_token"`).
   Mitigation: prototype the full lesson against the running socket at plan
   time (the prototype-first discipline used for prior phases), verifying both
   the dead and connected renders and the auth redirect.
2. **In-memory issues are throwaway** (migrate in lesson 29). Mitigation: the
   README frames it as the build-then-persist bridge, identical to how projects
   were framed.
3. **`Phoenix.LiveViewTest` doesn't exercise real browser JS.** Accepted per
   the master design; we test what it covers (mount, events, rendered diffs).
4. **In-memory singleton test isolation.** Mitigation: fresh per-test
   user+project, `async: false`, per-board assertions (same approach proven in
   lessons 24–26).

## Success criteria

- Lesson `27-liveview-1` exists with README, HINTS, slides, exercises,
  solutions.
- Every `solutions/` project (incl. lesson 27) passes `mix test --include
  pending` with zero failures and zero warnings, against Postgres.
- Lesson 27's `exercises/` compiles (no warnings under `--warnings-as-errors`)
  and its non-pending tests pass; the two LiveView drill tests fail until
  implemented.
- `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are green in CI with the Postgres service.
- The board at `/projects/:id/board` lists, adds, and toggles issues live in
  one tab; an anonymous visitor is redirected to log in; a user cannot view
  another user's project board.
- After merge, the slide site publishes lesson 27.
