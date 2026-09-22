# Plan J — Lesson 30 (`changesets-deep`: validations and constraints) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author lesson `30-changesets-deep`: Tracker's schemas learn to refuse bad data — `Ecto.Enum` on `status`, `validate_length`, a validation the learner writes, and the two constraint families only Postgres can enforce.

**Architecture:** Thread Tracker from lesson 29's solution. Both changeset builders move out of the contexts into public `Project.changeset/2` and `Issue.changeset/2`, so every public context signature — zero-arity forms included — is untouched. Projects is the provided worked example (enum, validations, custom validation, a new unique index); issues is drilled in two parts: the changeset (Drill 1) and the constraints plus their migration (Drill 2). One web-layer line changes: the project form's status input becomes a select.

**Tech Stack:** Elixir 1.19.5-otp-28 / OTP 29.0.1; Phoenix 1.8.7; `ecto` 3.14.0, `ecto_sql` 3.14.0, `postgrex` 0.22.2, `phoenix_ecto` 4.7.0; Postgres 16. No new Hex deps.

**Spec:** `docs/superpowers/specs/2026-09-22-lesson-30-changesets-deep-design.md`.

**This plan was prototyped end-to-end under the pinned toolchain against a real Postgres before being written.** Solution: **126 tests / 0 failures**. Exercise: **117 / 0 with 9 excluded**, and exactly those **9** failing under `--include pending`, each for its own reason. Both folders are warning-free under `compile --warnings-as-errors` **and** `test --warnings-as-errors`. Every code block below is verified prototype output and `mix format`-clean.

**Three things the prototype pinned down — do not re-derive them:**

- **`unique_constraint` needs `error_key`.** Verified by removing it: the duplicate-title error arrives as `%{project_id: ["has already been taken"]}`, on a field with no form input, so the browser shows nothing. With `error_key: :title` it lands where the learner typed.
- **The trim must run before `validate_length`.** `update_change/3` rewrites the change later steps read, so a trim placed after the length check measures the raw string and stores the trimmed one.
- **The pending count is 9, not the spec's 6–8 target.** The spec is refined by this plan (Task 1 Step 11 records the exact split). 9 is one below lesson 29's 10.

## Global Constraints

- Pinned toolchain: Elixir 1.19.5-otp-28, Erlang 29.0.1. Install with `mise install`; run **every** `mix` and `make` command as `mise x -- ...`. No `tools/*` script wraps its own `mix` calls, and bare `mix` is Homebrew's 1.20.
- No new Hex dependencies. `mix.lock` unchanged from lesson 29's.
- Public context API unchanged from lesson 29: `list_projects(scope)`, `get_project!(id)`, `change_project(attrs \\ %{})`, `create_project(scope, attrs)`, `list_issues(project_id)`, `change_issue(attrs \\ %{})`, `create_issue(project_id, attrs)`, `toggle_issue(id)`. The zero-arity `change_project()` / `change_issue()` forms are what the controller and LiveView call — the default argument must survive.
- Never `cast` `user_id` or `project_id`; set them on the struct.
- Paren-free DSL in `lib/` and migrations. `tools/lint-all` gates this for lessons 29–30 once PR #11 merges.
- Databases: `tracker_30_solutions_{test,dev}` and `tracker_30_exercises_{test,dev}`.
- Lesson 29's three migrations are carried unchanged and never edited.

---

## Conventions (read once, apply throughout)

### Repo-root rule
`tools/*` and `make` run from `/Users/ristkari/code/private/elixir-training`. Per-lesson `mix` runs inside `lessons/30-changesets-deep/{exercises,solutions}`.

### Local Postgres (required)

```bash
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
```

### Dependency on PR #11
PR #11 (`chore/contributing-and-lint-gate`) adds the paren-free lint gate scoped to lessons 29–30. If it has merged, rebase this branch on `main` before Task 4's smoke run so `make lint` exercises the gate. If it has not, proceed — the gate is additive and lesson 30's code is already paren-free.

### `deps/`
Do **not** re-fetch dependencies from scratch: `:heroicons` is a git dependency over SSH with no usable key in this sandbox. Copy `deps/` from lesson 29's solution along with the rest of the tree. `deps/` is gitignored.

### Commit style
GPG signing is automatic but the agent cannot answer a pinentry prompt. Check first with `echo test | gpg --clearsign >/dev/null 2>&1 && echo UNLOCKED`. If locked, **stop and report BLOCKED** with the commit message written to a file — never disable signing. Use the session's own `Co-Authored-By` trailer.

### Build order
Task 1 solution → Task 2 exercise → Task 3 prose → Task 4 smoke + PR.

---

## Task 1: Lesson 30 solution — schemas that refuse bad data

**Files:**
- Create: `lessons/30-changesets-deep/` (scaffold), then `solutions/` as a copy of lesson 29's
- Create: `solutions/priv/repo/migrations/<ts1>_add_unique_project_name_index.exs`, `<ts2>_add_unique_issue_title_index.exs`
- Create: `solutions/test/tracker/issue_changeset_test.exs`
- Modify: `solutions/lib/tracker/projects/project.ex`, `issues/issue.ex`, `lib/tracker/projects.ex`, `lib/tracker/issues.ex`, `config/{test,dev}.exs`, `lib/tracker_web/controllers/project_html/new.html.heex`, `test/tracker/issues_test.exs`

**Interfaces:**
- Produces: public `Tracker.Projects.Project.changeset/2` and `Tracker.Issues.Issue.changeset/2`; `status` as `Ecto.Enum` (`:open` / `:closed`) on both schemas; the eight context functions unchanged in name, arity and return shape.
- Consumes: lesson 29's controller, LiveView, router and templates — unchanged except the one status input.

- [ ] **Step 1: Toolchain, Postgres, scaffold and thread**

```bash
cd /Users/ristkari/code/private/elixir-training
mise install
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done

git checkout -b plan-j-lesson-30
tools/new-lesson 30-changesets-deep
rm -rf lessons/30-changesets-deep/exercises lessons/30-changesets-deep/solutions
cp -R lessons/29-schemas-and-migrations/solutions lessons/30-changesets-deep/solutions
rm -rf lessons/30-changesets-deep/solutions/_build
```

Keep `deps/`. `exercises/` stays absent until Task 2.

- [ ] **Step 2: Point the solution at its own databases**

```bash
cd lessons/30-changesets-deep/solutions
sed -i '' 's/tracker_29_solutions_test/tracker_30_solutions_test/; s/tracker_29_solutions_dev/tracker_30_solutions_dev/' config/test.exs config/dev.exs
grep -n 'database:' config/test.exs config/dev.exs
```

Expected: `tracker_30_solutions_test#{...}` and `tracker_30_solutions_dev`.

- [ ] **Step 3: Generate both migrations, in order**

```bash
mise x -- mix ecto.gen.migration add_unique_project_name_index
sleep 1
mise x -- mix ecto.gen.migration add_unique_issue_title_index
ls priv/repo/migrations
```

Expected five files: lesson 29's three, then these two. The issue-title one must carry the later timestamp.

- [ ] **Step 4: Write the two migration bodies**

`<ts1>_add_unique_project_name_index.exs`:

```elixir
defmodule Tracker.Repo.Migrations.AddUniqueProjectNameIndex do
  use Ecto.Migration

  def change do
    create unique_index(:projects, [:user_id, :name])
  end
end
```

`<ts2>_add_unique_issue_title_index.exs`:

```elixir
defmodule Tracker.Repo.Migrations.AddUniqueIssueTitleIndex do
  use Ecto.Migration

  def change do
    create unique_index(:issues, [:project_id, :title])
  end
end
```

The column order is load-bearing: it is what makes the derived index names (`projects_user_id_name_index`, `issues_project_id_title_index`) match what the changeset side infers.

- [ ] **Step 5: Rewrite the Project schema (the worked example)**

`lib/tracker/projects/project.ex` (whole file):

```elixir
defmodule Tracker.Projects.Project do
  @moduledoc "A project row, and the rules a project has to satisfy."
  use Ecto.Schema
  import Ecto.Changeset

  schema "projects" do
    field :name, :string
    field :status, Ecto.Enum, values: [:open, :closed], default: :open
    field :user_id, :id

    timestamps type: :utc_datetime
  end

  def changeset(project, attrs) do
    project
    |> cast(attrs, [:name, :status])
    |> update_change(:name, &String.trim/1)
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 80)
    |> validate_name()
    |> unique_constraint([:user_id, :name], error_key: :name)
  end

  # A validation is just changeset -> changeset, so `|>` composes ours with
  # Ecto's. validate_change/3 is the primitive underneath.
  defp validate_name(changeset) do
    validate_change(changeset, :name, fn :name, name ->
      if String.match?(name, ~r/[[:alnum:]]/),
        do: [],
        else: [name: "needs at least one letter or number"]
    end)
  end
end
```

`update_change` sits **before** `validate_length` deliberately: it rewrites the change the later steps read, so trimming afterwards would measure one string and store another.

- [ ] **Step 6: Make the Projects context a thin caller**

`lib/tracker/projects.ex` — replace the private `changeset/2` and its two callers:

```elixir
  def change_project(attrs \\ %{}), do: Project.changeset(%Project{}, attrs)

  def create_project(scope, attrs) do
    %Project{user_id: scope.user.id}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end
```

Drop the now-unused `alias Ecto.Changeset` and the private `changeset/2`. `list_projects/1` and `get_project!/1` are unchanged. Leaving a stale alias behind fails `--warnings-as-errors`.

- [ ] **Step 7: Rewrite the Issue schema and context (what Task 2 will withhold)**

`lib/tracker/issues/issue.ex` (whole file):

```elixir
defmodule Tracker.Issues.Issue do
  @moduledoc "An issue row, and the rules an issue has to satisfy."
  use Ecto.Schema
  import Ecto.Changeset

  schema "issues" do
    field :title, :string
    field :status, Ecto.Enum, values: [:open, :closed], default: :open
    field :project_id, :id

    timestamps type: :utc_datetime
  end

  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :status])
    |> update_change(:title, &String.trim/1)
    |> validate_required([:title])
    |> validate_length(:title, max: 120)
    |> validate_title()
    |> unique_constraint([:project_id, :title], error_key: :title)
    |> foreign_key_constraint(:project_id)
  end

  defp validate_title(changeset) do
    validate_change(changeset, :title, fn :title, title ->
      if String.match?(title, ~r/[[:alnum:]]/),
        do: [],
        else: [title: "needs at least one letter or number"]
    end)
  end
end
```

`lib/tracker/issues.ex` (whole file):

```elixir
defmodule Tracker.Issues do
  @moduledoc "The Issues context: the boundary for issue business logic."
  import Ecto.Query

  alias Ecto.Changeset
  alias Tracker.Issues.Issue
  alias Tracker.Repo

  def list_issues(project_id) do
    # Query syntax is lesson 31. Read it as: this project's rows, oldest first.
    from(i in Issue, where: i.project_id == ^project_id, order_by: [asc: i.id])
    |> Repo.all()
  end

  def change_issue(attrs \\ %{}), do: Issue.changeset(%Issue{}, attrs)

  def create_issue(project_id, attrs) do
    %Issue{project_id: project_id}
    |> Issue.changeset(attrs)
    |> Repo.insert()
  end

  # Not user input: an internal flip of a value we control, so it skips
  # Issue.changeset/2 and every validation in it.
  def toggle_issue(id) do
    issue = Repo.get!(Issue, id)

    issue
    |> Changeset.change(status: flip(issue.status))
    |> Repo.update!()
  end

  defp flip(:open), do: :closed
  defp flip(_), do: :open
end
```

Note `flip/1` now matches **atoms**. `Changeset.change/2` neither casts nor validates — a leftover `"closed"` string would build a valid-looking changeset and raise `Ecto.ChangeError` from `Repo.update!` at dump time.

- [ ] **Step 8: Change the one web-layer line**

In `lib/tracker_web/controllers/project_html/new.html.heex`, replace the status input:

```heex
    <.input
      field={@form[:status]}
      type="select"
      prompt="Choose a status"
      options={Ecto.Enum.values(Tracker.Projects.Project, :status)}
      label="Status"
    />
```

Two things are deliberate. The module is spelled out because `ProjectHTML` has no alias for it — a bare `Project` compiles clean (it is just an atom in argument position) and 500s at render time. The `prompt` is what makes a blank status reachable at all; without it the select always has a value selected.

- [ ] **Step 9: Update the carried issue tests for atoms**

In `test/tracker/issues_test.exs`, three assertions change:

```elixir
    assert issue.status == :open
```

```elixir
    assert Issues.toggle_issue(issue.id).status == :closed
    assert Issues.toggle_issue(issue.id).status == :open
```

Nothing else in the carried suites changes: the LiveView assertions are text matches on rendered HTML (atoms render as their text), and `issues_table_test.exs`'s raw SQL still sees the string `"open"` because a string-backed enum stores strings. Its `pg_indexes` assertion tests **membership**, so the new index does not break it.

- [ ] **Step 10: Add the new test file**

Create `test/tracker/issue_changeset_test.exs`:

```elixir
defmodule Tracker.IssueChangesetTest do
  # Every rule an issue has to satisfy, and where each one is enforced.
  # One check per test: a rejected statement rolls back to its savepoint,
  # and mixing two checks in one test muddies which one failed.
  use Tracker.DataCase, async: true

  alias Tracker.Issues
  alias Tracker.Accounts.Scope
  alias Tracker.Repo
  import Tracker.AccountsFixtures

  defp project do
    scope = Scope.for_user(user_fixture())
    {:ok, project} = Tracker.Projects.create_project(scope, %{"name" => "Apollo"})
    project
  end

  # --- validations: Elixir side, before any SQL runs ---

  test "a title longer than 120 characters is rejected" do
    long = String.duplicate("x", 121)
    assert {:error, changeset} = Issues.create_issue(project().id, %{"title" => long})
    assert errors_on(changeset).title == ["should be at most 120 character(s)"]
  end

  test "a title with no letter or number is rejected" do
    assert {:error, changeset} = Issues.create_issue(project().id, %{"title" => "!!!"})
    assert errors_on(changeset).title == ["needs at least one letter or number"]
  end

  test "surrounding whitespace is trimmed before the rules run" do
    assert {:ok, issue} = Issues.create_issue(project().id, %{"title" => "  Fix login  "})
    assert issue.title == "Fix login"
  end

  test "a status outside the enum is rejected at cast time" do
    changeset = Issues.change_issue(%{"title" => "Fine", "status" => "sideways"})
    refute changeset.valid?
    assert errors_on(changeset).status == ["is invalid"]
  end

  # --- constraints: Postgres side, only after every validation passes ---

  test "a duplicate title in the same project is rejected" do
    project = project()
    {:ok, _} = Issues.create_issue(project.id, %{"title" => "Fix login"})

    assert {:error, changeset} = Issues.create_issue(project.id, %{"title" => "Fix login"})
    assert errors_on(changeset).title == ["has already been taken"]
  end

  test "the same title in a different project is fine" do
    {:ok, _} = Issues.create_issue(project().id, %{"title" => "Fix login"})
    assert {:ok, _} = Issues.create_issue(project().id, %{"title" => "Fix login"})
  end

  test "an issue for a project that does not exist is rejected" do
    assert {:error, changeset} = Issues.create_issue(999_999, %{"title" => "Orphan"})
    assert errors_on(changeset).project_id == ["does not exist"]
  end

  test "the unique index really exists in the database" do
    %{rows: rows} = Repo.query!("SELECT indexname FROM pg_indexes WHERE tablename = 'issues'")
    assert ["issues_project_id_title_index"] in rows
  end
end
```

- [ ] **Step 11: Format and verify the solution**

```bash
mise x -- mix format
mise x -- mix format --check-formatted
mise x -- env MIX_ENV=test mix do compile --force --warnings-as-errors + test --warnings-as-errors 2>&1 | tail -n 3
```

Expected: format clean, no warnings, **`126 tests, 0 failures`**. Both flags are needed and cover disjoint files — `compile --warnings-as-errors` never sees `*_test.exs`.

- [ ] **Step 12: Commit the solution**

```bash
cd /Users/ristkari/code/private/elixir-training
git add lessons/30-changesets-deep
git commit -F - <<'EOF'
Add lesson 30-changesets-deep solution: schemas that refuse bad data

Both changeset builders move out of the contexts into public
Project.changeset/2 and Issue.changeset/2, so every context signature —
zero-arity forms included — is untouched and the web layer moves by one
line: the project form's status input becomes a select.

status is an Ecto.Enum on both schemas, so a bad value fails at cast
time. Two new unique indexes, declared with error_key so the error lands
on the field the form actually shows. foreign_key_constraint turns a
bogus project_id from a raised Ecto.ConstraintError into a changeset
error. The trim runs before validate_length: update_change rewrites the
change later steps read, so trimming after would measure one string and
store another.

Solution green against Postgres: 126 tests, 0 failures.
EOF
```

---

## Task 2: Lesson 30 exercise — derive and withhold the issues side

**Files:**
- Create: `lessons/30-changesets-deep/exercises/` (copy of the finished solution)
- Modify: `exercises/config/{test,dev}.exs`, `exercises/test/test_helper.exs`
- Revert to lesson 29's versions: `exercises/lib/tracker/issues.ex`, `exercises/lib/tracker/issues/issue.ex`
- Delete: `exercises/priv/repo/migrations/*_add_unique_issue_title_index.exs`
- Tag: `exercises/test/tracker/issue_changeset_test.exs` (7), `exercises/test/tracker/issues_test.exs` (2)

**Interfaces:**
- Consumes: Task 1's finished solution.
- Produces: 9 `@tag :pending` drill tests.

- [ ] **Step 1: Copy and point at its own databases**

```bash
cd /Users/ristkari/code/private/elixir-training/lessons/30-changesets-deep
cp -R solutions exercises
rm -rf exercises/_build
cd exercises
sed -i '' 's/tracker_30_solutions_test/tracker_30_exercises_test/; s/tracker_30_solutions_dev/tracker_30_exercises_dev/' config/test.exs config/dev.exs
```

Keep `deps/`.

- [ ] **Step 2: Put the issues side back to its lesson 29 shape**

This is what the learner starts from — working code, not a stub:

```bash
cd /Users/ristkari/code/private/elixir-training
cp lessons/29-schemas-and-migrations/solutions/lib/tracker/issues.ex \
   lessons/30-changesets-deep/exercises/lib/tracker/issues.ex
cp lessons/29-schemas-and-migrations/solutions/lib/tracker/issues/issue.ex \
   lessons/30-changesets-deep/exercises/lib/tracker/issues/issue.ex
rm lessons/30-changesets-deep/exercises/priv/repo/migrations/*_add_unique_issue_title_index.exs
```

There is no typed-placeholder stub in this lesson: both drills deepen code that already compiles and runs, so the 1.19 type-checker trap does not arise.

- [ ] **Step 3: Set the exercise test helper**

`exercises/test/test_helper.exs` (whole file):

```elixir
ExUnit.start(exclude: [pending: true])
Ecto.Adapters.SQL.Sandbox.mode(Tracker.Repo, :manual)
```

- [ ] **Step 4: Tag the nine drill tests**

Add `@tag :pending` immediately above each of these.

In `test/tracker/issue_changeset_test.exs` — seven:
- `"a title longer than 120 characters is rejected"`
- `"a title with no letter or number is rejected"`
- `"surrounding whitespace is trimmed before the rules run"`
- `"a status outside the enum is rejected at cast time"`
- `"a duplicate title in the same project is rejected"`
- `"an issue for a project that does not exist is rejected"`
- `"the unique index really exists in the database"`

**Leave `"the same title in a different project is fine"` untagged** — it passes before and after the drill, and it is what shows the learner the file is alive.

In `test/tracker/issues_test.exs` — two: `"create_issue/2 with a title stores an open issue"` and `"toggle_issue/1 flips status"` (both assert atoms now).

```bash
grep -c "@tag :pending" test/tracker/issue_changeset_test.exs test/tracker/issues_test.exs
```

Expected: `7`, `2`.

- [ ] **Step 5: Verify exercise behavior**

```bash
mise x -- mix format --check-formatted
mise x -- env MIX_ENV=test mix do compile --force --warnings-as-errors + test --warnings-as-errors 2>&1 | tail -n 3
mise x -- mix test --include pending 2>&1 | tail -n 3
```

Expected: no warnings; **`117 tests, 0 failures (9 excluded)`**; then **`126 tests, 9 failures`**. Confirm each failure's reason against this table — no test may pass, and none may fail for an unrelated reason:

| test | expected failure |
|---|---|
| title > 120 chars | `{:error, changeset}` doesn't match — the insert succeeds |
| title with no letter/number | same |
| whitespace trimmed | `assert issue.title == "Fix login"`, got `"  Fix login  "` |
| status outside the enum | `refute changeset.valid?` — lesson 29's changeset never casts `:status` |
| duplicate title | `{:error, changeset}` doesn't match — no index, no constraint |
| bogus `project_id` | **raises `Ecto.ConstraintError`** — the "before" the drill converts |
| unique index exists | `pg_indexes` returns no such row |
| `create_issue/2` stores an open issue | `assert issue.status == :open`, got `"open"` |
| `toggle_issue/1` flips status | `assert ... == :closed`, got `"closed"` |

- [ ] **Step 6: Confirm the folders differ only where they should**

```bash
cd /Users/ristkari/code/private/elixir-training/lessons/30-changesets-deep
diff -rq --exclude=_build --exclude=deps solutions exercises
```

Expected exactly eight lines: `config/dev.exs`, `config/test.exs`, `lib/tracker/issues.ex`, `lib/tracker/issues/issue.ex`, `test/test_helper.exs`, `test/tracker/issue_changeset_test.exs`, `test/tracker/issues_test.exs` differ, and the issue-title migration exists only in `solutions`.

- [ ] **Step 7: Commit the exercise**

```bash
cd /Users/ristkari/code/private/elixir-training
git add lessons/30-changesets-deep/exercises
git commit -F - <<'EOF'
Add lesson 30-changesets-deep exercise: the issues drills

Drill 1 is the Issue changeset: move it into the schema module, make
status an Ecto.Enum, add the length and custom validations, and follow
through on flip/1 and toggle_issue/1 for atoms. Drill 2 is the
constraints: a new unique index migration, unique_constraint with
error_key, and foreign_key_constraint.

Nine pending tests. The issues side starts as lesson 29 left it —
working code the learner deepens, so there is no stub and no
type-checker trap. The bogus-project_id test starts by raising
Ecto.ConstraintError, which is exactly the "before" drill 2 converts
into a changeset error.

Exercise: 117 tests, 0 failures, 9 excluded; 9 failures with pending
included.
EOF
```

---

## Task 3: Lesson 30 prose — README, HINTS, slides

**Files:** `lessons/30-changesets-deep/README.md`, `HINTS.md`, `slides/slides.md` (scaffolder templates to replace)

- [ ] **Step 1: Author `README.md`** (~60–70 lines, following `lessons/29-schemas-and-migrations/README.md`)

Required content, beyond the standard sections:
- The spine: a validation runs in Elixir and can only see this changeset; a constraint runs in Postgres and is the only thing that can see other rows.
- **A constraint error never appears at `changeset.valid?` time.** `Repo.insert` on an invalid changeset issues no SQL at all, so a validation error and a constraint error never arrive together. Everything lessons 24, 25 and 29 taught branches on `valid?` — this needs a callout.
- **The changeset helper enforces nothing; it translates.** Without `unique_constraint/3` a duplicate raises `Ecto.ConstraintError`. With it you get `{:error, changeset}`. And the inverse: declaring a constraint whose index does not exist is silent, so a missing migration is a data bug, not an error.
- **`NOT NULL` is the exception:** it has no entry in the Postgres→Ecto constraint mapping, so it re-raises `Postgrex.Error` — which is what the carried `issues_table_test.exs` already asserts.
- **Where the error lands:** `unique_constraint([:user_id, :name])` keys the error to the *first* field, so without `error_key:` it arrives on `:user_id`, a column with no input — and the form shows nothing at all.
- **Which errors are invisible in the browser:** the `foreign_key_constraint(:project_id)` one, because there is no `project_id` input and `<.input>` only renders errors for submitted fields.
- **Why `toggle_issue/1` skips the changeset**, and that `change/2` neither casts nor validates — the raise comes from `Repo.update!`'s dump.
- **A blank status** is substituted with the schema default by `cast/4` and records no change, so it saves as `open` rather than erroring.
- Accuracy note: this is not the app's first validation — `Accounts.User` has shipped several since lesson 26. It is the first the learner writes.
- Common mistakes: Postgres not running; no `mix ecto.setup` in this folder; editing an applied migration (`MIX_ENV=test mix ecto.rollback` for the test DB); a `%{key}` whose atom doesn't exist yet makes `errors_on/1`'s `String.to_existing_atom/1` raise.
- Going further, named not taught: `check_constraint/3` (needs `:name`, raises at changeset-build time), `unsafe_validate_unique/4` (already in `accounts/user.ex`), `phx-change="validate"` with `apply_action(changeset, :validate)`, and "go read `Accounts.User` now that you can parse every line of it".

- [ ] **Step 2: Author `HINTS.md`** — two drills, three hints each (nudge naming the API → shape → full code). Hint 3 for each drill is the corresponding code from Task 1 Steps 7 and 4.

- [ ] **Step 3: Author `slides/slides.md`** — replace the template. Sections: the changeset moving into the schema; `Ecto.Enum` and the select; `validate_length` and the `{msg, opts}` error shape; the custom validation in both spellings (`validate_change/3` and `User.validate_email_changed/1`'s `get_field` + `add_error`); the migration-plus-declaration round trip; the validation-versus-constraint contrast. Closer: "Next: lesson 31 — queries" with `make slides-dev LESSON=31-queries`.

- [ ] **Step 4: Verify the slides publish and commit**

```bash
cd /Users/ristkari/code/private/elixir-training
mise x -- make slides-build
grep -c "lessons/30-changesets-deep/slides/" dist/index.html    # expect 1
rm -rf dist
git add lessons/30-changesets-deep
git commit -F - <<'EOF'
Add lesson 30-changesets-deep prose: README, HINTS, slides
EOF
```

---

## Task 4: Final smoke + PR

- [ ] **Step 1: Full local pipeline**

```bash
cd /Users/ristkari/code/private/elixir-training
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
mise x -- make ci-smoke
mise x -- make lint
mise x -- make test
mise x -- make solutions-test
mise x -- make slides-build
```

Expected all green, with lesson 30's exercise at 117/0 (9 excluded) and its solution at 126/0.

- [ ] **Step 2: Prove the databases are separate**

```bash
docker exec elixir_training_postgres psql -U postgres -lqt | awk -F'|' '{print $1}' | grep tracker_30
docker exec elixir_training_postgres psql -U postgres -d tracker_30_exercises_test \
  -c "SELECT indexname FROM pg_indexes WHERE tablename = 'issues'"
```

Expected: both `tracker_30_*_test` databases exist, and the exercises one has **no** `issues_project_id_title_index` — that is the isolation drill 2 depends on.

- [ ] **Step 3: Confirm all 31 lessons publish**

```bash
mise x -- make slides-build
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules \
         04-control-flow 05-recursion 06-enum-and-the-pipe 07-collections \
         08-strings-and-binaries 09-streams 10-structs-and-protocols 11-error-handling \
         12-mix-projects 13-processes 14-tasks-and-agents 15-genserver-1 16-genserver-2 \
         17-supervisors 18-otp-applications 19-ets 20-distribution 21-plug \
         22-phoenix-tour 23-controllers-and-heex 24-forms-and-changesets-preview 25-contexts \
         26-auth 27-liveview-1 28-liveview-2 29-schemas-and-migrations 30-changesets-deep; do
  grep -q "lessons/$n/slides/" dist/index.html || echo "$n: MISSING"
done | grep -c MISSING | xargs -I{} echo "missing count: {} (expected 0)"
rm -rf dist
```

- [ ] **Step 4: Walk the exercise as a learner**

In a scratch copy of `exercises/` **outside the repo**, with `deps/` copied across, its `config/test.exs` pointed at a throwaway database name, and `.tool-versions` copied in, implement both drills using only `HINTS.md`'s Hint 3, then run `mise x -- mix test --include pending`. Expect **126 tests, 0 failures**. Report anything HINTS left ambiguous. Delete the scratch copy and drop the throwaway database afterwards.

- [ ] **Step 5: Push and open the PR**

```bash
git push -u origin plan-j-lesson-30
```

PR title: `Plan J: lesson 30 changesets-deep (validations and constraints)`. Body: Summary linking this plan, What shipped, Notes (the `error_key` finding, the trim ordering, the one web-layer line), and a Test plan with the counts above. Then `gh pr checks` once. **Do not merge** — the human merges.

---

## Self-review checklist (applied)

**Spec coverage:** decision 1 (changesets into schemas) → Task 1 Steps 5–7. Decision 2 (`Ecto.Enum` both schemas) → Steps 5, 7, 9. Decision 3 (two unique indexes, `error_key`) → Steps 3–5, 7. Decision 4 (`foreign_key_constraint`) → Step 7. Decision 5 (validations) → Steps 5, 7. Decision 6 (custom validation, trim first) → Steps 5, 7. Decision 7 (one web line, spelled-out module, `prompt`) → Step 8. Decision 8 (`toggle_issue` keeps `change/2`) → Step 7. Decision 9 (`errors_on/1`) → Step 10. Decision 10 (new test file, `pg_indexes`) → Step 10. Threading and per-lesson databases → Task 1 Steps 1–2, Task 2 Step 1. Prose → Task 3. Smoke, isolation proof, learner walkthrough, PR → Task 4. The spec's 6–8 pending-test target is refined to 9 by the prototype, recorded in the plan header.

**Placeholder scan:** none. Every code block is verified prototype output. Migration filenames are `<ts1>`/`<ts2>` because `ecto.gen.migration` stamps them at run time; Task 1 Step 3 prints them.

**Type consistency:** `Tracker.Projects.Project.changeset/2` and `Tracker.Issues.Issue.changeset/2` throughout; contexts call them and keep `change_*/0..1`, `create_*/2`, `toggle_issue/1`; `status` is `:open` / `:closed` atoms in Elixir and `"open"` / `"closed"` in raw SQL; error keys are `:name` and `:title`; index names are `projects_user_id_name_index` and `issues_project_id_title_index`; databases are `tracker_30_{solutions,exercises}_{test,dev}`.
