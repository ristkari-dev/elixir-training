# Phase 3b-i — Lesson 26 `auth` (the database turn-on) — Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-06-02
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Parent design:** [Elixir course design](2026-05-21-elixir-course-design.md)
**Predecessor:** [Phase 3a design](2026-05-28-phase-3a-design.md)

## Purpose

Lesson 26 is the database-establishing lesson of the threaded `Tracker` app.
It turns Postgres on (reversing Phase 3a's "dormant Repo" setup), adds the CI
Postgres service, generates a controller-based authentication system with
`mix phx.gen.auth`, and integrates it into Tracker: the `/projects` routes are
protected behind login, and projects are scoped to the logged-in user. Users
live in Postgres; projects stay in the in-memory `ProjectStore` but gain a
`user_id`. This is the bridge state the master design calls for — projects
migrate to Postgres in lesson 29.

## Scope

**In scope (this cycle):** lesson 26 only (`26-auth`).

**Out of scope (later cycles, separate specs):**
- LiveView basics — `mount`/`render`/`handle_event` (lesson 27).
- Streams, PubSub, live broadcasting, live comments (lesson 28).
- Migrating projects/issues from in-memory to Postgres; deeper schemas and
  migrations (lesson 29, Phase 4).
- Associations, queries, `Ecto.Multi` (Phase 4).
- Real email delivery — the generated `UserNotifier` stays on the dev/test
  Swoosh adapters; no SMTP/production mailer work.

By the end of lesson 26, Tracker:
- has a real `users` table in Postgres and a working register / log-in /
  log-out / settings flow (generated, controller-based),
- redirects anonymous visitors away from `/projects` to the log-in page,
- shows each logged-in user only their own projects, and attaches the owner
  on create.

## Decisions locked during brainstorming

1. **Scope = lesson 26 only.** Lesson 26 establishes the database and CI
   database service and is qualitatively distinct from the LiveView pair
   (27–28); isolating it mirrors the Phase 3a/3b split rationale and keeps the
   DB-infrastructure change under focused review.
2. **Auth style = controller-based.** `phx.gen.auth` in Phoenix 1.8 defaults to
   a LiveView-based system but offers a controller-only mode (decline the
   LiveView prompt). Lesson 26 uses **controller-based** auth so it builds on
   the controllers learners already know (lessons 23–25) and leaves LiveView a
   clean, fresh introduction in lesson 27. (Slightly non-default, justified by
   the course's bottom-up Plug → controllers → LiveView pedagogy.)
3. **Drill focus = protect routes + scope projects to the user.** The generated
   auth is committed wholesale as provided code (not a drill — learners don't
   hand-write auth). The two hand-written, `@tag :pending` drills are: (a) wire
   `require_authenticated_user` onto the `/projects` routes; (b) scope the
   in-memory `ProjectStore`/`Projects` to the current user. This realizes the
   master design's "projects … now belong to a user."

## Conventions & mechanics

### Versions

- Pinned toolchain (repo `.tool-versions`): Elixir 1.19.5-otp-28 / Erlang
  29.0.1. Phoenix `~> 1.8` (1.8.7); generated with the `phx_new`/`phx.gen.auth`
  1.8.5 tooling.
- `mix.lock` committed for both `exercises/` and `solutions/`.
- README documents the exact Phoenix version (drift mitigation).

### Threading from lesson 25

- `26-auth/exercises/` and `26-auth/solutions/` are full committed copies of
  lesson 25's `solutions/` plus this lesson's additions (generated auth, the
  database turn-on, and the two drills).
- Lesson 25's carried tests remain green baseline (their `@tag :pending` is
  already removed). This lesson's two new drills are `@tag :pending` in both
  dirs (identical test files where applicable); the generated auth tests are
  not tagged pending (they pass as provided code).
- Module prefixes stay `Tracker` / `TrackerWeb`.

### The database turn-on (reverses the Phase 3a dormant-Repo recipe)

Phase 3a kept the generated Repo dormant. Lesson 26 switches it on, in **both**
`exercises/` and `solutions/`:

1. **`lib/tracker/application.ex`** — add `Tracker.Repo` back to the `children`
   list (before the endpoint, as `phx.new` originally generated it).
2. **`mix.exs`** — restore the `test` alias to
   `["ecto.create --quiet", "ecto.migrate --quiet", "test"]`.
3. **`test/support/conn_case.ex`** — restore
   `Tracker.DataCase.setup_sandbox(tags)` in the `setup` block and the
   `setup tags do` header.
4. **`test/test_helper.exs`** — exercises:
   `ExUnit.start(exclude: [pending: true])` followed by
   `Ecto.Adapters.SQL.Sandbox.mode(Tracker.Repo, :manual)`; solutions: plain
   `ExUnit.start()` followed by the same `Sandbox.mode` line. (The course's
   pending-exclusion convention is preserved; the sandbox line is what changes.)
5. The Repo config in `config/dev.exs` and `config/test.exs` already exists
   (generated, dormant since lesson 22) — no new config needed beyond ensuring
   it points at the standard local/CI Postgres (`postgres`/`postgres`,
   `localhost`, db `tracker_test#{partition}` with the SQL Sandbox pool).

README framing: "Lesson 22 generated a database layer and kept it dormant.
Lesson 26 switches it on: the Repo joins the supervision tree, `mix test`
creates and migrates a test database, and tests run inside a transaction that
rolls back (the SQL sandbox)."

### CI: the Postgres service

`.github/workflows/ci.yml` gains a Postgres service container on the `build`
job:

- `services.postgres` using image `postgres:16` (or the version matching the
  generated app's expectations), with
  `env: { POSTGRES_USER: postgres, POSTGRES_PASSWORD: postgres, POSTGRES_DB: postgres }`,
  `ports: ["5432:5432"]`, and a health check
  (`pg_isready`) so steps wait until it accepts connections.
- The existing `make` steps are unchanged: the restored `test` alias runs
  `ecto.create --quiet` + `ecto.migrate --quiet` against the service before
  tests. `make solutions-test` (which runs `mix test --include pending`) and
  `make test` exercise lesson 26's DB-backed suite.
- Lessons 0–25 declare no Repo, so they never touch the service; it simply sits
  available. Only lesson 26 onward uses it.
- Health check + the SQL sandbox (transactional, per-test rollback) keep the
  DB-backed tests deterministic.

### Auth generation (provided, controller-based)

Run inside the threaded app, in both dirs:

```
mix phx.gen.auth Accounts User users
# answer "n" to "Do you want to create a LiveView based authentication system?"
```

This generates (committed wholesale as provided code):
- `lib/tracker/accounts.ex` (the Accounts context),
- `lib/tracker/accounts/{user.ex,user_token.ex,user_notifier.ex,scope.ex}`,
- `lib/tracker_web/user_auth.ex` (the auth plugs incl.
  `require_authenticated_user` and `fetch_current_scope_for_user`, plus
  `on_mount` hooks),
- `lib/tracker_web/controllers/user_session_controller.ex` +
  `user_registration_controller.ex` + `user_settings_controller.ex` and their
  HTML view modules + HEEx templates,
- a `priv/repo/migrations/*_create_users_auth_tables.exs` migration,
- generated tests (`test/tracker/accounts_test.exs`,
  `test/tracker_web/user_auth_test.exs`, the three controller tests) and the
  generated `test/support/fixtures/accounts_fixtures.ex`,
- router injections: the auth routes and the `fetch_current_scope_for_user`
  plug in the `:browser` pipeline.

The 1.8 generator uses the **Scope** pattern: the current user is reached via
`conn.assigns.current_scope.user` (not a bare `current_user`). README and
slides introduce this.

After generation, run `mix ecto.create && mix ecto.migrate` locally so the
solution's generated auth tests pass, and commit the migration. The generated
auth test suite ships **green** in both dirs (it is provided, working code).

### The drill (hand-written, two `@tag :pending` holes)

**(a) Protect the projects routes.** In `lib/tracker_web/router.ex`, the
`/projects` resources must be moved behind the generated
`require_authenticated_user` plug (the generator provides a `scope` block /
pipeline for authenticated routes; the projects routes go there).
- Exercise stub: the `/projects` routes remain in the unauthenticated scope.
- Failing test: `GET /projects` while logged out responds `302` and redirects
  to the generated log-in path (`~p"/users/log-in"`).
- Solution: the routes live under the authenticated scope/pipeline.

**(b) Scope projects to the current user.** The in-memory store and context
gain user ownership:
- `Tracker.ProjectStore` — keys/filters items by `user_id`:
  `add(user_id, attrs)` stores the project with that owner and returns it;
  `list(user_id)` returns only that user's projects (insertion order). (The
  Agent state shape may change, e.g. each stored project carries `:user_id`.)
- `Tracker.Projects` — the boundary takes a **scope**:
  `list_projects(scope)` → `ProjectStore.list(scope.user.id)`;
  `create_project(scope, attrs)` → validates, then
  `ProjectStore.add(scope.user.id, applied_attrs)`, returning
  `{:ok, project}` | `{:error, changeset}`. `change_project/1` is unchanged.
- `TrackerWeb.ProjectController` — `index`/`create` pass
  `conn.assigns.current_scope` into the context.
- Exercise stub: the context/store ignore the user (global list), so the
  scoping tests fail.
- Failing tests (ConnCase, using the generated `register_and_log_in_user`
  helper):
  - a logged-in user sees only their own projects on `GET /projects` (create a
    project as user A, assert user B's index does not show it);
  - `POST /projects` attaches the current user as owner (the created project is
    visible to its creator and not to another user).

### Drill model & test conventions

- Same "provided app + stubbed holes" model as Phase 3a. Generated auth =
  provided; the two integration points = stubs with `@tag :pending` tests.
- Exercise stubs must compile cleanly (no warnings under
  `--warnings-as-errors`); where a provided caller consumes a stubbed function,
  use typed-placeholder stubs (returning a correctly-typed but wrong/incomplete
  value with a `# TODO:` comment) rather than bare `raise`, per the
  established Phoenix-era stub convention.
- `test/test_helper.exs`: exercises exclude `:pending`; solutions do not. Both
  set the SQL sandbox to `:manual`.
- DB-backed tests use the generated `Tracker.DataCase` (sandbox checkout) and
  `TrackerWeb.ConnCase`; the projects drills log a user in with the generated
  `register_and_log_in_user/1` helper.
- **Test isolation caveat for the in-memory store.** The SQL sandbox rolls back
  *database* state per test, but the app-started `ProjectStore` Agent is a
  singleton whose in-memory state persists across tests in a run. The scoping
  tests stay isolated because each test registers a fresh user with a unique
  id, so leftover projects belong to other users and never collide with the
  user under test. The projects ConnCase tests therefore run `async: false`
  (shared singleton) and must assert on per-user visibility, never on a global
  count or an empty store.
- Solutions pass `mix test --include pending` with zero failures and zero
  warnings, against Postgres. Exercises pass `mix test` (pending excluded),
  which still requires the DB (the generated auth tests run).

## CI / tooling impact

- `ci.yml` gains the Postgres service; `make` targets are unchanged (the
  restored `test` alias creates/migrates). Every CI run now starts Postgres.
- `tools/lint-all`, `tools/check-solutions`, `tools/run-all-tests` are
  unchanged; lesson 26's projects compile the full Phoenix + Ecto tree and run
  migrations. Generated code is `mix format`-clean (run `mix format` after
  generation to normalize any long lines, as in Phase 3a).
- Credo and ExCoveralls remain deferred to lesson 34.
- `tools/build_index` and the Cloud Run deploy are unchanged; lesson 26
  contributes its `slides/` as usual.

## Risks

1. **`phx.gen.auth` output specifics / version drift.** Mitigation: generate
   against the pinned 1.8.5 tooling at plan time and verify the exact router
   injection, `UserAuth` plug names, and Scope assign before writing the plan's
   code (the same prototype-first discipline used for Phase 3a).
2. **Hybrid state (Postgres users + in-memory projects).** Conceptually odd.
   Mitigation: the README explicitly frames it as a temporary bridge — users
   need persistence now (auth), projects get persistence in lesson 29.
3. **CI database flakiness.** Mitigation: health-check the service before
   tests; the SQL sandbox isolates each test in a rolled-back transaction.
4. **First DB-backed lesson is heavier.** Acceptable; it is the point of the
   lesson. No new services beyond Postgres.
5. **Scope concept is new in 1.8.** Mitigation: README/slides introduce
   `current_scope.user` gently, contrasting with a bare `current_user`.

## Success criteria

- Lesson `26-auth` exists with README, HINTS, slides, exercises, solutions.
- Every `solutions/` project (including lesson 26) passes `mix test --include
  pending` with zero failures and zero warnings, against Postgres.
- Lesson 26's `exercises/` compiles (no warnings under `--warnings-as-errors`)
  and its non-pending tests (including the generated auth suite) pass against
  Postgres; the two drill tests fail until implemented.
- `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are green in CI **with the Postgres service**.
- The generated register / log-in / log-out / settings flow works; `/projects`
  is protected; a logged-in user sees only their own projects.
- After merge, the slide site publishes lesson 26.
