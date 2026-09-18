# Plan I — Lesson 29 (`schemas-and-migrations`: Tracker moves to Postgres) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author lesson `29-schemas-and-migrations`: replace Tracker's two `Agent`-backed stores with Ecto schemas, migrations and `Repo` calls, keeping the context API — and therefore the whole web layer — exactly as lesson 28 left it.

**Architecture:** Thread Tracker from lesson 28's solution. Projects is the provided worked example (`create_projects` migration, `Tracker.Projects.Project` schema, `Repo`-backed `Tracker.Projects`); issues is the drill (Drill 1: the `create_issues` migration; Drill 2: the `Issue` schema plus the `Repo`-backed `Tracker.Issues`). `ProjectStore` and `IssueStore` are deleted. The exercise is derived from the finished solution by dropping the issues migration and schema, stubbing `Tracker.Issues`, and tagging ten drill tests `@tag :pending`. Lesson 29 is the first lesson with its own databases, and the first whose carried files are normalized to the paren-free DSL.

**Tech Stack:** Elixir 1.19.5-otp-28 / OTP 29.0.1; Phoenix 1.8.7; `phoenix_live_view` 1.1.30; `ecto` 3.14.0, `ecto_sql` 3.14.0, `postgrex` 0.22.2, `phoenix_ecto` 4.7.0; Postgres 16. No new Hex deps.

**Spec:** `docs/superpowers/specs/2026-09-18-lesson-29-schemas-and-migrations-design.md`.

**This plan was prototyped end-to-end against a real Postgres, under the pinned toolchain, before being written.** The solution runs **118 tests / 0 failures** (stable across repeated runs with `async: true`); the exercise compiles under `--warnings-as-errors`, passes **108 / 0 with 10 excluded**, and fails **exactly those 10** with `--include pending`. Every code block below is verified prototype output and `mix format`-clean.

## Global Constraints

- Pinned toolchain: Elixir 1.19.5-otp-28, Erlang 29.0.1 (repo `.tool-versions`). **Install it first** — `mise install` (it is precompiled; ~11s). Do not prototype or record counts under Homebrew Elixir 1.20.
- No new Hex dependencies. `mix.lock` committed for both folders.
- App/module prefixes stay `Tracker` / `TrackerWeb`.
- Context API is unchanged from lesson 28: `list_projects(scope)`, `get_project!(id)`, `change_project(attrs \\ %{})`, `create_project(scope, attrs)`, `list_issues(project_id)`, `change_issue(attrs \\ %{})`, `create_issue(project_id, attrs)`, `toggle_issue(id)`. The web layer is touched only by the normalization pass in Task 2.
- Never `cast` `user_id` or `project_id`; set them on the struct.
- Paren-free DSL (`field :name, :string`, not `field(:name, :string)`) in every `lib/` and migration file of this lesson.
- Form param keys stay `"project"` / `"issue"`; stream DOM ids stay `#issues-<id>`.

---

## Conventions (read once, apply throughout)

### Repo-root rule
All `tools/*` scripts and `make` targets run from the repo root `/Users/ristkari/code/private/elixir-training`. Per-lesson `mix` commands run inside `lessons/29-schemas-and-migrations/exercises` or `.../solutions`.

### Local Postgres (required — this whole lesson is DB-backed)

```bash
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
```

Host port 5432 must be free. Unlike lesson 28, **no step of this plan may be verified in CI only** — the drills are the database.

### Databases
Lesson 29 is the first lesson with its own databases (spec decision 2):

| folder | test | dev |
|---|---|---|
| `solutions/` | `tracker_29_solutions_test#{MIX_TEST_PARTITION}` | `tracker_29_solutions_dev` |
| `exercises/` | `tracker_29_exercises_test#{MIX_TEST_PARTITION}` | `tracker_29_exercises_dev` |

The `mix test` alias already runs `ecto.create --quiet` and `ecto.migrate --quiet`, so a brand-new name needs no extra setup. **Every later lesson renames these to its own number when it copies this lesson.**

### Commit style
GPG signing is automatic. Write messages as heredocs. All commits in this plan use:
```
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```

### Build order
Task 1 solution → Task 2 normalization (so the exercise inherits normalized files) → Task 3 exercise → Task 4 prose → Task 5 smoke + PR.

### Phoenix-era stub convention
Exercise stubs are typed placeholders with `# TODO:` comments, never a bare `raise`, and they compile with zero warnings under `--warnings-as-errors`. Two things the prototype pinned down — **do not re-derive them**:

- **The `create_issue/2` stub must return both `{:ok, _}` and `{:error, _}`.** An error-only stub fails the build under Elixir 1.19's type checker with `the following clause will never match: {:ok, issue} … which has type: dynamic({:error, %{..., action: :insert}})` at `project_board_live.ex:53`.
- **Because the stub can therefore fabricate an issue, three drill tests must assert persistence, not just rendering.** The board's add and multi-tab tests reload the board; `create_issue/2`'s context test reads the issue back through `list_issues/1`. Without that, the stub's fake `%{id: 0, …}` satisfies them and they pass with the drill undone. (`assert issue.id` does not help: `0` is truthy.)
- No `alias`/`import` of `Tracker.Issues.Issue` anywhere in the exercise, and no `%Issue{}` in exercise test files — the module does not exist there, and test files are compiled even when their tests are excluded.

---

## Task 1: Lesson 29 solution — Tracker on Postgres

**Files:**
- Create: `lessons/29-schemas-and-migrations/` (scaffold), then `solutions/` as a copy of lesson 28's
- Create: `solutions/priv/repo/migrations/<ts1>_create_projects.exs`, `<ts2>_create_issues.exs`
- Create: `solutions/lib/tracker/projects/project.ex`, `solutions/lib/tracker/issues/issue.ex`
- Create: `solutions/test/tracker/issues_table_test.exs`
- Modify: `solutions/lib/tracker/projects.ex`, `solutions/lib/tracker/issues.ex`, `solutions/lib/tracker/application.ex`, `solutions/config/test.exs`, `solutions/config/dev.exs`
- Delete: `solutions/lib/tracker/project_store.ex`, `solutions/lib/tracker/issue_store.ex`
- Modify (tests): `solutions/test/tracker/projects_test.exs`, `solutions/test/tracker/issues_test.exs`, `solutions/test/tracker_web/controllers/project_controller_test.exs`, `solutions/test/tracker_web/live/project_board_live_test.exs`

**Interfaces:**
- Produces: `Tracker.Projects.Project` (`:name`, `:status`, `:user_id`, timestamps), `Tracker.Issues.Issue` (`:title`, `:status`, `:project_id`, timestamps); the eight context functions listed in Global Constraints, with `create_*` returning `{:ok, struct} | {:error, changeset}`, `toggle_issue/1` returning the bare updated struct, and `get_project!/1` raising `Ecto.NoResultsError`.
- Consumes: lesson 28's `ProjectController`, `ProjectBoardLive`, templates, router and auth — unchanged.

- [ ] **Step 1: Toolchain, Postgres, scaffold and thread**

```bash
cd /Users/ristkari/code/private/elixir-training
mise install                       # elixir 1.19.5-otp-28, erlang 29.0.1
elixir -v                          # must print 1.19.5 (compiled with Erlang/OTP 28)
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done

tools/new-lesson 29-schemas-and-migrations
rm -rf lessons/29-schemas-and-migrations/exercises lessons/29-schemas-and-migrations/solutions
cp -R lessons/28-liveview-2/solutions lessons/29-schemas-and-migrations/solutions
rm -rf lessons/29-schemas-and-migrations/solutions/_build lessons/29-schemas-and-migrations/solutions/deps
```

`exercises/` stays absent until Task 3. If `mix` reports missing Hex under the freshly installed Elixir: `mix local.hex --force && mix local.rebar --force`.

- [ ] **Step 2: Point the solution at its own databases**

```bash
cd lessons/29-schemas-and-migrations/solutions
sed -i '' 's/database: "tracker_test#{System.get_env("MIX_TEST_PARTITION")}"/database: "tracker_29_solutions_test#{System.get_env("MIX_TEST_PARTITION")}"/' config/test.exs
sed -i '' 's/database: "tracker_dev"/database: "tracker_29_solutions_dev"/' config/dev.exs
grep -n 'database:' config/test.exs config/dev.exs
```

Expected: `tracker_29_solutions_test#{...}` and `tracker_29_solutions_dev`.

- [ ] **Step 3: Generate both migration files, in order**

```bash
mix deps.get
mix ecto.gen.migration create_projects
sleep 1
mix ecto.gen.migration create_issues
ls priv/repo/migrations
```

Expected three files: the carried `20260603050426_create_users_auth_tables.exs`, then `create_projects`, then `create_issues`. **`create_issues` must carry the later timestamp** — `issues` references `projects`. The `sleep 1` guarantees it.

- [ ] **Step 4: Write the two migration bodies**

`priv/repo/migrations/<ts1>_create_projects.exs`:

```elixir
defmodule Tracker.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string, null: false
      add :status, :string, null: false, default: "open"
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps type: :utc_datetime
    end

    create index(:projects, [:user_id])
  end
end
```

`priv/repo/migrations/<ts2>_create_issues.exs`:

```elixir
defmodule Tracker.Repo.Migrations.CreateIssues do
  use Ecto.Migration

  def change do
    create table(:issues) do
      add :title, :string, null: false
      add :status, :string, null: false, default: "open"
      add :project_id, references(:projects, on_delete: :delete_all), null: false

      timestamps type: :utc_datetime
    end

    create index(:issues, [:project_id])
  end
end
```

- [ ] **Step 5: Write the two schemas**

`lib/tracker/projects/project.ex`:

```elixir
defmodule Tracker.Projects.Project do
  @moduledoc "A project row: an Elixir struct that mirrors the `projects` table."
  use Ecto.Schema

  schema "projects" do
    field :name, :string
    field :status, :string, default: "open"
    field :user_id, :id

    timestamps type: :utc_datetime
  end
end
```

`lib/tracker/issues/issue.ex`:

```elixir
defmodule Tracker.Issues.Issue do
  @moduledoc "An issue row: an Elixir struct that mirrors the `issues` table."
  use Ecto.Schema

  schema "issues" do
    field :title, :string
    field :status, :string, default: "open"
    field :project_id, :id

    timestamps type: :utc_datetime
  end
end
```

- [ ] **Step 6: Rewrite both contexts on `Repo`**

`lib/tracker/projects.ex` (whole file):

```elixir
defmodule Tracker.Projects do
  @moduledoc "The Projects context: the boundary for project business logic."
  import Ecto.Query

  alias Ecto.Changeset
  alias Tracker.Projects.Project
  alias Tracker.Repo

  def list_projects(scope) do
    # Query syntax is lesson 31. Read it as: this user's rows, oldest first.
    from(p in Project, where: p.user_id == ^scope.user.id, order_by: [asc: p.id])
    |> Repo.all()
  end

  def get_project!(id), do: Repo.get!(Project, id)

  def change_project(attrs \\ %{}), do: changeset(%Project{}, attrs)

  def create_project(scope, attrs) do
    %Project{user_id: scope.user.id}
    |> changeset(attrs)
    |> Repo.insert()
  end

  defp changeset(project, attrs) do
    project
    |> Changeset.cast(attrs, [:name, :status])
    |> Changeset.validate_required([:name])
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

  def change_issue(attrs \\ %{}), do: changeset(%Issue{}, attrs)

  def create_issue(project_id, attrs) do
    %Issue{project_id: project_id}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def toggle_issue(id) do
    issue = Repo.get!(Issue, id)

    issue
    |> Changeset.change(status: flip(issue.status))
    |> Repo.update!()
  end

  defp changeset(issue, attrs) do
    issue
    |> Changeset.cast(attrs, [:title])
    |> Changeset.validate_required([:title])
  end

  defp flip("open"), do: "closed"
  defp flip(_), do: "open"
end
```

`validate_required` deliberately does **not** list `:status`: with `default: "open"` on the schema, `cast/4` replaces a blank `""` param with the default and records no change, so such a check could never fire.

- [ ] **Step 7: Delete both stores and their supervisor children**

```bash
rm lib/tracker/project_store.ex lib/tracker/issue_store.ex
```

In `lib/tracker/application.ex`, delete exactly these two lines from the `children` list:

```elixir
      Tracker.ProjectStore,
      Tracker.IssueStore,
```

Verify nothing references them: `grep -rn "ProjectStore\|IssueStore" lib test` must print nothing.

- [ ] **Step 8: Update the carried context tests**

`test/tracker/projects_test.exs` — change the `use` line to `use Tracker.DataCase, async: true` and change the last test's expected error:

```elixir
  test "get_project!/1 raises for a missing id" do
    assert_raise Ecto.NoResultsError, fn -> Projects.get_project!(999_999) end
  end
```

`test/tracker/issues_test.exs` (whole file) — real projects instead of invented ids 1/101/102, and the create test now reads the issue back:

```elixir
defmodule Tracker.IssuesTest do
  use Tracker.DataCase, async: true

  alias Tracker.Issues
  alias Tracker.Accounts.Scope
  import Tracker.AccountsFixtures

  defp create_project(name) do
    scope = Scope.for_user(user_fixture())
    {:ok, project} = Tracker.Projects.create_project(scope, %{"name" => name})
    project
  end

  test "create_issue/2 with a title stores an open issue" do
    project = create_project("Apollo")
    assert {:ok, issue} = Issues.create_issue(project.id, %{"title" => "Write tests"})
    assert issue.title == "Write tests"
    assert issue.status == "open"
    assert issue.project_id == project.id

    # It was stored, not just built: reading it back finds the same row.
    assert [stored] = Issues.list_issues(project.id)
    assert stored.id == issue.id
  end

  test "create_issue/2 with a blank title returns an error changeset" do
    project = create_project("Apollo")
    assert {:error, changeset} = Issues.create_issue(project.id, %{"title" => ""})
    refute changeset.valid?
  end

  test "list_issues/1 returns only that project's issues" do
    one = create_project("One")
    two = create_project("Two")
    {:ok, a} = Issues.create_issue(one.id, %{"title" => "A"})
    {:ok, b} = Issues.create_issue(two.id, %{"title" => "B"})

    ids = Enum.map(Issues.list_issues(one.id), & &1.id)
    assert a.id in ids
    refute b.id in ids
  end

  test "toggle_issue/1 flips status" do
    project = create_project("Apollo")
    {:ok, issue} = Issues.create_issue(project.id, %{"title" => "Toggle me"})
    assert Issues.toggle_issue(issue.id).status == "closed"
    assert Issues.toggle_issue(issue.id).status == "open"
  end
end
```

- [ ] **Step 9: Update the carried web tests (async + persistence assertions)**

In `test/tracker_web/controllers/project_controller_test.exs`, replace the three-line `async: false` comment and its `use` line with:

```elixir
  # Each test logs in a freshly-registered user, so their projects never
  # collide; assert on per-user visibility, not global counts.
  use TrackerWeb.ConnCase, async: true
```

In `test/tracker_web/live/project_board_live_test.exs`, replace the four-line comment and `use` line with:

```elixir
  # Each test makes a fresh user + project; assertions target a specific issue
  # by its stream dom id (#issues-<id>), never "the only element on the board".
  use TrackerWeb.ConnCase, async: true
```

and give the two add-flavored tests a reload assertion (this is what stops a fabricated stub issue from satisfying them in Task 3):

```elixir
    test "adding an issue shows it on the board and stores it", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")
      view |> form("form", issue: %{title: "Fix login"}) |> render_submit()
      assert render(view) =~ "Fix login"

      # Reload the board: a stored issue is still there.
      {:ok, reloaded, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert render(reloaded) =~ "Fix login"
    end
```

```elixir
      tab_a |> form("form", issue: %{title: "Broadcast me"}) |> render_submit()

      assert render(tab_b) =~ "Broadcast me"

      # And it was stored, not just pushed across the wire.
      {:ok, reloaded, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert render(reloaded) =~ "Broadcast me"
    end
```

- [ ] **Step 10: Add the table test (the file that drives Drill 1)**

Create `test/tracker/issues_table_test.exs`:

```elixir
defmodule Tracker.IssuesTableTest do
  # This file checks the `issues` TABLE, not the Issue schema: it talks to
  # Postgres through raw inserts and SQL, so it says nothing about your
  # Elixir code. Each check gets its own test, because a rejected statement
  # aborts the surrounding sandbox transaction.
  use Tracker.DataCase, async: true

  alias Tracker.Accounts.Scope
  alias Tracker.Repo
  import Tracker.AccountsFixtures

  defp project_id do
    scope = Scope.for_user(user_fixture())
    {:ok, project} = Tracker.Projects.create_project(scope, %{"name" => "Apollo"})
    project.id
  end

  # insert_all with a table name (not a schema) autogenerates nothing, so the
  # timestamps `timestamps/1` made NOT NULL have to be filled in by hand.
  defp row(attrs) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    Enum.into(attrs, %{inserted_at: now, updated_at: now})
  end

  test "project_id must point at a project that exists" do
    error = catch_error(Repo.insert_all("issues", [row(title: "Orphan", project_id: 999_999)]))
    assert %Postgrex.Error{postgres: %{code: :foreign_key_violation}} = error
  end

  test "title cannot be null" do
    error = catch_error(Repo.insert_all("issues", [row(project_id: project_id())]))
    assert %Postgrex.Error{postgres: %{code: :not_null_violation, column: "title"}} = error
  end

  test "status defaults to open in the database" do
    {1, nil} = Repo.insert_all("issues", [row(title: "No status given", project_id: project_id())])
    assert %{rows: [["open"]]} = Repo.query!("SELECT status FROM issues")
  end

  test "project_id is indexed" do
    %{rows: rows} = Repo.query!("SELECT indexname FROM pg_indexes WHERE tablename = 'issues'")
    assert ["issues_project_id_index"] in rows
  end
end
```

The `column: "title"` match matters: without it the check would also pass on some other NOT NULL column, proving nothing about `title`.

- [ ] **Step 11: Format and verify the solution is fully green**

```bash
mix format
mix format --check-formatted
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
mix test 2>&1 | tail -n 3
```

Expected: format clean; compile ends `Generated tracker app` with no warnings; **`118 tests, 0 failures`**. Then run `mix test` twice more — the counts must be identical and no sandbox "owner exited" messages may appear (this lesson is the repo's first `async: true` LiveView DB suite).

- [ ] **Step 12: Commit the solution**

```bash
cd /Users/ristkari/code/private/elixir-training
git checkout -b plan-i-lesson-29
git add lessons/29-schemas-and-migrations
git commit -F - <<'EOF'
Add lesson 29-schemas-and-migrations solution: Tracker on Postgres

Projects and issues move from the Agent stores into Ecto schemas and
migrations. The contexts keep every signature lesson 25 promised, so the
controller, the LiveView and the templates are untouched.

Projects is the worked example; issues is what the exercise will drill.
Both foreign keys are indexed and cascade on delete. list_* uses a
one-line from/where/order_by, flagged as lesson 31's topic, because a
table has no inherent order and toggling updates a row.

First lesson with its own databases (tracker_29_solutions_*), so the
exercise can write its own create_issues migration without colliding.

Solution green against Postgres: 118 tests, 0 failures.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
```

---

## Task 2: Normalize the DSL and stop formatting lessons from the root

**Files:**
- Modify: 8 files under `lessons/29-schemas-and-migrations/solutions/{lib,priv/repo/migrations}`
- Modify: `/Users/ristkari/code/private/elixir-training/.formatter.exs`

**Interfaces:**
- Produces: a lesson-29 solution whose every DSL call is paren-free, so the drills' `field`/`add`/`timestamps` match the surrounding code and the docs.
- Consumes: Task 1's finished solution.

**Why a script and not `mix format`:** the formatter never *removes* parentheses from a call in `locals_without_parens` — it only declines to add them. Both styles are format-stable, which is how lessons 27 and 28 ship the same generated files in opposite styles with `make lint` green.

- [ ] **Step 1: Write the one-off rewriter**

```bash
cd /Users/ristkari/code/private/elixir-training
cat > /tmp/depare.py <<'PY'
#!/usr/bin/env python3
"""Rewrite `macro(args)` back to `macro args` for Ecto/Phoenix DSL macros.

Only rewrites lines whose FIRST token is one of MACROS (so remote calls like
DateTime.add(...) are untouched), only under lib/ and priv/repo/migrations/.
"""
import sys, pathlib, re

MACROS = ["plug","socket","field","add","timestamps","execute","attr","slot",
          "pipe_through","get","post","put","patch","delete","forward","live",
          "live_session","live_dashboard","resources","embeds_one","embeds_many"]
PAT = re.compile(r'^(\s*)(' + "|".join(MACROS) + r')\((.*)$', re.S)

def rewrite(text):
    lines = text.split("\n")
    out, i = [], 0
    while i < len(lines):
        m = PAT.match(lines[i])
        if not m:
            out.append(lines[i]); i += 1; continue
        indent, macro, rest = m.groups()
        depth, buf, j = 1, [rest], i
        while depth > 0:
            for ch in (rest if j == i else lines[j]):
                if ch == "(": depth += 1
                elif ch == ")": depth -= 1
            if depth == 0: break
            j += 1
            if j >= len(lines): return None   # unbalanced; leave file alone
            buf.append(lines[j])
        last = buf[-1]
        if not last.rstrip().endswith(")"):
            out.append(lines[i]); i += 1; continue
        buf[-1] = last.rstrip()[:-1].rstrip()
        buf[0] = indent + macro + " " + buf[0]
        out.extend([b for b in buf if b.strip() != ""] if buf[-1].strip() == "" else buf)
        i = j + 1
    return "\n".join(out)

changed = 0
for root in sys.argv[1:]:
    for p in list(pathlib.Path(root).glob("lib/**/*.ex")) + list(pathlib.Path(root).glob("priv/repo/migrations/*.exs")):
        src = p.read_text()
        new = rewrite(src)
        if new and new != src:
            p.write_text(new); changed += 1
print(f"rewrote {changed} files")
PY
```

`test/` is deliberately out of scope: `get(conn, ...)`, `post(conn, ...)` and `live(conn, ...)` there are ordinary function calls whose parens are correct.

- [ ] **Step 2: Run it and verify nothing broke**

```bash
cd lessons/29-schemas-and-migrations/solutions
python3 /tmp/depare.py .
mix format
mix format --check-formatted && echo FORMAT_OK
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
mix test 2>&1 | tail -n 3
grep -rnE '^\s*(plug|socket|field|add|attr|slot|timestamps|resources|pipe_through|execute)\(' lib priv/repo/migrations | wc -l
```

Expected: `rewrote 8 files`; `FORMAT_OK`; no warnings; **`118 tests, 0 failures`**; leftover count **`0`**. The 8 files are `core_components.ex`, `router.ex`, `endpoint.ex`, `layouts.ex`, `user_settings_controller.ex`, `accounts/user.ex`, `accounts/user_token.ex` and the carried auth migration. Read the diff before committing — it must contain nothing but removed parentheses.

- [ ] **Step 3: Commit the normalization**

```bash
cd /Users/ristkari/code/private/elixir-training
git add lessons/29-schemas-and-migrations
git commit -F - <<'EOF'
style: paren-free DSL across the lesson 29 solution

Lesson 29 teaches the schema and migration DSL, so its files should read
the way the Ecto and Phoenix docs write it. Parentheses only; no
behavioral change, and the suite is unchanged at 118 tests, 0 failures.

mix format cannot do this — locals_without_parens stops the formatter
adding parens, never removes them — so this was a scripted rewrite of
lines whose first token is a DSL macro, reviewed by eye.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
```

- [ ] **Step 4: Stop the root formatter from reaching into lessons**

In `/Users/ristkari/code/private/elixir-training/.formatter.exs`, remove the `lessons/**` glob from `inputs` (it has `locals_without_parens: []`, so running `mix format` from the root is what added the parens to lessons 22–28 in the first place; each lesson formats itself through its own `.formatter.exs`, which `tools/lint-all` already invokes per folder).

```bash
cat .formatter.exs                      # confirm lessons/** is gone
mix format --check-formatted            # root project still clean
make lint                               # every lesson still formats itself
```

- [ ] **Step 5: Commit the formatter fix**

```bash
git add .formatter.exs
git commit -F - <<'EOF'
chore: stop formatting lessons/ from the repo root

The root .formatter.exs sets locals_without_parens: [], so formatting
from the root rewrites every lesson's Phoenix and Ecto DSL with
parentheses. Each lesson has its own .formatter.exs with the right
import_deps, and tools/lint-all runs the formatter per folder.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
```

---

## Task 3: Lesson 29 exercise — derive and stub the issues side

**Files:**
- Create: `lessons/29-schemas-and-migrations/exercises/` (copy of the finished solution)
- Modify: `exercises/config/test.exs`, `exercises/config/dev.exs`, `exercises/lib/tracker/issues.ex`, `exercises/test/test_helper.exs`
- Delete: `exercises/priv/repo/migrations/<ts2>_create_issues.exs`, `exercises/lib/tracker/issues/issue.ex` (and the now-empty `lib/tracker/issues/`)
- Modify (tags): `exercises/test/tracker/issues_table_test.exs`, `exercises/test/tracker/issues_test.exs`, `exercises/test/tracker_web/live/project_board_live_test.exs`

**Interfaces:**
- Consumes: Task 1 + Task 2's solution, verbatim.
- Produces: the ten `@tag :pending` drill tests the learner turns green.

- [ ] **Step 1: Copy the solution and point it at its own databases**

```bash
cd /Users/ristkari/code/private/elixir-training/lessons/29-schemas-and-migrations
cp -R solutions exercises
rm -rf exercises/_build exercises/deps
cd exercises
sed -i '' 's/tracker_29_solutions_test/tracker_29_exercises_test/; s/tracker_29_solutions_dev/tracker_29_exercises_dev/' config/test.exs config/dev.exs
grep -n 'database:' config/test.exs config/dev.exs
```

- [ ] **Step 2: Remove what the learner writes**

```bash
rm priv/repo/migrations/*_create_issues.exs
rm lib/tracker/issues/issue.ex && rmdir lib/tracker/issues
ls priv/repo/migrations        # only the auth migration + create_projects
```

- [ ] **Step 3: Set the exercise test helper**

`test/test_helper.exs` (whole file):

```elixir
ExUnit.start(exclude: [pending: true])
Ecto.Adapters.SQL.Sandbox.mode(Tracker.Repo, :manual)
```

- [ ] **Step 4: Stub the Issues context**

`lib/tracker/issues.ex` (whole file — note: no `alias` of `Issue`, no `import Ecto.Query`, both would warn):

```elixir
defmodule Tracker.Issues do
  @moduledoc "The Issues context: the boundary for issue business logic."

  # Drill 2 replaces this module's storage with Ecto. Until then the changeset
  # below is the lesson-24 schemaless kind, so the board still renders its
  # form — but nothing is ever stored.
  @types %{title: :string, status: :string}

  def list_issues(_project_id) do
    # TODO (drill 2): return this project's issues, oldest first, from the DB.
    []
  end

  def change_issue(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, [:title])
    |> Ecto.Changeset.validate_required([:title])
  end

  def create_issue(project_id, attrs) do
    changeset = change_issue(attrs)

    if changeset.valid? do
      # TODO (drill 2): insert the issue with Repo.insert/1 and return it.
      # This placeholder is never stored, so it vanishes on the next page load.
      {:ok,
       %{
         id: 0,
         title: Ecto.Changeset.get_field(changeset, :title),
         status: "open",
         project_id: project_id
       }}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  def toggle_issue(_id) do
    # TODO (drill 2): load the issue, flip its status, save it, return it.
    %{id: 0, title: "", status: "open", project_id: 0}
  end
end
```

`change_issue/1` must keep working: `ProjectBoardLive.mount/3` calls it on every board load.

- [ ] **Step 5: Tag the ten drill tests**

Add `@tag :pending` immediately above each of these:

- `test/tracker/issues_table_test.exs` — all four tests (Drill 1).
- `test/tracker/issues_test.exs` — `"create_issue/2 with a title stores an open issue"`, `"list_issues/1 returns only that project's issues"`, `"toggle_issue/1 flips status"`. The blank-title test stays untagged: the stub's changeset still validates, so it passes and shows the learner the file is alive.
- `test/tracker_web/live/project_board_live_test.exs` — `"adding an issue shows it on the board and stores it"`, `"toggling an issue flips its status"`, `"a second tab sees a new issue live"`. The unauthenticated and not-yours tests stay untagged.

```bash
grep -c "@tag :pending" test/tracker/issues_table_test.exs test/tracker/issues_test.exs test/tracker_web/live/project_board_live_test.exs
```

Expected: `4`, `3`, `3`.

- [ ] **Step 6: Verify exercise behavior**

```bash
mix deps.get
mix format
mix format --check-formatted && echo FORMAT_OK
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
mix test 2>&1 | tail -n 3
mix test --include pending 2>&1 | tail -n 3
```

Expected, exactly:
- compile: no warnings (if you see `the following clause will never match … {:ok, issue}`, the `create_issue/2` stub lost its success branch),
- `mix test` → **`108 tests, 0 failures (10 excluded)`**,
- `mix test --include pending` → **`118 tests, 10 failures`**.

Confirm each failure's reason — no test may fail for an unrelated reason, and none may pass:

| test | expected failure |
|---|---|
| `issues_table_test` ×4 | `relation "issues" does not exist` / `code: :undefined_table`, and the index query returning no rows |
| `create_issue/2 … stores an open issue` | `assert [stored] = Issues.list_issues(project.id)` — the stub returns `[]` |
| `list_issues/1 …` | `assert a.id in ids` |
| `toggle_issue/1 flips status` | `assert Issues.toggle_issue(issue.id).status == "closed"` |
| board add | `assert render(reloaded) =~ "Fix login"` (the reload, not the first render) |
| board toggle | `has_element?(view, "#issues-<id> .status", "open")` — the board is empty |
| board multi-tab | `assert render(reloaded) =~ "Broadcast me"` |

- [ ] **Step 7: Confirm the folders differ only where they should**

```bash
cd /Users/ristkari/code/private/elixir-training/lessons/29-schemas-and-migrations
diff -rq --exclude=_build --exclude=deps solutions exercises
```

Expected exactly nine lines: `config/dev.exs`, `config/test.exs`, `lib/tracker/issues.ex`, `test/test_helper.exs`, `test/tracker/issues_table_test.exs`, `test/tracker/issues_test.exs`, `test/tracker_web/live/project_board_live_test.exs` differ; `lib/tracker/issues` and the `create_issues` migration exist only in `solutions`.

- [ ] **Step 8: Commit the exercise**

```bash
cd /Users/ristkari/code/private/elixir-training
git add lessons/29-schemas-and-migrations/exercises
git commit -F - <<'EOF'
Add lesson 29-schemas-and-migrations exercise: the issues drills

Drill 1 is the create_issues migration, driven by a provided test that
inspects the real table: foreign key, NOT NULL title, the "open" default
and the project_id index. Drill 2 is the Issue schema and the Repo-backed
Issues context.

The stub returns both {:ok, _} and {:error, _}: an error-only stub trips
Elixir 1.19's type checker on the LiveView's {:ok, issue} clause. Because
it can therefore fabricate an issue, the add, multi-tab and create tests
assert the issue is still there after a reload.

Exercise: 108 tests, 0 failures, 10 excluded; 10 failures with pending
included.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
```

---

## Task 4: Lesson 29 prose — README, HINTS, slides, and two prose corrections

**Files:**
- Modify: `lessons/29-schemas-and-migrations/README.md`, `HINTS.md`, `slides/slides.md` (scaffolder templates)
- Modify: `lessons/23-controllers-and-heex/README.md`, `lessons/24-forms-and-changesets-preview/README.md` and its `slides/slides.md`, `lessons/25-contexts/README.md`

- [ ] **Step 1: Author `README.md`** (~60 lines, following `lessons/28-liveview-2/README.md`)

- H1 `# Lesson 29: Schemas & migrations`, then "By the end of this lesson, …" and a bridge paragraph: lesson 25 promised the contexts' API would not change when real storage arrived — this is that swap, and the controller and LiveView diff is empty.
- **What you should be able to do** (4 bullets): write a migration and run it; write a schema and say which column each field maps to; use `Repo.insert/get!/update!/all`; explain why a foreign key gets an index.
- **Key ideas**, bold run-in paragraphs: a schema is a struct (callback to lesson 10) that names a table; migrations are ordered, run-once, and never edited after they run; `references` plus `null: false` plus `on_delete: :delete_all`; why `project_id` is indexed (every board load filters on it); field-to-column mapping — `:string`→`varchar(255)`, `:id`→`bigint`, `timestamps type: :utc_datetime`→`timestamp(0)` (**not** `timestamptz`: `:utc_datetime` is a guarantee Ecto enforces in Elixir, so the column needs no zone), `citext` in the carried users migration; `cast` on `%Project{}` instead of lesson 24's `{data, types}`; a blank status becomes the schema default, and the database has `null: false` plus its own default; a table has no inherent order, so `list_*` says `order_by` (query syntax is lesson 31). Two "First time seeing this?" callouts: what a foreign key is; what an index is for.
- **The drills**: Drill 1 `mix ecto.gen.migration create_issues` then the table body, driven by `test/tracker/issues_table_test.exs`; Drill 2 `lib/tracker/issues/issue.ex` plus `lib/tracker/issues.ex` on `Repo`. Say that 10 tests are pending and that every issue test needs both drills.
- **How to work this lesson** (the fixed six steps, including `docker compose up -d postgres`, `mix deps.get`, `mix ecto.setup`, "see the 10 failing drill tests" via `mix test --include pending`).
- **Try it**: `mix phx.server`, register (the login link is at `/dev/mailbox`), create a project, stop the server with Ctrl-C twice, start it again — the project is still there. Note that lesson 28's dev data is not, because this lesson has its own database.
- **Common mistakes**: (1) Postgres isn't running; (2) no `mix ecto.setup` in this folder — each lesson folder has its own database now, and the dev server shows phoenix_ecto's "run migrations" page until you do; (3) editing a migration that already ran does nothing — `MIX_ENV=test mix ecto.rollback` for the test database, plain `mix ecto.rollback` for dev, or `MIX_ENV=test mix ecto.reset`; (4) `create_issues` must be stamped after `create_projects`.
- **Going further**: `mix phx.gen.schema` and what it would have written here; `Ecto.Enum` for status (lesson 30); atomic `update_all` toggles (lessons 31/33).
- **Links**: `Ecto.Schema`, `Ecto.Migration`, `Ecto.Repo` on hexdocs.

- [ ] **Step 2: Author `HINTS.md`** — the standard preamble (one hint at a time, Postgres reminder, "2 drills, 10 pending tests"), then `## Drill 1: The create_issues migration` and `## Drill 2: The Issue schema and the Issues context`, each with `### Hint 1` (names the API: `mix ecto.gen.migration`, `create table`, `add`, `references`, `create index` / `use Ecto.Schema`, `schema`, `field`, `Repo.insert`, `Repo.get!`, `Ecto.Changeset.change`), `### Hint 2` (shape, partial code), `### Hint 3` (the full code from Task 1 Steps 4–6).

- [ ] **Step 3: Author `slides/slides.md`** — replace the template. Title `# Lesson 29` / `## Schemas & migrations — the Agent is gone`; then sections (`---`) with `--` sub-slides, each one code block (≤15 lines) plus 1–3 prose lines: the `create_issues` migration; the `Issue` schema beside it (field ↔ column); `Repo.insert/get!/update!/all` replacing the Agent; the `from/where/order_by` line with "lesson 31 explains this"; why `project_id` is indexed; what `mix phx.gen.schema` would have generated and why we wrote it by hand. Closer: "Next: lesson 30 — changesets-deep" with `make slides-dev LESSON=30-changesets-deep`.

- [ ] **Step 4: Verify the slides publish, then commit the lesson prose**

```bash
cd /Users/ristkari/code/private/elixir-training
make slides-build
grep -c "lessons/29-schemas-and-migrations/slides/" dist/index.html    # expect 1
rm -rf dist
git add lessons/29-schemas-and-migrations
git commit -F - <<'EOF'
Add lesson 29-schemas-and-migrations prose: README, HINTS, slides

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
```

- [ ] **Step 5: Fix the two stale forward references, and add one forward note**

Corrections (these are wrong today):
- `lessons/23-controllers-and-heex/README.md:5` and `lessons/24-forms-and-changesets-preview/README.md:3,69,94` say projects/persistence arrive in lesson 26. They arrive in lesson 29 — reword.
- `lessons/24-forms-and-changesets-preview/slides/slides.md:117` ("That's the gap Postgres fills next") is stale because lesson 25 adds no Postgres. Point it at lesson 29.

A forward note, **not** a correction: `lessons/25-contexts/README.md:48,75,91` describe `RuntimeError` and integer-keyed lookup. Those are true of lesson 25's own Agent store and its tests still pin them, so keep the wording and append one sentence: in lesson 29 the store becomes `Repo.get!`, which raises `Ecto.NoResultsError` and accepts a string id.

```bash
git add lessons/23-controllers-and-heex lessons/24-forms-and-changesets-preview lessons/25-contexts
git commit -F - <<'EOF'
docs: point lessons 23-25 at lesson 29 for Postgres

Lessons 23 and 24 told learners persistence arrives in lesson 26; lesson
26 only brought the users table. Lesson 25's RuntimeError and
integer-key text is correct for its own Agent store, so it keeps its
wording and gains a forward note about Repo.get!.

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
EOF
```

---

## Task 5: Final smoke + PR

- [ ] **Step 1: Full local pipeline (Postgres up)**

```bash
cd /Users/ristkari/code/private/elixir-training
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
make ci-smoke
make lint
make test
make solutions-test
make slides-build
```

Expected: all green, with lesson 29's exercise at 108/0 (10 excluded) and its solution at 118/0, each against its own database.

- [ ] **Step 2: Prove the databases are really separate**

```bash
docker exec elixir_training_postgres psql -U postgres -lqt | awk -F'|' '{print $1}' | grep tracker
docker exec elixir_training_postgres psql -U postgres -d tracker_29_exercises_test -c '\dt' | grep -c issues
```

Expected: `tracker_29_solutions_test` and `tracker_29_exercises_test` both exist, and the exercises database has **no** `issues` table (`0`) — that is the isolation the drill depends on.

- [ ] **Step 3: Confirm all 30 lessons publish**

```bash
make slides-build
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules \
         04-control-flow 05-recursion 06-enum-and-the-pipe 07-collections \
         08-strings-and-binaries 09-streams 10-structs-and-protocols 11-error-handling \
         12-mix-projects 13-processes 14-tasks-and-agents 15-genserver-1 16-genserver-2 \
         17-supervisors 18-otp-applications 19-ets 20-distribution 21-plug \
         22-phoenix-tour 23-controllers-and-heex 24-forms-and-changesets-preview 25-contexts \
         26-auth 27-liveview-1 28-liveview-2 29-schemas-and-migrations; do
  grep -q "lessons/$n/slides/" dist/index.html || echo "$n: MISSING"
done | grep -c MISSING | xargs -I{} echo "missing count: {} (expected 0)"
rm -rf dist
```

- [ ] **Step 4: Walk the exercise as a learner (the check nothing else makes)**

In a scratch copy of `exercises/`, write the migration and the schema/context from the HINTS' Hint 3 and confirm the suite goes to 118/0. Delete the scratch copy. This is the only proof that the drills are completable from the hints alone.

- [ ] **Step 5: Push the branch and open the PR**

```bash
git push -u origin plan-i-lesson-29
gh pr create --title "Plan I: lesson 29 schemas-and-migrations (Tracker on Postgres)" --body "$(cat <<'EOF'
## Summary

Phase 4 opens: Tracker's projects and issues move from the Agent stores into
Postgres, per `docs/superpowers/plans/2026-09-18-plan-i-lesson-29-schemas-and-migrations.md`
and its spec.

## What shipped

- Lesson 29 solution: `create_projects`/`create_issues` migrations, `Project` and
  `Issue` schemas, both contexts on `Repo`, both Agent stores deleted.
- Lesson 29 exercise: Drill 1 the issues migration, Drill 2 the schema + context;
  10 pending tests, including a provided test that inspects the real table.
- First lesson with its own databases, so the exercise can write its own
  migration without colliding with the solution.
- Paren-free DSL across the lesson, and the root formatter no longer reaches
  into `lessons/`.
- README, HINTS, slides; lessons 23–25 prose pointed at lesson 29.

## Notes

- The context API is unchanged, so the controller, LiveView and templates differ
  from lesson 28 only by formatting.
- `get_project!/1` now raises `Ecto.NoResultsError` (a 404) instead of
  `RuntimeError` — the one deliberate change, called out in the README.
- The carried suites are now `async: true`; the Agent singletons that forced
  `async: false` are gone.

## Test plan

- [ ] CI green with the Postgres service.
- [ ] Solution 118/0; exercise 108/0 with 10 excluded, 10 failures with pending.
- [ ] `tracker_29_exercises_test` has no `issues` table until the drill is done.
- [ ] After merge, Deploy republishes the slide site with lesson 29.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 6: Watch CI; merge after green + approval**

`gh pr checks` until green. If green and approved: `gh pr merge --squash` → triggers Deploy. (Leave the merge to the human, per prior phases.)

---

## Self-review checklist (applied)

**Spec coverage:** decision 1 (projects provided, issues drilled) → Task 1 Steps 4–6, Task 3 Steps 2–5. Decision 2 (per-folder databases) → Task 1 Step 2, Task 3 Step 1, Task 5 Step 2. Decision 3 (unchanged API, `Repo.get!`) → Task 1 Step 6, Task 1 Step 8. Decision 4 (id fields + `references`) → Task 1 Steps 4–5. Decision 5 (hand-written, `ecto.gen.migration`) → Task 1 Steps 3–5, slide in Task 4 Step 3. Decision 6 (`:string` status, type mapping, no `validate_required(:status)`) → Task 1 Step 6, README in Task 4 Step 1. Decision 7 (query preview) → Task 1 Step 6. Decision 8 (paren-free DSL, root formatter) → Task 2. Decision 9 (table test) → Task 1 Step 10. Decision 10 (stores deleted) → Task 1 Step 7. Testing section → Task 1 Steps 8–9, Task 3 Steps 5–6. Prose section → Task 4. Risks 1–4 → Task 1 Step 11 (repeat runs), Task 3 Step 6 (failure-reason table), Task 5 Step 2 (database isolation). Risk 8 → Task 2 Step 2.

**Placeholder scan:** none. Every code block is verified prototype output. `# TODO:` strings are the intentional exercise stubs. Migration filenames are written `<ts1>`/`<ts2>` because `ecto.gen.migration` stamps them at run time; Task 1 Step 3 prints them.

**Type consistency:** `Tracker.Projects.Project` / `Tracker.Issues.Issue` throughout; `changeset/2` is a private helper in both contexts; `create_*` returns `{:ok, struct} | {:error, changeset}`; `toggle_issue/1` returns the bare struct (`Repo.update!`), which `ProjectBoardLive` relies on; `list_*` returns a list ordered by `id`; the stream stays `:issues` with DOM ids `issues-<id>`; the PubSub payload stays `{:issue, issue}`; databases are `tracker_29_{solutions,exercises}_{test,dev}` in every reference.
