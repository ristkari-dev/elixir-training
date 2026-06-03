# Plan F — Phase 3b-i (Lesson 26 `auth` + database turn-on) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author lesson `26-auth`: turn Postgres on for the threaded Tracker app, generate controller-based authentication with `phx.gen.auth`, add the CI Postgres service, and integrate auth — protect `/projects` and scope projects to the logged-in user.

**Architecture:** Thread Tracker from lesson 25's solution. Reverse the Phase 3a "dormant Repo" recipe (Repo into the supervision tree, restore the ecto `test` alias and the SQL sandbox). Generate controller-based auth **once** in the solution, implement the two drills (route protection + per-user scoping of the in-memory `ProjectStore`), then **derive** the exercise from the finished solution by stubbing the two holes — so both dirs share one generated migration. CI gains a health-checked Postgres service.

**Tech Stack:** Elixir 1.19.5-otp-28 / OTP 29.0.1 (repo `.tool-versions`); Phoenix `~> 1.8` (1.8.7); `phx.gen.auth` 1.8.5; Ecto + Postgrex against Postgres 16; `bcrypt_elixir` (added by the generator); ExUnit with `DataCase`/`ConnCase` + SQL sandbox.

**Spec:** `docs/superpowers/specs/2026-06-02-phase-3b-i-auth-design.md`.

**This plan was prototyped end-to-end against Postgres before being written.** The solution runs 105 tests / 0 failures; the exercise compiles under `--warnings-as-errors`, passes 101/0 with pending excluded, and fails exactly the 4 drill tests with pending included. All code below is verified.

---

## Conventions (read once, apply throughout)

### Repo-root rule
All `tools/*` scripts run from the repo root `/Users/ristkari/code/private/elixir-training`. Per-lesson `mix` commands run inside `lessons/26-auth/exercises` or `.../solutions`.

### Local Postgres for development/verification
A `docker-compose.yml` already exists at the repo root with `postgres:16-alpine` (user/pass `postgres`/`postgres`, db `postgres`, port 5432, health-checked). Bring it up before running any DB-backed `mix test`:

```bash
docker compose up -d postgres
# wait until healthy:
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
```

The generated `config/test.exs` connects to `localhost:5432` as `postgres`/`postgres`, database `tracker_test<PARTITION>` — matching the container.

### Commit style
GPG signing is automatic. Lesson commits use the co-author trailer that matches prior lessons:
```
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```
Infrastructure commits (CI/tooling) use:
```
Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
```

### Module names
The app stays `Tracker` / `TrackerWeb`. The generated auth context is `Tracker.Accounts`; the scope struct is `Tracker.Accounts.Scope` (current user reached as `conn.assigns.current_scope.user`).

### Build order (important)
Generate `phx.gen.auth` **once**, in the solution. Derive the exercise by copying the finished solution and reverting the two drill holes to stubs. This guarantees both dirs share the same generated migration timestamp and identical generated auth. Do **not** run `phx.gen.auth` separately in the exercise.

### Phoenix-era stub convention
Exercise stubs must compile with **zero warnings** under `mix compile --warnings-as-errors`. Where provided code consumes a stubbed function, use typed-placeholder stubs (correct types, wrong/incomplete behavior, a `# TODO:` comment) rather than bare `raise`.

---

## Task 1: Lesson 26 solution — DB turn-on, gen.auth, and the drill

**Files:** scaffold `lessons/26-auth`; replace its `exercises/`+`solutions/` with copies of lesson 25's solution; in `solutions/`: edit `lib/tracker/application.ex`, `mix.exs`, `test/support/conn_case.ex`, `test/test_helper.exs`; run `phx.gen.auth`; edit `lib/tracker_web/router.ex`, `lib/tracker/project_store.ex`, `lib/tracker/projects.ex`, `lib/tracker_web/controllers/project_controller.ex`, `test/tracker_web/controllers/project_controller_test.exs`, `test/tracker/projects_test.exs`.

- [ ] **Step 1: Scaffold and thread from lesson 25**

```bash
cd /Users/ristkari/code/private/elixir-training
tools/new-lesson 26-auth
rm -rf lessons/26-auth/exercises lessons/26-auth/solutions
cp -R lessons/25-contexts/solutions lessons/26-auth/solutions
rm -rf lessons/26-auth/solutions/_build lessons/26-auth/solutions/deps
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
```

(The exercise dir is created in Task 3 by deriving from this finished solution. Leave `lessons/26-auth/exercises` absent for now.)

- [ ] **Step 2: Turn the database on (in `solutions/`)**

Edit `lessons/26-auth/solutions/lib/tracker/application.ex` — add `Tracker.Repo,` to the `children` list immediately after `TrackerWeb.Telemetry,`:

```elixir
    children = [
      TrackerWeb.Telemetry,
      Tracker.Repo,
      {DNSCluster, query: Application.get_env(:tracker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tracker.PubSub},
      Tracker.ProjectStore,
      # Start a worker by calling: Tracker.Worker.start_link(arg)
      # {Tracker.Worker, arg},
      # Start to serve requests, typically the last entry
      TrackerWeb.Endpoint
    ]
```

Edit `lessons/26-auth/solutions/mix.exs` — restore the `test` alias:

```elixir
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
```

Edit `lessons/26-auth/solutions/test/support/conn_case.ex` — restore the sandbox in the `setup` block (change `setup _tags do` back to `setup tags do` and add the `setup_sandbox` line):

```elixir
  setup tags do
    Tracker.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
```

Overwrite `lessons/26-auth/solutions/test/test_helper.exs`:

```elixir
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Tracker.Repo, :manual)
```

- [ ] **Step 3: Generate controller-based auth (once, in `solutions/`)**

```bash
cd lessons/26-auth/solutions
mix deps.get
mix compile
printf 'n\n' | mix phx.gen.auth Accounts User users
mix deps.get
cd /Users/ristkari/code/private/elixir-training
```

The `printf 'n\n'` answers "no" to "Do you want to create a LiveView based authentication system?" — producing **controller-based** auth. The generator injects into `mix.exs` (adds `{:bcrypt_elixir, "~> 3.0"}`), `config/config.exs` (`config :tracker, :scopes, ...`), `config/test.exs` (`config :bcrypt_elixir, :log_rounds, 1`), `test/support/conn_case.ex` (login helpers), `lib/tracker_web/router.ex` (imports `TrackerWeb.UserAuth`, adds `plug :fetch_current_scope_for_user` to `:browser`, and the auth route scopes), and `AGENTS.md`.

- [ ] **Step 4: Create + migrate the test database, confirm the generated baseline is green**

```bash
cd lessons/26-auth/solutions
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate
mix test 2>&1 | tail -n 3
cd /Users/ristkari/code/private/elixir-training
```

Expected: `102 tests, 0 failures` (generated auth suite + the carried lesson-25 project tests). This proves the DB turn-on and gen.auth work end-to-end.

- [ ] **Step 5: Protect the `/projects` routes (drill hole 1, solution)**

In `lessons/26-auth/solutions/lib/tracker_web/router.ex`: the generator left `resources "/projects", ...` inside the unauthenticated `scope "/", TrackerWeb do pipe_through :browser` block. Remove it from there, so that block is just:

```elixir
  scope "/", TrackerWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/ping", PageController, :ping
  end
```

Then add a new authenticated scope. Place it immediately after the generated settings scope (the one ending with `confirm_email`):

```elixir
  scope "/", TrackerWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/projects", ProjectController, only: [:index, :show, :new, :create]
  end
```

(`require_authenticated_user` is the generated `TrackerWeb.UserAuth` plug; it redirects logged-out visitors to `~p"/users/log-in"` with a 302.)

- [ ] **Step 6: Scope the in-memory store and context to the user (drill hole 2, solution)**

Overwrite `lessons/26-auth/solutions/lib/tracker/project_store.ex`:

```elixir
defmodule Tracker.ProjectStore do
  @moduledoc "In-memory project storage backed by an Agent. Replaced by Postgres in lesson 29."
  use Agent

  def start_link(_opts),
    do: Agent.start_link(fn -> %{items: [], next_id: 1} end, name: __MODULE__)

  def list(user_id) do
    __MODULE__
    |> Agent.get(& &1.items)
    |> Enum.filter(&(&1.user_id == user_id))
    |> Enum.reverse()
  end

  def add(user_id, attrs) do
    Agent.get_and_update(__MODULE__, fn %{items: items, next_id: id} ->
      project = attrs |> Map.put(:id, id) |> Map.put(:user_id, user_id)
      {project, %{items: [project | items], next_id: id + 1}}
    end)
  end

  def get(id), do: __MODULE__ |> Agent.get(& &1.items) |> Enum.find(&(&1.id == id))
end
```

Overwrite `lessons/26-auth/solutions/lib/tracker/projects.ex`:

```elixir
defmodule Tracker.Projects do
  @moduledoc "The Projects context: the boundary for project business logic."
  alias Tracker.ProjectStore

  @types %{name: :string, status: :string}

  def list_projects(scope), do: ProjectStore.list(scope.user.id)

  def get_project!(id) do
    ProjectStore.get(id) || raise "no project with id #{inspect(id)}"
  end

  def change_project(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, Map.keys(@types))
    |> Ecto.Changeset.validate_required([:name])
  end

  def create_project(scope, attrs) do
    changeset = change_project(attrs)

    if changeset.valid? do
      attrs = Ecto.Changeset.apply_changes(changeset)
      project = ProjectStore.add(scope.user.id, attrs)
      {:ok, project}
    else
      {:error, %{changeset | action: :insert}}
    end
  end
end
```

Overwrite `lessons/26-auth/solutions/lib/tracker_web/controllers/project_controller.ex`:

```elixir
defmodule TrackerWeb.ProjectController do
  use TrackerWeb, :controller

  alias Tracker.Projects

  def index(conn, _params) do
    render(conn, :index, projects: Projects.list_projects(conn.assigns.current_scope))
  end

  def show(conn, %{"id" => id}) do
    project = Projects.get_project!(String.to_integer(id))
    render(conn, :show, project: project)
  end

  def new(conn, _params) do
    render(conn, :new, form: Phoenix.Component.to_form(Projects.change_project(), as: :project))
  end

  def create(conn, %{"project" => params}) do
    case Projects.create_project(conn.assigns.current_scope, params) do
      {:ok, _project} ->
        conn |> put_flash(:info, "Project created.") |> redirect(to: ~p"/projects")

      {:error, changeset} ->
        render(conn, :new, form: Phoenix.Component.to_form(changeset, as: :project))
    end
  end
end
```

- [ ] **Step 7: Rewrite the project controller test for the authenticated, scoped world (solution)**

Overwrite `lessons/26-auth/solutions/test/tracker_web/controllers/project_controller_test.exs`:

```elixir
defmodule TrackerWeb.ProjectControllerTest do
  # async: false — Tracker.ProjectStore is an app-started singleton shared
  # across tests. Each test logs in a freshly-registered user, so their
  # projects never collide; assert on per-user visibility, not global counts.
  use TrackerWeb.ConnCase, async: false

  alias Tracker.Accounts.Scope
  import Tracker.AccountsFixtures

  describe "unauthenticated access" do
    test "GET /projects redirects to the log-in page", %{conn: conn} do
      conn = get(conn, ~p"/projects")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "authenticated access" do
    setup :register_and_log_in_user

    test "GET /projects renders the projects index", %{conn: conn} do
      conn = get(conn, ~p"/projects")
      assert html_response(conn, 200) =~ "Projects"
    end

    test "GET /projects/new renders the form", %{conn: conn} do
      conn = get(conn, ~p"/projects/new")
      assert html_response(conn, 200) =~ "New project"
    end

    test "POST /projects with valid params redirects and shows the project", %{conn: conn} do
      conn = post(conn, ~p"/projects", project: %{name: "Gemini"})
      assert redirected_to(conn) == ~p"/projects"
      assert recycle(conn) |> get(~p"/projects") |> html_response(200) =~ "Gemini"
    end

    test "POST /projects with a blank name re-renders the form", %{conn: conn} do
      conn = post(conn, ~p"/projects", project: %{name: ""})
      assert html_response(conn, 200) =~ "New project"
    end

    test "a user sees only their own projects", %{conn: conn} do
      other = user_fixture()
      {:ok, _} = Tracker.Projects.create_project(Scope.for_user(other), %{"name" => "OtherSecret"})

      conn = post(conn, ~p"/projects", project: %{name: "MineAlone"})
      body = recycle(conn) |> get(~p"/projects") |> html_response(200)

      assert body =~ "MineAlone"
      refute body =~ "OtherSecret"
    end
  end
end
```

- [ ] **Step 8: Update the Projects context unit test for the scope-based API (solution)**

Overwrite `lessons/26-auth/solutions/test/tracker/projects_test.exs`:

```elixir
defmodule Tracker.ProjectsTest do
  use Tracker.DataCase, async: false

  alias Tracker.Projects
  alias Tracker.Accounts.Scope
  import Tracker.AccountsFixtures

  setup do
    %{scope: Scope.for_user(user_fixture())}
  end

  test "create_project/2 with valid attrs stores and returns it", %{scope: scope} do
    assert {:ok, project} = Projects.create_project(scope, %{"name" => "Apollo"})
    assert project.name == "Apollo"
    assert project.id
    assert project.user_id == scope.user.id
    assert Enum.any?(Projects.list_projects(scope), &(&1.id == project.id))
  end

  test "create_project/2 with a blank name returns an error changeset", %{scope: scope} do
    assert {:error, changeset} = Projects.create_project(scope, %{"name" => ""})
    refute changeset.valid?
  end

  test "list_projects/1 returns only the scope's own projects", %{scope: scope} do
    other = Scope.for_user(user_fixture())
    {:ok, mine} = Projects.create_project(scope, %{"name" => "Mine"})
    {:ok, theirs} = Projects.create_project(other, %{"name" => "Theirs"})

    ids = Enum.map(Projects.list_projects(scope), & &1.id)
    assert mine.id in ids
    refute theirs.id in ids
  end

  test "get_project!/1 raises for a missing id" do
    assert_raise RuntimeError, fn -> Projects.get_project!(999_999) end
  end
end
```

- [ ] **Step 9: Format, then verify the solution is fully green**

```bash
cd lessons/26-auth/solutions
mix format
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
mix test 2>&1 | tail -n 3
cd /Users/ristkari/code/private/elixir-training
```

Expected: compile clean (no warnings); `105 tests, 0 failures`.

- [ ] **Step 10: Commit the solution**

```bash
git add lessons/26-auth/solutions
git status   # confirm NO deps/ _build/ priv/static/assets/ node_modules/ nested .git staged
git commit -m "$(cat <<'EOF'
Add lesson 26-auth solution: database turn-on + scoped auth

Threads Tracker from lesson 25 and switches the database on (Repo into
the supervision tree, ecto steps restored to the test alias, SQL sandbox
restored). Generates controller-based auth via phx.gen.auth (Accounts,
User/UserToken/Scope, session/registration/settings controllers, users
migration). Integrates it: /projects is protected behind
require_authenticated_user, and the in-memory ProjectStore + Projects
context are scoped to current_scope.user so each user sees only their own
projects. Users live in Postgres; projects stay in-memory until lesson 29.

Solution green against Postgres: 105 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Lesson 26 exercise — derive from the solution, stub the two holes

**Files:** create `lessons/26-auth/exercises` as a copy of the finished solution, then revert the two drill holes to stubs and re-tag the drill tests `@tag :pending`.

- [ ] **Step 1: Derive the exercise from the finished solution**

```bash
cd /Users/ristkari/code/private/elixir-training
cp -R lessons/26-auth/solutions lessons/26-auth/exercises
rm -rf lessons/26-auth/exercises/_build lessons/26-auth/exercises/deps
```

This carries the identical generated auth + migration (same timestamp) into the exercise.

- [ ] **Step 2: Set the exercise test_helper to exclude pending**

Overwrite `lessons/26-auth/exercises/test/test_helper.exs`:

```elixir
ExUnit.start(exclude: [pending: true])
Ecto.Adapters.SQL.Sandbox.mode(Tracker.Repo, :manual)
```

- [ ] **Step 3: Revert hole 1 — leave `/projects` in the public scope**

In `lessons/26-auth/exercises/lib/tracker_web/router.ex`: remove the authenticated projects scope added in Task 1 Step 5, and put `resources "/projects"` back in the public `:browser` scope. The public scope becomes:

```elixir
  scope "/", TrackerWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/ping", PageController, :ping
    resources "/projects", ProjectController, only: [:index, :show, :new, :create]
  end
```

and the authenticated scope block (`pipe_through [:browser, :require_authenticated_user]` containing the projects resources) is deleted. (Leave the generated settings auth scope intact.)

- [ ] **Step 4: Revert hole 2 — `ProjectStore` ignores the user (typed-placeholder stubs)**

Overwrite `lessons/26-auth/exercises/lib/tracker/project_store.ex`:

```elixir
defmodule Tracker.ProjectStore do
  @moduledoc "In-memory project storage backed by an Agent. Replaced by Postgres in lesson 29."
  use Agent

  def start_link(_opts),
    do: Agent.start_link(fn -> %{items: [], next_id: 1} end, name: __MODULE__)

  # TODO: return only the projects whose :user_id matches user_id.
  def list(_user_id) do
    __MODULE__ |> Agent.get(& &1.items) |> Enum.reverse()
  end

  # TODO: store the project with its :user_id so list/1 can filter by owner.
  def add(_user_id, attrs) do
    Agent.get_and_update(__MODULE__, fn %{items: items, next_id: id} ->
      project = Map.put(attrs, :id, id)
      {project, %{items: [project | items], next_id: id + 1}}
    end)
  end

  def get(id), do: __MODULE__ |> Agent.get(& &1.items) |> Enum.find(&(&1.id == id))
end
```

Leave `lib/tracker/projects.ex` and `lib/tracker_web/controllers/project_controller.ex` as the provided (solution) versions — they delegate `scope.user.id` into the store, showing the learner the boundary plumbing; the drill is implementing the store's scoping and protecting the route.

- [ ] **Step 5: Tag the four drill tests `@tag :pending` in the exercise**

In `lessons/26-auth/exercises/test/tracker_web/controllers/project_controller_test.exs`, add `@tag :pending` directly above these two tests:
- `test "GET /projects redirects to the log-in page", %{conn: conn} do`
- `test "a user sees only their own projects", %{conn: conn} do`

In `lessons/26-auth/exercises/test/tracker/projects_test.exs`, add `@tag :pending` directly above these two tests:
- `test "create_project/2 with valid attrs stores and returns it", %{scope: scope} do`
- `test "list_projects/1 returns only the scope's own projects", %{scope: scope} do`

(The other tests — `GET /projects renders the index`, `GET /projects/new`, both `POST` tests, `create_project blank name`, `get_project!` raises — stay un-tagged: they pass in the exercise because `/projects` is reachable, the store still stores/lists, and validation is unchanged.)

- [ ] **Step 6: Format and verify exercise behavior**

```bash
cd lessons/26-auth/exercises
mix deps.get
MIX_ENV=test mix ecto.create
mix format
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
echo "--- pending EXCLUDED (must be 0 failures) ---"
mix test 2>&1 | tail -n 3
echo "--- pending INCLUDED (must fail exactly the 4 drill tests) ---"
mix test --include pending 2>&1 | tail -n 3
cd /Users/ristkari/code/private/elixir-training
```

Expected: compile clean (no warnings); pending excluded → `101 tests, 0 failures (4 excluded)`; pending included → `105 tests, 4 failures`.

- [ ] **Step 7: Commit the exercise**

```bash
git add lessons/26-auth/exercises
git status   # confirm no build artifacts / nested .git staged
git commit -m "$(cat <<'EOF'
Add lesson 26-auth exercise: protect + scope drills

Derived from the lesson-26 solution (identical generated auth + migration),
with the two integration drills reverted to stubs: the /projects routes
sit in the public scope (learner moves them behind
require_authenticated_user), and ProjectStore.list/add ignore the user_id
(learner adds the owner filter + storage). The four drill tests are
@tag :pending; everything else (generated auth suite + carried project
tests) passes. Exercise compiles warning-free and runs against Postgres.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Lesson 26 prose — README, HINTS, slides

**Files:** `lessons/26-auth/README.md`, `lessons/26-auth/HINTS.md`, `lessons/26-auth/slides/slides.md` (the scaffolder created these; author them now). Read `lessons/25-contexts/README.md`, `lessons/24-forms-and-changesets-preview/HINTS.md`, and `lessons/25-contexts/slides/slides.md` for house style first.

- [ ] **Step 1: Author `README.md`**

Sections:
1. Title + intro: by the end you'll have a real `users` table in Postgres, a working register/log-in/log-out/settings flow (generated), `/projects` protected behind login, and each user seeing only their own projects.
2. **The database, switched on.** Lesson 22 generated a database layer and kept it *dormant*; this lesson switches it on — `Tracker.Repo` joins the supervision tree, `mix test` now runs `ecto.create` + `ecto.migrate`, and tests run inside a transaction the SQL sandbox rolls back. You need Postgres running (`docker compose up -d postgres` from the repo root; `mix ecto.setup` to create+migrate locally).
3. **`mix phx.gen.auth` (controller-based).** What it generates: the `Accounts` context, `User`/`UserToken`/`UserNotifier`, the users migration, and session/registration/settings **controllers** (we chose the controller-based option, not LiveView — LiveView is lesson 27). Mention that re-running locally needs `mix deps.get` (it adds `bcrypt_elixir`) and `mix ecto.migrate`.
4. **Scopes (`current_scope`).** New in Phoenix 1.8: the `:browser` pipeline runs `fetch_current_scope_for_user`, putting a `Tracker.Accounts.Scope` on `conn.assigns.current_scope`. The logged-in user is `current_scope.user` (not a bare `current_user`). Contexts take a `scope` so they can enforce ownership.
5. **Protecting routes.** `require_authenticated_user` is a generated plug; routes under a scope that `pipe_through [:browser, :require_authenticated_user]` redirect logged-out visitors to `~p"/users/log-in"`.
6. **The drills.** (a) Move the `/projects` routes behind `require_authenticated_user`. (b) Scope `Tracker.ProjectStore` to the owner: `list/1` returns only that user's projects, `add/2` records the `:user_id`. The `Projects` context and controller already pass `current_scope` through for you.
7. **Why projects are still in memory.** Users need persistence now (you can't log in to an in-memory account), but projects stay in the `ProjectStore` Agent — a deliberate bridge. Lesson 29 moves projects to Postgres behind the same context API.
8. **Common mistakes:** forgetting `docker compose up` so the DB connection fails; expecting `current_user` instead of `current_scope.user`; asserting on a global project count in tests (the in-memory store persists across tests — assert per-user visibility instead).
9. **Links:** [phx.gen.auth](https://hexdocs.pm/phoenix/mix_phx_gen_auth.html), [Ecto.Adapters.SQL.Sandbox](https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.Sandbox.html), [Phoenix — security/auth overview](https://hexdocs.pm/phoenix/authentication.html).

- [ ] **Step 2: Author `HINTS.md`** — two drill sections:
  - *Drill 1 (protect the route):* (1) the generated router already has a scope that does `pipe_through [:browser, :require_authenticated_user]`; (2) move `resources "/projects"` into a scope with that pipeline; (3) show the exact authenticated `scope` block.
  - *Drill 2 (scope the store):* (1) `list/1` should filter items by the passed `user_id`; `add/2` should record `:user_id` on the stored map; (2) show the `Enum.filter(&(&1.user_id == user_id))` and the `Map.put(:user_id, user_id)`; (3) show the full `list/1` and `add/2`.

- [ ] **Step 3: Author `slides/slides.md`** — replace the template. ~5 blocks (`---`/`--` separators): title; "The database, switched on (dormant → live)"; "phx.gen.auth — what it builds (controller-based)"; "Scopes: current_scope.user"; "The drills: protect /projects + scope the store". Closer → "Next: lesson 27 — LiveView" with `make slides-dev LESSON=27-liveview-1`.

- [ ] **Step 4: Verify slides publish and commit**

```bash
cd /Users/ristkari/code/private/elixir-training
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist >/dev/null 2>&1 && grep -c "lessons/26-auth/slides/" dist/index.html && rm -rf dist
git add lessons/26-auth/README.md lessons/26-auth/HINTS.md lessons/26-auth/slides
git commit -m "$(cat <<'EOF'
Add lesson 26-auth prose: README, HINTS, slides

Explains the database turn-on (dormant -> live, SQL sandbox), what
controller-based phx.gen.auth generates, the 1.8 Scope/current_scope
pattern, route protection, and the two drills (protect /projects, scope
the in-memory store to the owner). Frames the Postgres-users /
in-memory-projects hybrid as the bridge to lesson 29.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: build_index prints `1`.

---

## Task 4: CI Postgres service

**Files:** `.github/workflows/ci.yml`.

- [ ] **Step 1: Add a Postgres service to the `build` job**

Edit `.github/workflows/ci.yml`. Under `jobs.build`, add a `services:` block (sibling of `runs-on:` and `steps:`):

```yaml
jobs:
  build:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U postgres"
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10

    steps:
      - uses: actions/checkout@v6
      # ... existing steps unchanged ...
```

The generated `config/test.exs` connects to `localhost:5432` as `postgres`/`postgres`, which the mapped service port satisfies. Lesson 26's restored `test` alias runs `ecto.create`/`ecto.migrate` against it; lessons 0–25 declare no Repo and ignore it.

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "$(cat <<'EOF'
ci: add Postgres service for the database-backed lessons

Lesson 26 (auth) is the first lesson with a live Ecto Repo: its test
alias creates and migrates a database, and ConnCase/DataCase run inside
the SQL sandbox. Add a health-checked postgres:16-alpine service to the
build job (postgres/postgres on localhost:5432, matching the generated
config/test.exs). Lessons without a Repo ignore it.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
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

Expected: all green. `make test` (exercises, pending excluded) and `make solutions-test` (solutions, incl. pending) both create+migrate lesson 26's DB against the container and pass. Note: `make test`/`make solutions-test` will run `ecto.create`/`ecto.migrate` for lesson 26 — that needs the container up.

- [ ] **Step 2: Confirm all 27 lessons publish**

```bash
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules \
         04-control-flow 05-recursion 06-enum-and-the-pipe 07-collections \
         08-strings-and-binaries 09-streams 10-structs-and-protocols 11-error-handling \
         12-mix-projects 13-processes 14-tasks-and-agents 15-genserver-1 16-genserver-2 \
         17-supervisors 18-otp-applications 19-ets 20-distribution 21-plug \
         22-phoenix-tour 23-controllers-and-heex 24-forms-and-changesets-preview 25-contexts \
         26-auth; do
  grep -q "lessons/$n/slides/" dist/index.html && echo "$n: ok" || echo "$n: MISSING"
done | grep -c ok
echo "(expected 27)"
rm -rf dist
```

- [ ] **Step 3: Push the branch and open the PR**

```bash
git push -u origin plan-f-phase-3b-i
gh pr create --base main --head plan-f-phase-3b-i \
  --title "Plan F: Phase 3b-i lesson 26 auth + database turn-on" \
  --body "$(cat <<'EOF'
## Summary
- Implements [Plan F](docs/superpowers/plans/2026-06-03-plan-f-phase-3b-i-auth.md) — lesson 26 (`auth`), the database-establishing lesson.
- Turns Postgres on for Tracker (reverses the 3a dormant-Repo recipe), generates controller-based auth via `phx.gen.auth`, and adds the **CI Postgres service**.
- Integrates auth: `/projects` is protected behind login, and the in-memory `ProjectStore`/`Projects` are scoped to `current_scope.user`. Users live in Postgres; projects stay in-memory until lesson 29.

## What shipped
- **26-auth** (2 drills, DB-backed): protect `/projects` behind `require_authenticated_user`; scope the in-memory store to the owner (`list/1` filters by user, `add/2` records `:user_id`). Generated auth committed wholesale as provided code.
- First lesson with a live Repo: `DataCase`/`ConnCase` + SQL sandbox; CI gains a health-checked `postgres:16-alpine` service.

## Notes
- Controller-based auth (declined the LiveView prompt) keeps the bottom-up arc — LiveView is introduced fresh in lesson 27.
- Generated auth once in the solution; the exercise is derived from it (shared migration). Exercise compiles warning-free; pending-excluded green; the 4 drill tests fail until implemented.

## Test plan
- [ ] CI green **with the Postgres service** (ci-smoke, lint, exercises, solutions, slides-build, dist).
- [ ] After merge, Deploy republishes the slide site with lesson 26.
- [ ] Locally: `docker compose up -d postgres`, then `cd lessons/26-auth/solutions && mix ecto.setup && mix phx.server`, register at `/users/register`, log in, add a project at `/projects/new`.

Local pipeline green against Postgres: solution 105 tests / 0 failures; exercise 101/0 pending-excluded, 4 drill tests fail with pending.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 4: Watch CI; merge after green + approval**

```bash
gh pr checks <PR_NUMBER> --watch
```

If green and approved: `gh pr merge --squash --delete-branch` → triggers Deploy. (Leave the merge to the human, per prior phases.)

---

## Self-review checklist (applied)

**Spec coverage:** every spec section maps to a task. Database turn-on → Task 1 Step 2. CI Postgres service → Task 4. Controller-based gen.auth → Task 1 Step 3. Drill (protect + scope) → Task 1 Steps 5–6 (solution), Task 2 Steps 3–4 (exercise stubs). Generated-auth-green + DataCase/ConnCase/sandbox → Task 1 Steps 4 & 9. Test-isolation caveat (in-memory store, fresh per-test user, `async: false`) → encoded in the test files (Task 1 Steps 7–8) and README (Task 3). Threading from lesson 25 / generate-once-derive-exercise → Tasks 1 & 2. Prose → Task 3. Final smoke + all-lessons-publish + PR → Task 5.

**Placeholder scan:** none. Every code block is the verified prototype output. `# TODO:` strings are intentional exercise stubs. The migration filename is intentionally not hardcoded (the generator stamps a timestamp; both dirs share it because the exercise is copied from the solution).

**Type consistency:** signatures are consistent across tasks and dirs — `ProjectStore.list/1` (user_id), `ProjectStore.add/2` (user_id, attrs), `ProjectStore.get/1`; `Projects.list_projects/1` (scope), `Projects.create_project/2` (scope, attrs), `Projects.get_project!/1`, `Projects.change_project/1`; controller reads `conn.assigns.current_scope`; tests use `Tracker.Accounts.Scope.for_user/1`, `register_and_log_in_user`, `user_fixture/0`. The solution defines these (Task 1); the exercise reverts only the two holes (Task 2) and provides the same `Projects`/controller.
