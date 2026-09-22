# Lesson 30 `changesets-deep` — Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-09-22
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Parent design:** [Elixir course design](2026-05-21-elixir-course-design.md)
**Predecessor:** [Lesson 29 schemas-and-migrations design](2026-09-18-lesson-29-schemas-and-migrations-design.md)

## Purpose

Lesson 29 gave Tracker real tables. Lesson 30 makes them refuse bad data.

The learner already has one validation — `validate_required/2`, carried from
lesson 24 — and no constraints at all. This lesson adds the rest of the story:
the schema type as the first line of defence (`Ecto.Enum`), the validation
catalog (`validate_length`), a validation they write themselves, and the two
constraint families that only the database can enforce (`unique_constraint`,
`foreign_key_constraint`).

The spine of the lesson is one sentence: **a validation runs in Elixir and can
only see this changeset; a constraint runs in Postgres and is the only thing
that can see other rows.**

## Scope

**In scope:** lesson 30 only (`30-changesets-deep`).

**Out of scope (later, separate specs):**
- The query DSL, joins, preloads, dynamic queries — lesson 31.
- `belongs_to` / `has_many` / `many_to_many`, `cast_assoc`, the `Comment`
  domain and assignees — lesson 32.
- `Ecto.Multi`, `Repo.transaction`, rollback patterns — lesson 33.
- Teaching `DataCase` / `ConnCase` / `LiveViewTest` properly, fixtures vs
  factories — lesson 34. Lesson 30 uses `errors_on/1` without ceremony.
- The two carried authorization gaps (`ProjectController.show/2` loads any
  project by id; the board's `toggle` accepts any issue id). Lesson 29 assigned
  them to lesson 31, where scoped queries make the fix natural. Lesson 30 adds
  nothing that makes them worse.
- `check_constraint/3`, `unsafe_validate_unique/4` and live validation
  (`phx-change`) — named in "Going further" with pointers, not taught.

By the end of lesson 30:
- `status` is an `Ecto.Enum` on both schemas, so an invalid status fails at cast
  time,
- both schemas own a public `changeset/2` containing every rule,
- `projects` and `issues` each have a unique index, declared in the changeset
  so a duplicate returns `{:error, changeset}` instead of raising,
- a bad `project_id` returns a changeset error instead of a `Postgrex.Error`,
  and
- the learner has written a validation of their own.

## Decisions locked during brainstorming

**1. Changeset functions move into the schema modules.** `Project.changeset/2`
and `Issue.changeset/2` become public, with `import Ecto.Changeset`; the
contexts become thin callers. Every public context signature is unchanged —
including the **zero-arity** `change_project()` / `change_issue()` forms the
controller and the LiveView actually call, which the default argument provides.
Rationale: the master design's growth row for lesson 30 says "custom changeset
functions"; the schema files are currently bodies-only, so this gives the lesson
a reason to touch them without moving the web layer; and it decodes
`Tracker.Accounts.User`, which has had public changesets in the schema module
since lesson 26 with no explanation. Lesson 32's `cast_assoc` will want this
shape too.

**2. `status` becomes a string-backed `Ecto.Enum` on both schemas.**
`field :status, Ecto.Enum, values: [:open, :closed], default: :open`. No
migration: a string-backed enum keeps the existing `:string` column with its
`null: false` and its database default. Provided on Project, drilled on Issue.
This redeems three shipped promises (lesson 29's README twice and its closing
slide).

Measured blast radius — **breaks:** `flip/1`'s two string clauses,
`Changeset.change(status: ...)` in `toggle_issue/1`, and three assertions in
`issues_test.exs`. **Survives unchanged:** the LiveView assertions (text matches
on rendered HTML; atoms render as their text), the raw-SQL assertion in
`issues_table_test.exs` (a string-backed enum still stores `"open"`), and all
three templates.

**Do not pair the enum with `validate_inclusion(:status, ...)`.** It would be
dead code: a failed enum cast records no change, and `validate_change/4` only
runs when a change exists. The enum's own cast error already carries
`validation: :inclusion` metadata. A half-finished enum always *raises*
(`Ecto.ChangeError` on dump, because `Ecto.Enum.dump/3` matches only the atom
keys) — it never silently misbehaves, and the prose must not claim otherwise.

**3. Two new unique indexes: projects provided, issues drilled.**
`create unique_index(:projects, [:user_id, :name])` with
`unique_constraint([:user_id, :name], error_key: :name)` in
`Project.changeset/2`; `create unique_index(:issues, [:project_id, :title])`
with `unique_constraint([:project_id, :title], error_key: :title)` in
`Issue.changeset/2`. Scoped per user and per project, not global.

**The field list does two jobs, and `:error_key` is not optional here.**
- It derives the index name: Ecto builds `projects_user_id_name_index` from the
  changeset side and ecto_sql builds the same string from the migration side, so
  no `:name` option is needed — provided the column order matches. Write the
  columns in the same order in both places.
- It also decides which field the error lands on, and Ecto takes the **first**
  element of the list. Without `:error_key`, a duplicate name would attach
  `"has already been taken"` to `:user_id` and a duplicate title to
  `:project_id` — neither of which has an input on any form, so `<.input>` would
  render nothing and the user would see the form silently redisplay. That is the
  exact silent failure this lesson exists to remove, so both declarations pass
  `:error_key` and the README says why.

**4. `foreign_key_constraint(:project_id)` in `Issue.changeset/2`.** No
migration needed — the foreign key exists from lesson 29 and the inferred name
`issues_project_id_fkey` matches Postgres's own default from `references/2`.
Tested at the context level with a bogus id; the prose says plainly that this
particular error is invisible in the browser (see decision 7).

**5. The validations Tracker gains.** `validate_length(:name, min: 2, max: 80)`
on Project, `validate_length(:title, max: 120)` on Issue. **No `min` on
`:title`** — two carried tests create issues called "A" and "B".

Length is chosen because it is the only validation whose message carries
`%{count}`, which makes the `{msg, opts}` error shape visible. Ecto stores the
message uninterpolated and **two independent consumers** interpolate it — they
are not a chain, and the prose must not present them as one:
- the test path: `errors_on/1` does its own `Regex.replace` over `opts` and
  returns; it never touches Gettext and never reads the `.po` file;
- the browser path: `<.input>` → `translate_error/1` → `Gettext.dngettext` →
  the msgids in `priv/gettext/en/LC_MESSAGES/errors.po`.

**6. The custom validation is a named private function wrapping
`validate_change/3`.** `defp validate_name(changeset)` (and `validate_title/1`
for the drill) is a `validate_change(:name, fn :name, name -> ... end)` wrapper
rejecting a value with no letter or digit, piped in as `|> validate_name()`.

**The trim is a separate, earlier step: `update_change(:name, &String.trim/1)`
immediately after `cast/4`, before `validate_required` and `validate_length`.**
Order matters and the spec pins it: `update_change/3` rewrites the change that
later steps read, so a trim placed after `validate_length` would measure the raw
string and store the trimmed one — `" A "` would pass `min: 2` and be stored as
a one-character name, and an 80-character name with a trailing space would be
rejected even though the stored value fits. Normalize, then measure.

These are not alternatives — `validate_change/3` is the primitive, the named
function is the composition unit, and saying so is the lesson's payoff line: a
validation is just `changeset -> changeset`, which is why `|>` composes yours
with Ecto's. `User.validate_email_changed/1` is the in-tree precedent, in the
`get_field/2` + `add_error/3` spelling; one slide can show both.

The trim is load-bearing, not decorative: `cast/4`'s empty-value handling
decides *emptiness* only and stores the original string, so without the trim
`"Apollo"` and `"Apollo "` are two different rows that both satisfy the new
unique index.

**7. Exactly one web-layer line changes.** `new.html.heex`'s free-text status
input becomes
`<.input field={@form[:status]} type="select" prompt="Choose a status" options={Ecto.Enum.values(Tracker.Projects.Project, :status)} label="Status" />`.

**The module must be spelled out.** The template compiles into
`TrackerWeb.ProjectHTML`, which has no alias for the schema, so a bare `Project`
is just the atom `Elixir.Project`. In argument position there is no remote call
for the compiler to check, so it compiles clean — no warning, green even under
`--warnings-as-errors` — and fails at **render** time instead, when
`Ecto.Enum.values/2` reaches for that module's schema reflection. Expect a 500
on `GET /projects/new`, not a build error. Spelling the module out keeps the
diff to one file; an alias in `project_html.ex` would make it two.

**The `prompt` is required, not decoration.** `<.input type="select">` renders a
blank `<option>` only when `:prompt` is given. Without it the select offers only
`open` and `closed`, one always selected, so a blank status is unreachable from
the browser — and the README paragraph about what `cast/4` does with a blank
value would describe a path the learner cannot exercise.

`core_components.ex` is **not** touched: the `type="select"` clause and every
error-rendering path already exist. Lesson 29 sold "the web layer didn't
change"; lesson 30 breaks that streak by one line, and the prose says so rather
than letting it lapse quietly.

**8. `toggle_issue/1` keeps `Changeset.change/2`.** It is an internal flip of a
value the app controls, not user input, so it does not go through
`Issue.changeset/2`. The README says this explicitly, because a learner who adds
a validation and then toggles will otherwise assume it was enforced. Note what
`change/2` does **not** do: it neither casts nor validates — it only asks
`Ecto.Type.equal?` whether each value differs from the struct's and stores what
it is given. A leftover `Changeset.change(issue, status: "closed")` therefore
returns `valid?: true` with no errors; the failure comes one layer later, as an
`Ecto.ChangeError` from `Repo.update!` when `Ecto.Enum.dump/3` refuses the
string. Still loud, but the prose must put the raise in the right place — and
this is the sentence the README repeats.

**9. Error assertions arrive via `errors_on/1`.** It already exists in
`test/support/data_case.ex` and is imported by `Tracker.DataCase`, but no
Tracker test uses it — the carried assertions are `refute changeset.valid?`,
which cannot tell one failure from another. Lesson 30 uses `errors_on/1` in the
new test file and in the drill assertions, and **leaves the carried
`refute valid?` lines alone**. Common mistakes notes that a `%{key}` whose atom
does not already exist in the VM makes the helper's `String.to_existing_atom/1`
raise.

**10. The new test file is `test/tracker/issue_changeset_test.exs`,** provided,
in lesson 29's `issues_table_test.exs` idiom: one check per `test` block,
asserting the specific field and message, plus **one raw `pg_indexes`
assertion** that `issues_project_id_title_index` exists.

That last assertion is load-bearing, but not for the reason it first appears.
With the index missing, `Repo.insert/1` **succeeds** — constraints are consulted
only when the adapter reports a violation — so the duplicate-title test goes
red, not green. The failure the `pg_indexes` check actually defends against is a
learner satisfying `{:error, changeset}` from Elixir alone, with
`unsafe_validate_unique/4` and no index: the tests pass, and duplicates still
land in the database the moment two requests race. The same asymmetry is the
README's point — a declaration with no index behind it enforces nothing.

## Conventions & mechanics

### Versions

- Pinned toolchain: Elixir 1.19.5-otp-28 / Erlang 29.0.1. **Install with
  `mise install` and run every command as `mise x -- mix ...`** — `mix` on PATH
  is Homebrew's 1.20.x, and mise's shims are not on PATH in non-interactive
  shells. The same applies to `make`, because no `tools/*` script wraps its
  internal `mix` calls.
- Phoenix 1.8.7, `phoenix_live_view` 1.1.30, `ecto` 3.14.0, `ecto_sql` 3.14.0,
  `postgrex` 0.22.2, `phoenix_ecto` 4.7.0. **No new Hex dependencies.**
- Postgres 16.

### Threading from lesson 29

- `30-changesets-deep/solutions/` is a full copy of lesson 29's `solutions/`
  plus this lesson's changes; `exercises/` is derived from the finished
  solution.
- **Rename the databases** to `tracker_30_solutions_{test,dev}` and
  `tracker_30_exercises_{test,dev}` in each folder's `config/test.exs` and
  `config/dev.exs`. This is the rule lesson 29 introduced, and lesson 30 is the
  first lesson to inherit rather than introduce it; forgetting it silently
  shares lesson 29's data.
- Lesson 29's three migrations are carried unchanged and **never edited**. The
  two new migrations are generated with `mix ecto.gen.migration`, in
  `solutions/`, and the projects one is copied byte-for-byte into `exercises/`;
  the issues one does not ship in `exercises/` at all.
- New migrations are **format-gated**: each project's `.formatter.exs` declares
  `subdirectories: ["priv/*/migrations"]`, and the nested
  `priv/repo/migrations/.formatter.exs` formats them. A hand-written migration
  that is not `mix format`-clean fails `make lint`.
- Paren-free DSL in `lib/` and migrations, as lesson 29 established.

### The projects side (provided)

`Tracker.Projects.Project` gains `import Ecto.Changeset`, the enum field, and:

```elixir
def changeset(project, attrs) do
  project
  |> cast(attrs, [:name, :status])
  |> update_change(:name, &String.trim/1)
  |> validate_required([:name])
  |> validate_length(:name, min: 2, max: 80)
  |> validate_name()
  |> unique_constraint([:user_id, :name], error_key: :name)
end
```

`Tracker.Projects` keeps all four public functions and becomes a thin caller.

### The drills (`@tag :pending`)

**Drill 1 — `Issue.changeset/2`.** Move the changeset out of the context into
the schema module; make `status` an `Ecto.Enum` and start casting it (today
`Issues` does not cast `:status` at all); add `validate_length(:title, max: 120)`
and a custom `validate_title/1`; follow through on `flip/1` and `toggle_issue/1`
for atoms.

**Drill 2 — Issue constraints.** A new migration adding
`unique_index(:issues, [:project_id, :title])`, plus
`unique_constraint([:project_id, :title], error_key: :title)` and
`foreign_key_constraint(:project_id)` in `Issue.changeset/2`. Drill 1's title
pipeline mirrors the provided one: trim first, then measure.

Pending tests: **9** — seven in the new changeset test file and two carried
`issues_test.exs` assertions that now expect atoms. (The brainstorm targeted
6–8; the prototype settled on 9, one below lesson 29's 10, and Plan J tabulates
each failure reason.)

Note that lesson 29's stub hazard is largely **moot** here: both drills deepen
code that already compiles and works, so there is no `raise`-shaped stub and no
unmatched consumer clause. The exercise still must compile warning-free, and any
stub that does appear follows the typed-placeholder convention.

### Testing

- `Tracker.DataCase` for the context and changeset tests, `TrackerWeb.ConnCase`
  for the controller and LiveView, all `async: true` as lesson 29 left them.
- The carried `pg_indexes` assertion in `issues_table_test.exs` tests
  **membership**, not list equality, so the new issues index does not break it.
  Record this so nobody "fixes" that test.
- Fixture safety was checked against the new unique indexes: every carried test
  that creates two projects either uses distinct names or a fresh user per
  project, and no carried test creates two issues with the same title in one
  project. The board test's helper hardcodes the name "Apollo" but creates one
  project per test. **The plan's prototype re-verifies this** before the
  migrations land.
- **The zero-warnings check needs two flags, covering disjoint files.**
  `mix compile --warnings-as-errors` covers `lib/` and `test/support/` only, so
  warnings in a `_test.exs` file — an unused alias in the new test file being
  the likeliest — slip through. Run
  `mise x -- env MIX_ENV=test mix do compile --force --warnings-as-errors + test --warnings-as-errors`
  in each folder. `mix precommit` alone is NOT sufficient, and **CI enforces
  neither** — it runs the make targets only — so the plan checks this by hand.
- CI order is exercises first (`make test`), then solutions
  (`make solutions-test`). With per-lesson databases neither can mask the other.

### Prose

README (~60–70 lines, lesson 29's shape). Key ideas must carry three things a
beginner cannot deduce:

1. **A constraint error never appears at `changeset.valid?` time.** `Repo.insert`
   on an invalid changeset issues no SQL at all, so a validation error and a
   constraint error can never arrive together. Everything lessons 24, 25 and 29
   taught branches on `valid?`; this needs its own paragraph and a callout.
2. **The changeset helper enforces nothing — it translates.** Without
   `unique_constraint/3`, a duplicate raises `Ecto.ConstraintError`, whose
   message names the constraint and the helper to call. With it, you get
   `{:error, changeset}`. And the inverse: declaring a constraint whose index
   does not exist is silent, so a missing migration is a data bug, not an error.
3. **`NOT NULL` is the exception.** SQLSTATE 23502 has no entry in the
   Postgres→Ecto constraint mapping, so it re-raises a `Postgrex.Error` — which
   is exactly what the carried `issues_table_test.exs` already asserts. Any "the
   database is the last line of defence" narrative must say that unique and
   foreign-key violations become changeset errors once declared, while NOT NULL
   raises.

Also required: a blank select never reaches the enum (`cast/4` substitutes the
schema default for an empty value and records no change, so it saves as
`"open"`); the `foreign_key_constraint` error is invisible in the browser
because there is no `project_id` input and `<.input>` only renders errors for
fields present in the submitted params; and why `toggle_issue/1` skips the
changeset.

Accuracy note for the prose: lesson 30 is **not** the app's first validation or
constraint. `Tracker.Accounts.User` has shipped `validate_format`,
`validate_length`, `validate_confirmation` and `unsafe_validate_unique` since
lesson 26. Lesson 30 is the first the *learner* writes — and "go read
`Accounts.User` now that you can parse every line of it" is the Going-further
item that closes that loop.

Going further, named with pointers, not taught: `check_constraint/3` (the only
constraint with no inferred name — a missing `:name` raises `ArgumentError` when
the changeset is *built*, breaking even the empty form), `unsafe_validate_unique/4`
(already in `accounts/user.ex`), and `phx-change="validate"` with
`apply_action(changeset, :validate)` for live validation.

HINTS: two drills, three hints each, hint 3 being full code. Slides: the
changeset move, the enum and the select, `validate_length` and the message path,
the custom validation in both spellings, the migration-plus-declaration round
trip, and the validation-versus-constraint contrast. Closer: "Next: lesson 31 —
queries".

## CI / tooling impact

- No new dependencies. `tools/build_index` already lists lesson 30, so it
  publishes as soon as `slides/` exists.
- The `mix test` alias creates and migrates whatever database name the config
  names, so the `tracker_30_*` rename needs no tooling change.
- Lesson 30 makes the ninth Phoenix+Ecto project pair (lessons 22–30), each
  compiled from scratch in CI with no `_build` cache.
- The plan's all-lessons-publish loop grows to 31 slugs.

**A separate chore PR lands before the lesson 30 branch** (not inside it, so the
lesson diff stays about the lesson):
- `CONTRIBUTING.md` still tells authors to stub with `raise "TODO: implement
  this"`, which fails the build under Elixir 1.19's type checker for any stub a
  provided caller consumes. Correct it to the typed-placeholder convention,
  noting the `raise` form is still right for the pre-Phoenix lessons 1–20.
- `CONTRIBUTING.md` also still prescribes `Note:` speaker-note blocks; no lesson
  since 20 uses them.
- Add a grep gate to `tools/lint-all` for parenthesized Phoenix/Ecto DSL calls,
  so the paren-free rule is enforced rather than remembered. **It must ship
  green, which constrains its scope in three ways:**
  - **Glob:** `lessons/{29-*,30-*}/{exercises,solutions}/{lib,priv/repo/migrations}`
    only. Repo-wide it would fail immediately — 257 parenthesized DSL lines
    already exist under earlier lessons' `lib/`. The spec states that the glob
    widens as each earlier lesson is normalized; nobody is obliged to normalize
    them now.
  - **Lesson 21 must stay excluded permanently unless it gains `import_deps`:**
    its project has no Ecto/Phoenix deps imported into the formatter, so
    `mix format` *adds* the parens the gate would forbid. The gate and the
    formatter check run in the same loop, so that combination is unsatisfiable.
  - **Token list:** statement-position `plug`, `socket`, `field`, `add`,
    `timestamps`, `execute`, `attr`, `slot`, `pipe_through`, `resources`,
    `create`, `embeds_one`, `embeds_many`, `belongs_to`, `has_many`, `has_one`,
    `many_to_many`. **Exclude `from`** — 19 legitimate expression-position
    `from(` calls live in lessons 28–29 — and keep `test/` out, where
    `get(conn, …)`, `post(conn, …)` and `live(conn, …)` are ordinary function
    calls. Migrations are in scope precisely because lesson 30 ships two.

## Risks

1. **Scope.** Six topics were deferred here by name and lesson 30 has two drill
   slots. Mitigation: decision 10's Going-further list is the release valve, and
   the pending-test target is 6–8, below lesson 29's 10.
2. **A half-finished enum.** If `status` becomes an enum but `flip/1` keeps its
   string clauses, `Repo.update!` raises `Ecto.ChangeError`. This is loud, not
   silent — but the carried LiveView assertions will not catch it, because they
   are text matches on rendered HTML. Mitigation: a drill test that toggles and
   asserts the atom.
3. **Constraint-name mismatch.** `unique_constraint(:name)` would infer
   `projects_name_index` while the migration produces
   `projects_user_id_name_index`, and the mismatch only surfaces as a raised
   `Ecto.ConstraintError` when a duplicate is attempted. Mitigation: the list
   form in the same column order as the index, stated in decision 3 and checked
   by the prototype.
4. **A constraint drill is easy to fake — from Elixir.** A learner can satisfy
   `{:error, changeset}` with `unsafe_validate_unique/4` and never write the
   index, leaving the race wide open. Mitigation: decision 10's `pg_indexes`
   assertion, which no Elixir-side change can satisfy. (A *missing* index does
   not hide: the duplicate test simply goes red.)
5. **Retroactive validations breaking carried fixtures.** Mitigation: the bounds
   in decision 5 were chosen against the actual fixture strings, and the
   prototype re-verifies both folders.
6. **Lesson 33 inherits a constraint.** `unique_index(:issues, [:project_id,
   :title])` makes "move issue between projects" fail when the destination
   already holds an issue with that title. This is honest domain behaviour, not
   a defect; lesson 33's spec must handle it, and this spec records it.
7. **The lesson becoming an API catalog.** A validation list is the easiest
   topic in the course to render as a reference table. Mitigation: the house
   voice explains *why* — why a validation cannot see other rows, why a blank
   select is not an error, why the trim matters for the unique index.

## Open items for later specs

- Lesson 31 must pick up the two authorization gaps lesson 29 recorded.
- Lesson 31's row lists preloads, which need lesson 32's associations; the
  ordering still needs resolving.
- No lesson owns the Project↔User association from the master data model.
- The generators (`phx.gen.html` / `phx.gen.context` / `phx.gen.live`) are
  promised as "taught explicitly" and still have no home.
- Lesson 33 inherits the issue-title uniqueness constraint (Risk 6).

## Success criteria

- Lesson `30-changesets-deep` exists with README, HINTS, slides, exercises,
  solutions.
- Both schemas own a public `changeset/2`; both contexts keep every lesson 29
  signature, zero-arity forms included.
- `status` is an `Ecto.Enum` on both schemas; the project form is a select.
- A duplicate project name for the same user, and a duplicate issue title in the
  same project, each return `{:error, changeset}`; a bogus `project_id` returns
  a changeset error rather than raising.
- Every `solutions/` project passes `mix test --include pending` with zero
  failures, and lesson 30's two folders are warning-free under BOTH
  `compile --warnings-as-errors` and `test --warnings-as-errors`; the
  `exercises/` folder compiles warning-free,
  passes with pending excluded, and fails exactly its drill tests — against its
  own `tracker_30_exercises_test` database.
- `make ci-smoke`, `make lint`, `make test`, `make solutions-test`,
  `make slides-build` are green.
- After merge, the slide site publishes lesson 30.
