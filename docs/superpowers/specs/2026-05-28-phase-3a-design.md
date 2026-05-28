# Phase 3a — Phoenix fundamentals (lessons 21–25) — Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-05-28
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Parent design:** [Elixir course design](2026-05-21-elixir-course-design.md)

## Purpose

Stand up the first half of Phase 3: the pre-database Phoenix story. Lesson 21
introduces Plug as a standalone concept; lessons 22–25 generate and grow the
threaded `Tracker` app from a fresh `mix phx.new` skeleton to a working
projects index and new-project form, all backed by an in-memory store behind a
context. Auth, Postgres, and LiveView are deferred to a separate Phase 3b cycle
(lessons 26–28).

## Scope

**In scope (this cycle):** lessons 21, 22, 23, 24, 25.

**Out of scope (Phase 3b, separate spec):** lesson 26 (`phx.gen.auth` +
Postgres + CI database), lesson 27 (`liveview-1`), lesson 28 (`liveview-2`,
PubSub). Anything requiring a running database.

By the end of Phase 3a, `Tracker` serves:
- a projects index page rendered from an in-memory store,
- a new-project form that validates input and adds to the store,
- all domain logic behind a `Tracker.Projects` context.

## Decisions locked during brainstorming

1. **Scope = 21–25** (pre-database). The natural seam is lesson 26, where
   Postgres first appears.
2. **Drill model = provided app + stubbed holes.** `exercises/` commits the
   real generated Phoenix app with specific functions/templates/actions left
   as `raise "TODO: ..."` or clearly marked holes, plus failing `@tag :pending`
   tests that target them. README and slides teach the generator commands and
   what they produce. Learners read real generated code and fill the holes.
   This keeps the course's "failing tests as the spec" model and stays
   CI-friendly.
3. **DB handling = full default app, Repo dormant.** Generate with plain
   `mix phx.new tracker` (includes Ecto, Repo, Postgres config). For lessons
   22–25 the Repo is kept *dormant* so no Postgres is needed in CI. Lesson 26
   (Phase 3b) switches it on.

## Conventions & mechanics

### Versions

- `{:phoenix, "~> 1.8"}` — resolves to 1.8.7 (latest stable as of 2026-05).
- `{:phoenix_live_view, "~> 1.1"}` — stable line (the 1.2 RC is avoided).
- App generated with the `phx_new` 1.8.5 installer.
- `mix.lock` is committed for every `exercises/` and `solutions/` project.
- Each lesson README documents the exact Phoenix version it was authored
  against (drift mitigation per the master design's Risk #1).

### Threading (same as Phase 2, Phoenix-sized)

- Each lesson's `exercises/` and `solutions/` are independent committed Mix
  projects. `deps/` and `_build/` remain gitignored.
- Lesson N's `exercises/` = lesson N−1's `solutions/` **plus** new
  `@tag :pending` tests (and any new stubbed holes). One focused addition per
  lesson, enforced by review.
- Lesson 21 is the exception: a standalone Plug project, not part of `Tracker`.
  `Tracker` begins at lesson 22.
- Consequence: lessons 22–25 each commit a full Phoenix app for both
  `exercises/` and `solutions/` (~4 × 2 near-duplicate apps). This is accepted
  by the master design ("the threaded `Tracker` app is not a special
  directory — it lives inside each lesson").

### Keeping the Repo dormant (lessons 22–25)

`mix phx.new tracker` generates an Ecto/Postgres-backed app. To run lessons
22–25 with no database, the committed Tracker app is adjusted as follows, and
the change is narrated in the README so learners understand it:

1. Remove `Tracker.Repo` from the children list in
   `lib/tracker/application.ex` (leave the `Tracker.Repo` module and
   `config/*.exs` Repo config files in place — dormant, not deleted).
2. In `mix.exs`, change the `test` alias from
   `["ecto.create --quiet", "ecto.migrate --quiet", "test"]` to just
   `["test"]` (and likewise drop `ecto.setup`/`ecto.reset` reliance from the
   dev workflow docs for now).
3. In `test/support/conn_case.ex` and `test/test_helper.exs`, remove the
   `Ecto.Adapters.SQL.Sandbox` setup lines (the sandbox checkout and
   `Sandbox.mode/2` call). ConnCase keeps its endpoint/`~p` helpers.

README framing (every Phase 3a Tracker lesson): "Phoenix generated a full
database layer. We're not using it yet — the contexts hold data in memory —
so the Repo stays dormant (commented out of the supervision tree). Lesson 26
switches it on when we add accounts and Postgres."

### Test conventions

- `test/test_helper.exs`: `ExUnit.start(exclude: [pending: true])` in
  `exercises/`; plain `ExUnit.start()` in `solutions/` — same as Phases 0–2.
- ConnCase is used for controller tests (the generated module, minus the Ecto
  sandbox bits). `DataCase` and `Phoenix.LiveViewTest` are not used in 3a.
- New exercise tests carry `@tag :pending` until the learner makes them pass.
- Solutions must pass `mix test` with zero failures and zero warnings.

### In-memory store

- Lesson 24 introduces a minimal in-memory holder, `Tracker.ProjectStore`
  (an `Agent`-backed module: `list/0`, `add/1`) — a deliberate callback to
  Phase 2 OTP. The controller talks to it directly in lesson 24.
- Lesson 25 introduces the `Tracker.Projects` context as the boundary that
  wraps `ProjectStore` (and owns changeset construction). The controller is
  refactored to call the context instead of the store. No data shape change —
  the lesson is about the boundary itself.

## Lessons

### Lesson 21 — `plug` (standalone)

**Not part of Tracker.** A standalone Mix project teaching the Plug contract:
Phoenix is "an OTP application that speaks HTTP," and the unit of that is a
Plug — `init/1` + `call/2` transforming a `Plug.Conn`.

- **Deps:** `{:plug, "~> 1.16"}`. Tests use `Plug.Test` to build and send a
  `%Plug.Conn{}` and assert on the result — no port binding, CI-safe. Bandit
  and Phoenix are named in the narrative only (not depended on).
- **Key ideas:** `Plug.Conn` (request/response fields, `assign`,
  `put_resp_header`, `send_resp`, `halt`); function plugs vs module plugs;
  plugs compose into a pipeline; `Plug.Router`.
- **Drills (3):**
  1. **Function plug** — e.g. `Greeter.call/2` that `assign`s a value or sets
     a response header. Tested via `Plug.Test.conn/3` + assertion on the conn.
  2. **Module plug** — `init/1` + `call/2` implementing a token check: `halt`
     with `send_resp(conn, 401, ...)` when a required header is missing,
     otherwise pass the conn through unchanged.
  3. **`Plug.Router` pipeline** — compose the plugs: `GET /hello` → 200
     `"hello"`; `GET /secret` behind the module plug → 401 without the header,
     200 with it. Tested by sending conns through the router.
- **Failing tests:** assert on conn status / resp_body / headers for each
  drill.

### Lesson 22 — `phoenix-tour`

**Adds to Tracker:** the `mix phx.new tracker` skeleton itself (Repo dormant).

- **README/slides:** run `mix phx.new tracker`; tour the structure
  (`lib/tracker` domain vs `lib/tracker_web` web layer, `Endpoint`, `Router`,
  `Telemetry`, the supervision tree — explicitly tying back to Phase 2:
  "Phoenix is an OTP application; here's its supervision tree"); the dev
  workflow (`mix phx.server`, code reloading, `mix phx.routes`). Explain the
  dormant-Repo adjustment.
- **Drill (1, deliberately tiny — controllers are done properly in 23):** add
  a `GET /ping` route mapping to `PageController.ping/2` that returns
  `text(conn, "pong")`. The action is the stubbed hole.
- **Failing test:** a ConnCase test asserting `get(conn, ~p"/ping")` responds
  200 with body `"pong"`.

### Lesson 23 — `controllers-and-heex`

**Adds to Tracker:** a static Projects index page rendered from a hard-coded
list.

- **Key ideas:** controller actions, `render/3`, HEEx templates, layouts (the
  1.8 `Layouts` module: root + app), core components (`<.header>`, `<.table>`,
  `<.icon>` heroicons), `~p` verified routes, assigns.
- **Drills:** `ProjectController.index/2` assigns a hard-coded list of project
  maps/structs; the `index.html.heex` template renders them (e.g. in a
  `<.table>`). Optionally `show/2` for a single project. Controller action(s)
  and/or template marked as holes.
- **Failing tests:** ConnCase tests asserting `get(conn, ~p"/projects")`
  renders the project names; `show` renders one project's detail.

### Lesson 24 — `forms-and-changesets-preview`

**Adds to Tracker:** a new-project form (in-memory; no DB).

- **Key ideas:** `<.form>` + `to_form/2`, form fields and inputs, handling a
  POST, reading params, `put_flash` + `redirect`, and **schemaless
  changesets** — `Ecto.Changeset.cast/4` over a plain map with a types map,
  giving validation (required fields, length) with no schema, no Repo, no
  Postgres. This is the "just enough changesets to validate" the master design
  calls for, and it works in the dormant-DB phase.
- **In-memory store:** an `Agent`-backed `Tracker.ProjectStore` (`list/0`,
  `add/1`); the controller uses it directly in this lesson (the context
  boundary arrives in 25).
- **Drills:** `ProjectController.new/2` renders the form from an empty
  changeset; `create/2` builds a changeset from params — on invalid, re-render
  the form with errors and a 200; on valid, add to `ProjectStore`, `put_flash`,
  and `redirect` to the index. Action(s) + changeset function are the holes.
- **Failing tests:** posting invalid params re-renders with a visible error;
  posting valid params redirects (302) and the new project appears on the
  index page.

### Lesson 25 — `contexts`

**Adds to Tracker:** the `Tracker.Projects` context (still in-memory),
organizing business logic behind a boundary.

- **Key ideas:** the Phoenix context pattern — why the web layer should call a
  domain boundary instead of owning logic; `Projects` as the public API;
  `change_project/1` returning a changeset for forms.
- **Boundary API:** `list_projects/0`, `get_project!/1`, `create_project/1`
  (validates via changeset, adds to `ProjectStore`, returns
  `{:ok, project}` | `{:error, changeset}`), `change_project/1`.
- **Drills:** implement the `Tracker.Projects` context functions (the holes),
  wrapping `ProjectStore`; refactor the controller from 24 to delegate to the
  context rather than touching the store/changeset directly.
- **Failing tests:** context unit tests (`create_project/1` validates and
  stores; `list_projects/0` returns stored projects; `get_project!/1` raises
  on a missing id) plus the existing controller tests still green through the
  context.

## CI / tooling impact

- `make solutions-test` and `make lint` already iterate every lesson and pick
  these up with no workflow change. Compile is heavier (Phoenix dependency
  tree), but there is **no Postgres** and **no Node/asset build** — the test
  alias is reduced to `["test"]` and `mix test` does not compile assets.
- Generated Phoenix code is already `mix format`-clean. Credo and ExCoveralls
  remain deferred to lesson 34 per the master design, so Phoenix lesson
  `mix.exs` files use the generated form (no `excoveralls`); `check-solutions`
  only runs `mix test`, so this is fine.
- `tools/build_index` and the Cloud Run deploy pipeline are unchanged; each
  lesson contributes its `slides/` as before.
- Repo grows by ~4 near-duplicate Phoenix apps × 2 (exercises + solutions).
  Accepted per the master design.

## Risks

1. **Phoenix version drift.** Mitigation: pin `~> 1.8` / `~> 1.1`, commit
   `mix.lock`, document the exact version in each README, CI runs on the
   pinned `.tool-versions`.
2. **Dormant-Repo confusion.** A learner may wonder why the generated Repo is
   commented out. Mitigation: a consistent README paragraph in every 22–25
   lesson explaining it and pointing to lesson 26.
3. **Generated-app churn across lessons.** Four near-identical apps invite
   drift between exercises and solutions. Mitigation: lesson N exercises are
   produced from lesson N−1 solutions; review enforces "one focused addition."
4. **Heavier CI compile.** Acceptable; no new services required.

## Out of scope (explicit, deferred to Phase 3b)

- `phx.gen.auth`, sessions, route protection (lesson 26).
- Postgres, the CI database service, `DataCase`, migrations (lesson 26+).
- LiveView and `Phoenix.LiveViewTest` (lessons 27–28).
- PubSub and live broadcasting (lesson 28).

## Success criteria

- Lessons 21–25 exist with README, HINTS, slides, exercises, solutions.
- Every `solutions/` passes `mix test` (zero failures, zero warnings) with no
  database.
- Every `exercises/` compiles; its `@tag :pending` tests fail for the right
  reason before the drill is done and pass after.
- `make solutions-test`, `make lint`, `make slides-build`, and the full
  `make ci-smoke` are green with no Postgres.
- After merge, the slide site publishes lessons 21–25.
