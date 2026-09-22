# Lesson 29 `schemas-and-migrations` — Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-09-18
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Parent design:** [Elixir course design](2026-05-21-elixir-course-design.md)
**Predecessor:** [Lesson 28 liveview-2 design](2026-06-09-lesson-28-liveview-2-design.md)

## Purpose

Lesson 29 opens Phase 4 by moving Tracker's own domain into Postgres. Projects
and issues have lived in two `Agent`-backed stores since lessons 25 and 27;
this lesson replaces both with Ecto **schemas**, **migrations** and `Repo`
calls. Lesson 26 switched the database on for `phx.gen.auth`'s users table, but
learners have never written a schema or a migration themselves — here they do.

The lesson's payoff is the promise lesson 25 made and repeated through lessons
26–28: the context API stays the same, so the controller, the LiveView and every
template are untouched, and the data now survives a restart.

## Scope

**In scope:** lesson 29 only (`29-schemas-and-migrations`).

**Out of scope (later, separate specs):**
- `belongs_to` / `has_many` / `many_to_many` and preload strategies — lesson 32
  (`associations`). Lesson 29 uses plain id fields plus `references(...)` in the
  migrations.
- The query DSL as a topic: joins, dynamic queries, "my open issues across
  projects" — lesson 31 (`queries`). Lesson 29 uses one flagged `from/where/order_by`
  line, twice.
- `unique_constraint`, `foreign_key_constraint`, `check_constraint`, the
  validation catalog and custom validations — lesson 30 (`changesets-deep`).
  `Ecto.Enum` is named there too.
- `Ecto.Multi`, `Repo.transaction`, rollback patterns — lesson 33.
- Teaching `DataCase` / `ConnCase` / `LiveViewTest` properly, and fixtures vs
  factories — lesson 34 (`testing`). Lesson 29 uses the case templates without
  ceremony, as lessons 26–28 do.
- Releases and running migrations in production — lessons 37–38.
- Closing Tracker's two known authorization gaps (see Risks 6).

By the end of lesson 29:
- `projects` and `issues` are Postgres tables, created by migrations the lesson
  writes,
- `Tracker.Projects` and `Tracker.Issues` return `%Project{}` / `%Issue{}`
  structs from `Repo`,
- `Tracker.ProjectStore` and `Tracker.IssueStore` are deleted, and
- the web layer is unchanged: the board still streams and broadcasts exactly as
  lesson 28 left it, and the data is still there after a restart.

## Decisions locked during brainstorming

**1. Projects is the worked example; issues is the drill.** The `create_projects`
migration, the `Tracker.Projects.Project` schema and the `Repo`-backed
`Tracker.Projects` are provided complete and walked through in README and
slides. The learner writes the `create_issues` migration (Drill 1) and the
`Tracker.Issues.Issue` schema plus the `Repo`-backed `Tracker.Issues` (Drill 2).
Rationale: the lesson row names schemas and migrations, and learners have
written neither, so they must write one of each. Projects has to work in
`exercises/`, because `projects_test`, `project_controller_test` and every board
test create projects.

**2. Each lesson folder gets its own database, starting here.** Literal names in
`config/test.exs` and `config/dev.exs`: `tracker_29_solutions_test` /
`tracker_29_exercises_test` (with `MIX_TEST_PARTITION` appended, as today) and
the matching `_dev` names. Required by decision 1: with the learner writing
`create_issues`, a shared database means "relation \"issues\" already exists" in
one direction and a suite silently testing the other folder's schema in the
other. It also stops CI masking exercise bugs, since `ci-smoke` runs every
solution before any exercise suite. **Rule for later lessons:** every lesson that
copies a Phoenix project renames both databases to its own number; the plan's
self-review greps for the previous lesson's names. Lessons 22–28 are not
backfilled — lessons 22–25 never connect, and 26–28 share only the auth
migration.

**3. The context API does not change.** Same names, same arities, same return
shapes; only the internals move from `Agent` to `Repo`. `ProjectController` and
`ProjectBoardLive` are byte-identical to lesson 28. One deliberate exception:
`get_project!/1` uses `Repo.get!`, so a missing id raises `Ecto.NoResultsError`
(a 404 in production) instead of `RuntimeError` (a 500). The README names it.
Lesson 25's `RuntimeError` and integer-key wording stays as written — it
correctly describes lesson 25's own `Agent`-backed store, which its solution and
its passing test still pin — and the prose commit only appends a forward note
there (see Prose).

**4. Ownership is an id field plus a database foreign key.** `field :user_id, :id`
on `Project`, `field :project_id, :id` on `Issue`; `references(...)` with
`null: false, on_delete: :delete_all` and an index on each in the migrations.
`belongs_to` is lesson 32's, and the upgrade is exactly what lesson 32 shows.
Neither id is ever cast — both are set on the struct, per `AGENTS.md`.

**5. Hand-written, with `mix ecto.gen.migration`.** Schemas are written by hand
so beginners watch the DSL built line by line. Migration files are generated
with `mix ecto.gen.migration create_projects` / `create_issues` (which is also
Drill 1's first command) and filled in by hand. One slide shows what
`mix phx.gen.schema` would emit and why the lesson doesn't use it: with scopes
`default: true`, it writes `changeset(struct, attrs, user_scope)` with a
`put_change`, which doesn't match our API.

**6. `status` stays `:string`.** Schema default `"open"`, `null: false` and a
database default in the migration. Tests compare strings, the toggle flips
strings, and the project form's status input is free text — an `Ecto.Enum` would
break all three and its real value (rejecting bad input with a changeset error)
is lesson 30's. Types are taught through the field-to-column mapping instead:
`:string`→`varchar(255)`, `:id`→`bigint` (the referencing column matching
`references/2`'s `bigserial`), `timestamps type: :utc_datetime`→`timestamp(0)`,
which `\d issues` reports as `timestamp(0) without time zone`, plus the `citext`
the learner already has in the users migration. **Not `timestamptz`:** the slide
makes that the teaching point — `:utc_datetime` is a guarantee Ecto enforces on
the Elixir side (it only stores `DateTime`s in `Etc/UTC`), so the column needs no
time zone of its own; `timestamptz` appears only if you write the type yourself.

`change_project/1` keeps `validate_required([:name])`, as lesson 28 has it, and
Drill 2's `change_issue/1` mirrors it with `[:title]`. A blank status cannot
fail a validation and cannot reach the database as `NULL`: `cast/4` treats `""`
as an empty value and substitutes the schema default before casting, recording
no change at all, and `Repo.insert/1` then writes `"open"` from the struct. That
two-layer guarantee — schema default, `null: false` plus a database default — is
what the README explains; adding `:status` to `validate_required` would ship a
check that provably never fires.

**7. Ordering is a flagged one-line query preview.** `import Ecto.Query` and
`from(p in Project, where: p.user_id == ^scope.user.id, order_by: [asc: p.id])`
in the provided `list_projects/1`, mirrored by the learner in `list_issues/1`
(full code in Hint 3), each with a comment pointing at lesson 31. A table has no
inherent order, and toggling an issue updates its row, so without `order_by` the
board reorders on reload. Sorting in Elixir would teach the wrong default.

**8. No-paren DSL, and the root formatter stops touching lessons.** Lesson 29's
files — new and carried — use the parenthesis-free DSL that the Ecto and Phoenix
docs use. Three mechanics matter, because the obvious one doesn't work:
- `mix format` **never removes** parentheses from a call listed in
  `locals_without_parens`; it only declines to add them. Both styles are
  format-stable under the same `.formatter.exs`, which is why lessons 27 and 28
  ship the same generated files in opposite styles with `make lint` green. So
  the normalization commit is a scripted-then-eyeballed rewrite over `lib/`,
  `test/`, `config/` and `priv/repo/migrations/` in both folders, not a format
  run. `mix format --check-formatted` inside the lesson folder is the check that
  the result is stable, nothing more.
- The repo-root `.formatter.exs` drops `lessons/**` from its inputs. It has
  `locals_without_parens: []`, so formatting from the root is what adds the
  parens back.
- The generators are not a clean precedent either — `phx.gen.auth`'s output
  writes `timestamps(type: :utc_datetime)` with parens. The docs are the
  reference the learner will read next, so they win.

Lessons 22–28 keep their current formatting.

**9. A provided test inspects the table itself.** No carried test can see
`null: false`, the database default, the foreign key or the index, so a wrong
migration would pass. `test/tracker/issues_table_test.exs` (provided, `@tag
:pending`) queries the real table: a `foreign_key_violation` for a bogus
`project_id`, the `"open"` default on an insert that omits status, a
`not_null_violation` **naming the `title` column** for a missing title, and
`issues_project_id_index` in `pg_indexes`. It uses `Repo.insert_all("issues", ...)`
and `Repo.query!` with the table name as a string, never `%Issue{}`, so it
compiles before Drill 2 exists. Before Drill 1 every check fails on
`:undefined_table` — the right reason.

Two mechanics the plan must honor, both verified against the pinned deps:
`insert_all` with a string source has no schema, so Ecto autogenerates nothing,
while `timestamps type: :utc_datetime` emits both columns `null: false`. Every
row the test inserts therefore supplies `inserted_at`/`updated_at` explicitly
(a private `row/1` helper), or Postgres rejects it on `inserted_at` before the
foreign key or the status default is ever reached. And the missing-title check
asserts the column name, because otherwise a nullable `title` would still pass on
some other NOT NULL column. `insert_all` being the raw path that hands you none
of `insert/2`'s conveniences is worth one line in the README. Each of the four
checks is its own `test` block: a rejected statement aborts the surrounding
sandbox transaction, so two constraint checks sharing a test would fail on
"current transaction is aborted" instead of on what they assert.

This is also the lesson's "one new test file", per the master design.

**10. Both stores are deleted.** `lib/tracker/project_store.ex` and
`lib/tracker/issue_store.ex` go, along with their two `application.ex` children,
in both folders. Their moduledocs have promised this since lesson 25. Keeping an
Agent behind the exercise stubs would let the pending tests pass without
Postgres.

## Conventions & mechanics

### Versions

- Pinned toolchain (repo `.tool-versions`): Elixir 1.19.5-otp-28 / Erlang
  29.0.1. **It must be installed before prototyping** — `mise ls` currently
  reports both as missing and recent local builds used Elixir 1.20, while CI
  pins 1.19.5 strictly. The stub convention exists because of the 1.19 type
  checker, so 1.20 results prove nothing.
- Phoenix 1.8.7, `phoenix_live_view` 1.1.30, `ecto` 3.14.0, `ecto_sql` 3.14.0,
  `postgrex` 0.22.2, `phoenix_ecto` 4.7.0. **No new Hex dependencies** —
  `phoenix_ecto`, `ecto_sql` and `postgrex` have been in `mix.exs` since
  `phx.new`. `mix.lock` committed for both folders.
- Postgres 16 (`docker-compose.yml` locally, the `postgres:16-alpine` service in
  CI).

### Threading from lesson 28

- `29-schemas-and-migrations/solutions/` is a full copy of lesson 28's
  `solutions/` plus this lesson's changes; `exercises/` is derived from the
  finished solution.
- Module prefixes stay `Tracker` / `TrackerWeb`.
- The auth migration `20260603050426_create_users_auth_tables.exs` keeps its
  version and its content; the normalization commit (decision 8) removes the
  parens the root formatter added to it, since the lesson sends learners into
  that file to read `citext` and two migration styles in one directory would
  undo the point. Re-wording an applied migration is inert — `schema_migrations`
  records the version, never the text — and lesson 29 has its own databases
  anyway. `priv/repo/migrations/.formatter.exs` is carried too (migrations are
  formatted by that nested config, not the project's).
- Both new migrations are generated once, in `solutions/`. `create_projects` is
  copied byte-for-byte into `exercises/`; the timestamp must be earlier than
  `create_issues`, which `exercises/` does not ship at all.
- Later lessons add new migrations; lesson 29's are never edited in place.

### The projects side (provided)

`priv/repo/migrations/<ts>_create_projects.exs`:

```elixir
create table(:projects) do
  add :name, :string, null: false
  add :status, :string, null: false, default: "open"
  add :user_id, references(:users, on_delete: :delete_all), null: false

  timestamps type: :utc_datetime
end

create index(:projects, [:user_id])
```

`lib/tracker/projects/project.ex`:

```elixir
defmodule Tracker.Projects.Project do
  use Ecto.Schema

  schema "projects" do
    field :name, :string
    field :status, :string, default: "open"
    field :user_id, :id

    timestamps type: :utc_datetime
  end
end
```

`lib/tracker/projects.ex` keeps every signature and swaps the store for `Repo`:
`list_projects/1` is the query preview above; `get_project!/1` is
`Repo.get!(Project, id)`; `change_project/1` becomes
`%Project{} |> Ecto.Changeset.cast(attrs, [:name, :status]) |> validate_required([:name])`
(a schema-backed changeset instead of lesson 24's `{data, types}` pair);
`create_project/2` puts the scope's `user_id` on the struct and calls
`Repo.insert/1`, which already returns `{:ok, struct} | {:error, changeset}` —
the shape lesson 25 promised.

### The drills (`@tag :pending`)

**Drill 1 — the `create_issues` migration.** `mix ecto.gen.migration create_issues`,
then a table with `title` (`:string`, `null: false`), `status` (`:string`,
`null: false`, `default: "open"`), `project_id`
(`references(:projects, on_delete: :delete_all)`, `null: false`),
`timestamps type: :utc_datetime`, and `create index(:issues, [:project_id])`.
Driven by `test/tracker/issues_table_test.exs`.

**Drill 2 — the `Issue` schema and the `Issues` context.** `lib/tracker/issues/issue.ex`
mirroring `Project`, then `Tracker.Issues` on `Repo`: `list_issues/1` as the
mirrored query, `change_issue/1` as a schema-backed changeset,
`create_issue/2` setting `project_id` on the struct, and `toggle_issue/1` as
`Repo.get!` → `Ecto.Changeset.change(issue, status: flip(issue.status))` →
`Repo.update!`, returning the bare struct the LiveView expects.

Exercise stubs follow the Phoenix-era convention: typed placeholders with
`# TODO:` comments, never a bare `raise`, no unused aliases, imports, variables
or private functions, compile-clean under `--warnings-as-errors`, and no
reference to `%Issue{}` (the module doesn't exist yet) anywhere in `lib/` or
`test/`. `change_issue/1` must stay a working schemaless changeset, because
`ProjectBoardLive.mount/3` consumes it on every board load.

The plan's prototype settled `create_issue/2`'s stub shape: it returns **both**
`{:ok, _}` and `{:error, _}`, like lesson 25's. An error-only stub fails the
build — Elixir 1.19's type checker reports "the following clause will never
match: `{:ok, issue}`" against the provided LiveView. The consequence is that
the stub can fabricate an issue, so three drill tests assert persistence rather
than rendering: the board's add and multi-tab tests reload the board, and
`create_issue/2`'s context test reads the issue back with `list_issues/1`.
Without that the stub satisfies them and they pass with the drill undone
(`assert issue.id` does not save it — the stub's `0` is truthy).

### Testing

`Tracker.DataCase` for contexts, `TrackerWeb.ConnCase` with
`register_and_log_in_user` for the controller and the LiveView, both DB-backed
through the SQL sandbox lesson 26 introduced.

- `async: true` on `projects_test.exs`, `issues_test.exs`,
  `project_controller_test.exs` and `project_board_live_test.exs`. The
  singletons that forced `async: false` are gone, and the comments blaming them
  are deleted. This is the first async LiveView DB test in the repo, so the
  prototype must confirm it: `LiveViewTest` propagates the test pid through
  `$callers`, which the sandbox honors, and sequences don't roll back, so ids and
  `board:<id>` topics stay unique — but a LiveView touching the database after
  its owner exits would log sandbox noise.
- `issues_test.exs` creates a real user and project through an inline private
  helper (mirroring `project_board_live_test.exs`) instead of the made-up
  project ids 1/101/102, which now violate the foreign key. No new fixtures
  module — that's lesson 34's.
- `projects_test.exs`'s missing-id test asserts `Ecto.NoResultsError`.
- Pending: the four `issues_table_test.exs` checks (Drill 1), the three
  `issues_test.exs` behaviors that need a persisted issue, and the board's add,
  toggle and multi-tab tests (Drill 2) — **10**, above lessons 26–28's 2–4,
  which the README's drill section reflects. Every board and issue test needs
  both drills done. Prototype counts: solution **118 tests / 0 failures**;
  exercise **108 / 0 with 10 excluded**, and exactly those 10 failing under
  `--include pending`, each for its own reason (the plan tabulates them).
- Carried tests keep the `"project"` / `"issue"` form param keys and the
  `#issues-<id>` stream DOM ids.

### Drill model & test conventions

- `test/test_helper.exs`: exercises `ExUnit.start(exclude: [pending: true])`,
  solutions plain `ExUnit.start()`, both followed by the `Sandbox.mode` line.
- Solutions pass `mix test --include pending` with zero failures and zero
  warnings against Postgres. Exercises compile warning-free, pass `mix test`
  with the pending tests excluded, and fail exactly the pending ones under
  `mix test --include pending`.
- `mix precommit` (already defined in `mix.exs`: compile `--warnings-as-errors`,
  `deps.unlock --unused`, format, test) is the manual zero-warnings gate, since
  no repo tool enforces it.
- Documented `exercises/` ↔ `solutions/` differences: the two drill files, the
  `Issue` schema, the `create_issues` migration, `test_helper.exs`, the pending
  tags, and — new this lesson — `config/test.exs` and `config/dev.exs`.

### Prose

README (~60 lines, lesson 28's shape): the payoff framing ("lesson 25 promised
the API wouldn't change — here's the swap"), callbacks to lesson 14's `Agent`,
lessons 17/18/24 on state dying with the process, lesson 24's schemaless
changeset, lesson 25's boundary, lesson 26's sandbox and users migration. A
"Try it" step — create a project, restart `mix phx.server`, it's still there —
which is the demo lesson 24 set up. A note on why two domains move at once,
against the one-focused-addition rule. Common mistakes leads with "Postgres
isn't running", then a missing `mix ecto.setup` (each lesson folder now has its
own database, and the dev endpoint's `CheckRepoStatus` page appears until it
runs), then editing an already-run migration: `mix ecto.rollback` only touches
dev, so a test-side fix needs `MIX_ENV=test mix ecto.rollback` or
`MIX_ENV=test mix ecto.reset`. Also: registering again in the fresh dev database
means reading the login link at `/dev/mailbox`.

HINTS: two drill sections, three hints each, hint 3 being full code.

Slides: the migration, the schema, `Repo` calls replacing the `Agent`, the
field-to-column mapping, why `project_id` is indexed, the `phx.gen.schema`
comparison, and the `from/where/order_by` preview. Closer: "Next: lesson 30 —
changesets-deep" with `make slides-dev LESSON=30-changesets-deep`.

A separate prose commit does two different things, and the plan must keep them
apart:
- **Corrections.** The stale forward references that tell learners Postgres
  arrives in lesson 26 (`lessons/23-controllers-and-heex/README.md`,
  `lessons/24-forms-and-changesets-preview/README.md` and its slides) are wrong
  today and are rewritten to point at lesson 29.
- **A forward note, not a correction.** Lesson 25's `RuntimeError` and
  integer-key lines describe lesson 25's own `Agent` store accurately, and its
  solution and tests still pin them. They keep their wording and gain one
  sentence saying lesson 29 replaces the store with `Repo.get!`, after which the
  same lookup raises `Ecto.NoResultsError` and accepts a string id.

## CI / tooling impact

- No new dependencies, no workflow change: the Postgres service already exists,
  every make target globs `lessons/*`, and `tools/build_index` already lists
  lesson 29, so it publishes as soon as `slides/` exists.
- The per-folder database names need no tooling change: the `mix test` alias
  runs `ecto.create` and `ecto.migrate`, and the CI service accepts any name.
- The repo-root `.formatter.exs` drops `lessons/**` from its inputs (decision 8).
- CI cost: one more Phoenix+Ecto project pair, compiled from scratch and tested
  five times per job, with no `_build` cache.
- The plan's all-lessons-publish loop grows to 30 slugs.

## Risks

1. **Shared database state.** Mitigated by decision 2 (per-lesson, per-folder
   names) and by the rule that later lessons rename on copy. The plan's
   self-review greps for stale names.
2. **Migration ordering and edits.** `create_issues` must be stamped after
   `create_projects`, or `references(:projects)` fails on a fresh database.
   Editing an applied migration silently does nothing. Mitigation: generate both
   in one sitting, and cover rollback in Common mistakes.
3. **Stubs under the 1.19 type checker.** A stub whose result the provided code
   consumes can warn or crash confusingly (see The drills). Mitigation:
   prototype under the pinned toolchain, run `mix precommit`, and confirm each
   pending test's failure reason.
4. **`async: true` on LiveView DB tests is a repo first.** Cleared by the
   prototype: four consecutive runs of the full solution suite were green with
   no sandbox "owner exited" noise. If it ever appears, fall back to
   `async: false` for the board test alone.
5. **Lesson size.** Two domains, schemas, migrations, indexes, the `Repo` API
   and ~10 pending tests may run past the 1–2 hour target. Mitigation: projects
   is read-only worked example, the drills stay narrow, and anything optional
   goes to "Going further".
6. **Authorization gaps carried forward.** `ProjectController.show/2` loads any
   project by id, and the board's `toggle` accepts any issue id, so a crafted
   `phx-value-id` can toggle another project's issue. Both predate this lesson
   and persistence doesn't worsen them. Deliberately out of scope to keep the
   diff about storage; recorded for lesson 31, where scoped queries make the fix
   natural. The spec for lesson 31 must pick them up.
7. **`toggle_issue/1` is no longer atomic.** The `Agent` flipped inside
   `get_and_update`; `Repo.get!` then `update!` is read-then-write, so two tabs
   toggling at the same instant can race. Acceptable for teaching; `update_all`
   and transactions are lessons 31 and 33.
8. **The paren normalization is a hand pass, not a format run.** `mix format`
   can neither perform it nor catch a mistake in it (decision 8), and it touches
   a few hundred call sites across both folders. Mitigation: script the rewrite,
   review the diff by eye, and rely on the full suite plus
   `mix compile --warnings-as-errors` to prove nothing changed behaviorally —
   the normalization is its own commit so the diff stays reviewable.
9. **Master-design invariants that don't match the repo.** The master design
   says exercise tests may fail and describes a per-lesson CI matrix, but CI is
   a single job and `tools/run-all-tests` fails on any non-pending exercise
   failure. Lesson 29 follows the repo, not the invariant.

## Open items for later specs

- Lesson 31's row lists preloads, which need lesson 32's associations — the
  ordering needs resolving in the lesson 31 spec.
- No lesson owns the Project↔User association from the master design's data
  model; lesson 32 should claim it.
- The master design says the generators are "taught explicitly", but no lesson
  yet does beyond lesson 29's one comparison slide. Lesson 29 is the first point
  where Tracker has schemas, so `phx.gen.html` / `phx.gen.context` /
  `phx.gen.live` need a home in Phase 4 or 5.
- Lesson 36's stale-issue digest depends on `issues.updated_at`, so issue
  timestamps keep `updated_at` (no `updated_at: false`).

## Success criteria

- Lesson `29-schemas-and-migrations` exists with README, HINTS, slides,
  exercises, solutions.
- `projects` and `issues` are Postgres tables; both `Agent` stores and their
  supervisor children are gone from both folders.
- The web layer (`ProjectController`, `ProjectBoardLive`, templates) is
  unchanged from lesson 28 apart from formatting.
- Every `solutions/` project (including lesson 29) passes `mix test --include
  pending` with zero failures and zero warnings against Postgres.
- Lesson 29's `exercises/` compiles warning-free under `--warnings-as-errors`,
  passes `mix test` with pending excluded, and fails exactly the pending drill
  tests — against its own database, with `solutions/` never migrated into it.
- `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are green in CI.
- A project created in `mix phx.server` is still there after a restart.
- After merge, the slide site publishes lesson 29.
