# Lesson 31 `queries` — Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-09-24
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Parent design:** [Elixir course design](2026-05-21-elixir-course-design.md)
**Predecessor:** [Lesson 30 changesets-deep design](2026-09-22-lesson-30-changesets-deep-design.md)

## Purpose

Tracker can store rows and refuse bad ones. It still cannot answer a question
that spans two tables.

Lesson 31 teaches the query: `from`, `where`, `order_by`, the `^` pin, `join`
with an explicit `on:`, bindings, `select` shapes, and queries composed from
plain functions. The feature it earns is the one the master design licensed —
**my open issues, across every project I own** — and the same join then fixes a
real security bug that has been sitting in Tracker since lesson 29.

The load-bearing sentence: **a query is a value. It does not touch the database
until `Repo` runs it, and it knows nothing about how your tables relate — only
the `on:` you wrote.**

## Scope

**In scope:** lesson 31 only (`31-queries`).

**Out of scope (later, separate specs):**
- `preload` — it needs a declared association, and associations are lesson 32.
  See decision 1; this is the lesson's cliffhanger, not an omission.
- `belongs_to` / `has_many` / `many_to_many`, `cast_assoc`, the `Comment`
  domain, assignees — lesson 32.
- `Ecto.Multi`, transactions, "move issue between projects" — lesson 33.
- Teaching `DataCase` / `ConnCase` / `LiveViewTest`, fixtures vs factories —
  lesson 34. Lesson 31 uses the case templates without ceremony and adds no
  fixtures module.
- `Ecto.Query.dynamic/2`, `update_all`, subqueries, `select_merge` — named in
  "Going further" with the case each one solves, not taught.

By the end of lesson 31:
- `GET /issues` lists the learner's open issues across all their projects, with
  the project name beside each one,
- that list is built by a join the learner wrote, filtered by a composable
  function, not by `Enum`,
- `get_project!` and `toggle_issue` take the scope and filter on it, so one user
  can no longer read or write another user's rows, and
- the learner can say what a query *is* — a value, built up and passed around,
  that runs only when `Repo` sees it.

## Decisions locked during brainstorming

**1. `preload` is deferred to lesson 32; lesson 31 answers the same question
with `join` + `select`.** The constraint is absolute, not stylistic — but the
error a learner sees depends on which spelling they try, and the prose must name
the right one:
- `preload: [project: p]` (binding form) — `Ecto.QueryError`, "field
  `Tracker.Issues.Issue.project` in preload is not an association", raised by the
  planner during normalization.
- `preload: [:project]` **on this lesson's query** — also caught by the planner,
  because the query has a map `select`, so it never reaches the preloader.
- `Repo.preload(issues, :project)` on already-loaded structs — `ArgumentError`,
  "schema Tracker.Issues.Issue does not have association or embed :project",
  from `Ecto.Repo.Preloader`.

There is no escape hatch: every path resolves a *declared* association.
**Common mistakes must show the middle case**, since that is the one a learner
reaches for. Joins are unaffected — `join: p in Project, on: i.project_id == p.id`
works on plain id columns.

"Show the project name next to each issue" is therefore answered by
`select: %{title: i.title, project: p.name}` across the join: the
mechanism-first answer, which is the right order for this course. One slide
names `preload`, states exactly why it cannot work yet (an association is a
declaration on the schema, not a clause in the query), and hands it to lesson
32 — where the N+1 demonstration lands harder on someone who has hand-written
the `on:`.

Note there is **no in-tree precedent for an `on:`-based join**: the only joins
in the repo (`accounts/user_token.ex`) use `assoc/2`, which resolves a declared
association. The lesson is teaching the form the learner has not seen.

**2. The contexts move to scope-first arities.** `get_project!(scope, id)` and
`toggle_issue(scope, id)`, each filtering on `scope.user.id` inside the query.
This is the repo's own rule (`AGENTS.md`: "Always pass the assign
`current_scope` to context modules as first argument. When performing queries,
use `current_scope.user` to filter the query results"), which `list_projects/1`
and `create_project/2` already follow and these two do not.

Lessons 29 and 30 kept every signature stable. Lesson 31 does not, and the
README says so in a sentence rather than letting it read as drift: those lessons
were about storage and rules, which are not about *who is asking*; this lesson
is about the query, and **a query that forgets who is asking is a security
bug**. Keep the house habit of naming the web-layer cost: lesson 29 changed zero
lines, lesson 30 exactly one, lesson 31 changes roughly thirty.

Note for the prose: lesson 30's "every context signature stays exactly as lesson
29 left it" is scoped to lesson 30's own diff and stays true. Lesson 31 ends a
streak; it does not falsify a claim.

**3. `Projects.fetch_project(scope, id)` exists alongside the bang version.**
Returning `{:ok, %Project{}} | :error`. The controller wants a 404 (so it calls
the bang); the board's `mount/3` wants a friendly flash-and-redirect (so it
calls this one). Without it, a scoped `get_project!` raising inside `mount/3`
crashes the LiveView and the carried board test — which asserts
`{:error, {:redirect, %{to: "/projects"}}}` — goes red. With it, that assertion
survives byte-for-byte, the hand-rolled `if project.user_id == ...` disappears
from the LiveView, and ownership moves from an `if` in the web layer into the
`where` in the query. That is the lesson's claim, demonstrated.

The bang/non-bang pair is itself teachable: two callers, two genuinely different
needs, the same `Repo.get`/`Repo.get!` idiom learners already use.

**4. The two authorization gaps are fixed, split along the usual seam.**

*Gap 1 (provided, projects side).* `ProjectController.show/2` loads any project
by id: any logged-in user can `GET /projects/<id>` and read another user's
project name and status, enumerable by incrementing the id. Fixed by decisions 2
and 3. **There is no `GET /projects/:id` test today**, so nothing goes red — the
fix ships its own: one for "renders my project", one asserting a 404 for someone
else's.

*Gap 2 (drilled, issues side).* The board's `toggle` passes the client-supplied
`phx-value-id` straight to `Issues.toggle_issue/1`, which does a bare
`Repo.get!`. From a board they own, a user can flip **any** issue row in the
database. Three consequences, in severity order: a write to another user's row;
an information leak, because the toggled issue is `stream_insert`ed into the
attacker's board, rendering the victim's issue title; and an existence oracle,
since a nonexistent id raises where a real one succeeds. The tamper is silent —
the broadcast goes to the *attacker's* topic, so the victim's open tab never
updates.

The fix is this lesson's join, applied to a security bug:
`from(i in Issue, join: p in Project, on: i.project_id == p.id, where: i.id == ^id and p.user_id == ^scope.user.id)`.
**A third, one-line bug rides along:** the broadcast must use
`topic(issue.project_id)`, not the mounted project's id, or toggling an issue
from another of your own boards still notifies the wrong room.

**The contract is `{:ok, %Issue{}} | :error`, and it never raises on a miss.**
This is pinned here for the same reason `fetch_project/2` is: a raising lookup
inside `handle_event/3` kills the LiveView process, so the new board test would
need `catch_exit` and the suite would log a crash report. Instead
`handle_event("toggle", ...)` matches — `{:ok, issue}` broadcasts to
`topic(issue.project_id)` and `stream_insert`s; `:error` returns
`{:noreply, socket}` and nothing happens, which is exactly what a crafted id
should do. The drill test then reads normally: push the crafted toggle, assert
the response, then read the victim's row back from Postgres and assert it did
not move.

**5. `list_issues/1` and `create_issue/2` keep taking a bare `project_id`, and
the README says why.** This looks inconsistent with decision 2 and is not: the
board proves ownership once at `mount/3` via `fetch_project/2`, and both
functions receive `socket.assigns.project.id` — a server-held value. `toggle`
was exploitable because its id came from the client. The distinction is the
lesson's point in miniature: **scope the reads whose key the user can choose.**

**6. The feature is a controller page at `GET /issues`.** A new
`TrackerWeb.IssueController.index/2` plus a template, mirroring
`ProjectController`, which learners already know. Query params drive the filter
(`/issues?status=open`), which motivates composition honestly. No new LiveView
surface in an Ecto lesson; lesson 28 already taught LiveView.

**7. "Dynamic queries" means composable `query -> query` functions.** Plain
private functions that take a query and return one, piped together, so the query
is assembled from what the user asked for:

```elixir
# public: the query as a value — this is what the test can hold
def my_issues_query(scope, filters \\ %{}) do
  Issue
  |> for_user(scope)
  |> filter_status(filters)
  |> newest_first()
end

def list_my_issues(scope, filters \\ %{}), do: scope |> my_issues_query(filters) |> Repo.all()
```

`for_user/2`, `filter_status/2` and `newest_first/1` stay private. The split is
not ceremony: `my_issues_query/2` is the seam decision 9's guard needs, and it
is also the lesson's thesis made executable — the query exists as a value before
anything runs it.

`Ecto.Query.dynamic/2` gets a Going-further paragraph naming the case it
actually solves (a condition assembled at runtime that must land inside one
`where`, or an `or_where` chain). It is not taught: its payoff appears in filter
combinations beginners have not met, and it would make a third mechanism in a
lesson already carrying joins, selects and the scoped rewrite.

**8. No new migration.** `issues(project_id)` and `projects(user_id)` both exist
from lesson 29 and cover both hops of the join. Adding an index nothing needs,
purely to have something to assert on, would be cargo cult. The README says this
out loud — "when do I add an index" is a question beginners ask exactly here —
and points at `EXPLAIN` in Going further.

**9. The anti-fake guard asserts on the query, not the rows.** A learner can
satisfy every behavioural assertion with `Repo.all(Issue) |> Enum.filter(...)`,
doing the work in Elixir while the database does none of it. So the provided
test file holds the query itself and asserts on the SQL it compiles to:

```elixir
query = Issues.my_issues_query(scope, %{"status" => "open"})
assert %Ecto.Query{} = query

{sql, _params} = Repo.to_sql(:all, query)
assert sql =~ "JOIN"
assert sql =~ "WHERE"
```

Two details the plan must not "tidy": the function is the repo-injected
`Repo.to_sql/2` (the module form is `Ecto.Adapters.SQL.to_sql/3` and takes the
repo as its second argument), and it returns `{sql, params}` — so the tuple is
destructured before `=~`, which needs a binary on its left. Same device as
lesson 29's raw `insert_all` and lesson 30's `pg_indexes` assertion, aimed at
this lesson's specific fake.

**10. `update_all` gets a Going-further paragraph that answers the promise
literally.** Lesson 29's README told learners, about the toggle specifically:
"One `update_all` statement could flip it in the database without loading
anything. Lessons 31 and 33." The paragraph must therefore be about *that*
statement, and must give the reason Tracker does not use it here: **`update_all`
does not touch `updated_at`** (Ecto's own docs say so), and lesson 36's
stale-issue digest depends on that column. A bulk-close example that dodges the
promised case would not honour it.

## Conventions & mechanics

### Versions

- Pinned toolchain: Elixir 1.19.5-otp-28 / Erlang 29.0.1. Install with
  `mise install`; run **every** `mix` and `make` as `mise x -- ...`.
- Phoenix 1.8.7, ecto 3.14.0, ecto_sql 3.14.0, postgrex 0.22.2. **No new Hex
  dependencies** — `Ecto.Query` ships in ecto.
- Postgres 16.

### Threading from lesson 30

- `31-queries/solutions/` is a copy of lesson 30's `solutions/` plus this
  lesson's changes; `exercises/` is derived from the finished solution.
- **Rename the databases** to `tracker_31_{solutions,exercises}_{test,dev}` in
  both folders' `config/test.exs` and `config/dev.exs`, and in the README's
  Common mistakes. Self-review greps for `tracker_30_`.
- Keep `deps/` when copying rather than re-fetching. `:heroicons` is a **git
  dependency over HTTPS**; CI fetches it fine, but the local sandbox may not
  have outbound access, and a warm `deps/` is free. (Lesson 30's plan recorded
  this as SSH — that was wrong; the conclusion stands.)
- All five carried migrations are carried byte-for-byte and never edited.
- Resolve the four `# Query syntax is lesson 31` comments in lesson 31's own
  copies — the lesson they point at has arrived. Lesson 30's copies stay as
  they are.

### The projects side (provided)

`Projects.get_project!(scope, id)` and `Projects.fetch_project(scope, id)`, both
scoped; `ProjectController.show/2` passes the scope; `ProjectBoardLive.mount/3`
branches on `fetch_project/2`. The `/issues` page, its controller and its
template are also provided — but see the test-budget note below, because the
page depends on drilled code.

### The drills (`@tag :pending`)

**Drill 1 — the cross-project query.** Write `Issues.list_my_issues/2` and its
composable helpers: the join with an explicit `on:`, the `where` on
`scope.user.id`, a `select` shaping `%{id:, title:, project_name:}`,
`filter_status/2` over the query params, and `newest_first/1`.

**Drill 2 — the scoped toggle.** Rewrite `Issues.toggle_issue/2` around the same
join, update the LiveView call site, and fix the broadcast topic to
`issue.project_id`.

**The provided-page collision has two halves, and both must be handled.**

*Runtime:* the `/issues` page is provided but its controller calls drilled code,
so **its ConnCase test is tagged pending**; a non-pending test for it would make
`exercises` red from the first `mix test`.

*Compile time — the half that bites harder:* in `exercises/`, the provided
`IssueController.index/2` calls `Issues.list_my_issues/2`, and the provided
`ProjectBoardLive` calls `Issues.toggle_issue/2` at its new arity. If the drill
simply "creates" those functions, the exercise does not compile — Elixir emits
"undefined or private", and `--warnings-as-errors` turns that into a failure
before a single test runs. So `exercises/lib/tracker/issues.ex` ships **typed
placeholders at the final arities**, per the stub convention:

```elixir
def my_issues_query(_scope, _filters \\ %{}) do
  # TODO (drill 1): build the query — join to projects, scope to this user.
  Issue
end

def list_my_issues(scope, filters \\ %{}), do: scope |> my_issues_query(filters) |> Repo.all()

def toggle_issue(_scope, _id) do
  # TODO (drill 2): find this user's issue through a join, then flip it.
  :error
end
```

`my_issues_query/2` returning bare `Issue` keeps the page rendering (every issue,
unscoped and unfiltered) rather than crashing, which makes the drill's job
visible; `toggle_issue/2` returning `:error` matches the contract the provided
LiveView already branches on. Both are wrong in ways the pending tests catch —
the `to_sql` guard sees no `JOIN`, and the toggle changes nothing.

**Test budget.** Target **9** pending: roughly five for drill 1 (including the
page test), four for drill 2. At least one test in the new file stays untagged
so the learner sees it is alive.

**Fixtures.** The carried `issues_test.exs` helper mints a fresh user per
project, so no existing fixture can express drill 1's headline case — one user,
two projects, issues in both. The new test file needs its own small helper that
takes a scope and creates a second project under it. No fixtures module; that is
lesson 34's.

### Testing

- `Tracker.DataCase` for context and query tests, `TrackerWeb.ConnCase` with
  `register_and_log_in_user` for the controller and LiveView, all `async: true`.
  `DataCase` already imports `Ecto.Query`.
- Assertions are per-scope membership, never global counts; LiveView tests target
  a specific `#issues-<id>`.
- Carried tests that change: `projects_test.exs` (the `get_project!` arity, plus
  a new "raises for another user's project"), `issues_test.exs` (the
  `toggle_issue` arity and its helper), `project_board_live_test.exs` (a new
  crafted-toggle test; the existing redirect assertion is unchanged by design —
  see decision 3), and `project_controller_test.exs` (two new `show/2` tests).
- Zero-warnings gate needs **both** flags:
  `mise x -- env MIX_ENV=test mix do compile --force --warnings-as-errors + test --warnings-as-errors`.

### Prose

README sections as lessons 29–30, with these obligations: the load-bearing
sentence; why scope moved into the signatures and the ~30 web-layer lines;
decision 5's read-scoping rule; `preload` named with its exact reason and handed
to lesson 32; why no index was added; and Common mistakes covering a missing `^`
(an unbound variable in a query), `select` before `join`, and `preload: [:project]`
raising here.

Going further, named not taught: `Ecto.Query.dynamic/2`; `update_all` per
decision 10; subqueries and `select_merge`; and `EXPLAIN` for when an index
would help.

HINTS: two drills, three hints each, hint 3 near-complete code. Slides: query as
a value; `from`/`where`/`order_by` and the pin; the join and its `on:`; bindings;
`select` shapes; composition; the security fix; closer pointing at lesson 32 —
associations, and the `preload` this lesson could not reach.

## Documentation amendments (separate PR, before the lesson branch)

The repo has no precedent for a lesson's own PR editing another lesson's shipped
prose or the master design, so these land first, on their own:

The master design carries **two** tables with rows 29–34 — the Phase 4
curriculum table and the lesson-by-lesson growth table — so every edit below
names its table. Missing the second one would leave the growth table still
promising preloads at 31, which is the exact claim decision 1 retires.

- **Curriculum table, row 31:** "Query DSL, joins, preloads, dynamic queries" →
  "Query DSL, joins, select shapes, composition, dynamic queries".
- **Growth table, row 31:** the "joins, preloads, dynamic queries" clause loses
  "preloads" the same way; the feature name is unchanged.
- **Curriculum table, row 32:** add `Project↔User` alongside `Issue↔Project`,
  giving the association an owner at last.
- **Growth table, row 32:** same addition, so the two tables agree.
- **Curriculum table, row 34:** add the generators (`phx.gen.html` /
  `phx.gen.context` / `phx.gen.live`), run against the app the learner built by
  hand — the promise has floated since the course design and now has a home.

The plan's self-review greps the master design for "preload" and confirms the
only surviving hits are lesson 32's.
- `tools/build_index/build_index.exs`: lesson 31's subtitle becomes
  "joins · composition · dynamic". **This is live on the published site.**
- `lessons/30-changesets-deep/slides/slides.md`: the closer's "Joins, preloads,
  composition" becomes "Joins, composition, dynamic queries".

## CI / tooling impact

- No new dependencies; no CI workflow change.
- `tools/lint-all`'s paren-free gate widens its glob to `lessons/31-*`. `from(`
  is already excluded by design — query code keeps its parens — and the token
  list needs no change.
- `tools/build_index` already lists lesson 31; the subtitle edit above is the
  only change.
- The plan's all-lessons-publish loop grows to 32 slugs.

## Risks

1. **The `Enum.filter` fake.** Mitigation: decision 9's `to_sql` assertion.
2. **Scope churn.** Changing two context arities touches four test files and two
   web call sites. Mitigation: decision 3 keeps the one colliding assertion
   intact; the plan's prototype confirms the rest before the branch exists.
3. **The lesson becoming an API catalogue.** A query lesson is the most prone in
   the course. Mitigation: every section answers a question Tracker actually has,
   and the Going-further list absorbs everything that does not.
4. **The provided page depending on drilled code.** Mitigation: the test-budget
   note above — its test is pending, and the plan verifies `exercises` is green
   before the drills.
5. **Lesson 32 will rewrite `/issues`.** Drill 1 returns bare maps from a
   `select`; lesson 32's payoff is `issue.project.name` via `belongs_to` and
   `preload`, so it will revisit this page. That is the intended arc — lesson 32
   replaces a hand-written join with a declaration — and its spec should say so
   rather than discover it.
6. **`user_token.ex` stays partly unreadable.** Lesson 30 closed out
   `Accounts.User` ("nothing in that file you cannot read"). Lesson 31 cannot
   make the same claim: `user_token.ex` joins with `assoc/2`, which needs lesson
   32. Accepted, and the Going-further section says which lesson finishes it.

## Open items for later specs

- Lesson 32 inherits: `Project↔User`, the `/issues` page's evolution from
  `select` maps to `preload`, and finishing `user_token.ex`.
- Lesson 33 still inherits the issue-title uniqueness constraint (lesson 30,
  Risk 6) and `update_all`.
- Lesson 34 inherits the generators.

## Success criteria

- Lesson `31-queries` exists with README, HINTS, slides, exercises, solutions.
- `GET /issues` lists the learner's open issues across projects with project
  names, filtered by `?status=`, built by a join and a composable filter.
- `get_project!/2`, `fetch_project/2` and `toggle_issue/2` are scoped; another
  user's project 404s, and a crafted toggle of another user's issue changes
  nothing.
- The carried board redirect assertion still passes unchanged.
- Every `solutions/` project passes `mix test --include pending` with zero
  failures; lesson 31's `exercises/` compiles warning-free under both flags,
  passes with pending excluded, and fails exactly its 9 drill tests.
- `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are green.
- After merge, the slide site publishes lesson 31.
