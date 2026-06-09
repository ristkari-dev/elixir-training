# Plan G — Phase 3b-ii (Lesson 27 `liveview-1`) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author lesson `27-liveview-1`: introduce LiveView via a live issue board for a project (`mount`/`render`/`handle_event`), backed by a new in-memory `Issue` concept, with LiveView auth wired (`live_session` + `on_mount`).

**Architecture:** Thread Tracker from lesson 26's solution. Add `Tracker.IssueStore` (Agent) + `Tracker.Issues` (context), a small `on_mount` hook on `TrackerWeb.UserAuth` (lesson 26's controller-based auth generated none), and `TrackerWeb.ProjectBoardLive` at `live "/projects/:id/board"` inside an authenticated `live_session`. The drill is the two `handle_event` callbacks (add issue, toggle status); the exercise is derived from the finished solution by stubbing those two callbacks and tagging their two `LiveViewTest` tests `@tag :pending`.

**Tech Stack:** Elixir 1.19.5-otp-28 / OTP 29.0.1; Phoenix `~> 1.8` (1.8.7); `phoenix_live_view ~> 1.1`; Ecto/Postgres (auth only); `Phoenix.LiveViewTest`. No new Hex deps — LiveView and the `/live` socket are already in the app.

**Spec:** `docs/superpowers/specs/2026-06-07-phase-3b-ii-liveview-1-design.md`.

**This plan was prototyped end-to-end against Postgres + a live socket before being written.** The solution runs **113 tests / 0 failures**; the exercise compiles under `--warnings-as-errors`, passes **111** with the 2 drill tests excluded, and fails exactly **2** with pending included. All code below is verified and `mix format`-clean.

---

## Conventions (read once, apply throughout)

### Repo-root rule
All `tools/*` scripts run from the repo root `/Users/ristkari/code/private/elixir-training`. Per-lesson `mix` commands run inside `lessons/27-liveview-1/exercises` or `.../solutions`.

### Local Postgres (required — auth tests are DB-backed)
Bring up the existing compose service before any DB-backed `mix test`:

```bash
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
```

### Commit style
GPG signing is automatic. Lesson commits use:
```
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

### Module names
App stays `Tracker` / `TrackerWeb`. New modules: `Tracker.IssueStore`, `Tracker.Issues`, `TrackerWeb.ProjectBoardLive`.

### Build order
Build the full solution first (Task 1), then derive the exercise (Task 2) by reverting only the two `handle_event` callbacks to stubs and tagging their two tests pending. Everything else is identical across the two dirs.

### Phoenix-era stub convention
Exercise stubs compile with zero warnings under `mix compile --warnings-as-errors`. The two `handle_event` stubs are typed-placeholder no-ops (`{:noreply, socket}`) with `# TODO:` comments — never bare `raise` (LiveView invokes the callbacks).

---

## Task 1: Lesson 27 solution

**Files:** scaffold `lessons/27-liveview-1`; copy lesson 26's solution into `solutions/`; add `lib/tracker/issue_store.ex`, `lib/tracker/issues.ex`, `lib/tracker_web/live/project_board_live.ex`; edit `lib/tracker/application.ex`, `lib/tracker_web/user_auth.ex`, `lib/tracker_web/router.ex`, `lib/tracker_web/controllers/project_html/show.html.heex`; add `test/tracker/issues_test.exs`, `test/tracker_web/live/project_board_live_test.exs`.

- [ ] **Step 1: Scaffold and thread from lesson 26**

```bash
cd /Users/ristkari/code/private/elixir-training
tools/new-lesson 27-liveview-1
rm -rf lessons/27-liveview-1/exercises lessons/27-liveview-1/solutions
cp -R lessons/26-auth/solutions lessons/27-liveview-1/solutions
rm -rf lessons/27-liveview-1/solutions/_build lessons/27-liveview-1/solutions/deps
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
mkdir -p lessons/27-liveview-1/solutions/lib/tracker_web/live
```

Leave `lessons/27-liveview-1/exercises` ABSENT (Task 2 derives it). The scaffolder created `lessons/27-liveview-1/{README.md,HINTS.md,slides/}` — leave those for Task 3.

- [ ] **Step 2: Create `Tracker.IssueStore`**

`lessons/27-liveview-1/solutions/lib/tracker/issue_store.ex`:

```elixir
defmodule Tracker.IssueStore do
  @moduledoc "In-memory issue storage backed by an Agent. Replaced by Postgres in lesson 29."
  use Agent

  def start_link(_opts),
    do: Agent.start_link(fn -> %{items: [], next_id: 1} end, name: __MODULE__)

  def list(project_id) do
    __MODULE__
    |> Agent.get(& &1.items)
    |> Enum.filter(&(&1.project_id == project_id))
    |> Enum.reverse()
  end

  def add(project_id, attrs) do
    Agent.get_and_update(__MODULE__, fn %{items: items, next_id: id} ->
      issue =
        attrs
        |> Map.put(:id, id)
        |> Map.put(:project_id, project_id)
        |> Map.put_new(:status, "open")

      {issue, %{items: [issue | items], next_id: id + 1}}
    end)
  end

  def toggle(id) do
    Agent.get_and_update(__MODULE__, fn %{items: items} = state ->
      items =
        Enum.map(items, fn
          %{id: ^id} = issue -> %{issue | status: flip(issue.status)}
          issue -> issue
        end)

      {Enum.find(items, &(&1.id == id)), %{state | items: items}}
    end)
  end

  def get(id), do: __MODULE__ |> Agent.get(& &1.items) |> Enum.find(&(&1.id == id))

  defp flip("open"), do: "closed"
  defp flip(_), do: "open"
end
```

- [ ] **Step 3: Create the `Tracker.Issues` context**

`lessons/27-liveview-1/solutions/lib/tracker/issues.ex`:

```elixir
defmodule Tracker.Issues do
  @moduledoc "The Issues context: the boundary for issue business logic."
  alias Tracker.IssueStore

  @types %{title: :string, status: :string}

  def list_issues(project_id), do: IssueStore.list(project_id)

  def change_issue(attrs \\ %{}) do
    {%{status: "open"}, @types}
    |> Ecto.Changeset.cast(attrs, [:title])
    |> Ecto.Changeset.validate_required([:title])
  end

  def create_issue(project_id, attrs) do
    changeset = change_issue(attrs)

    if changeset.valid? do
      issue = changeset |> Ecto.Changeset.apply_changes() |> then(&IssueStore.add(project_id, &1))
      {:ok, issue}
    else
      {:error, %{changeset | action: :insert}}
    end
  end

  def toggle_issue(id), do: IssueStore.toggle(id)
end
```

- [ ] **Step 4: Start `IssueStore` in the supervision tree**

In `lessons/27-liveview-1/solutions/lib/tracker/application.ex`, add `Tracker.IssueStore,` to the `children` list immediately after `Tracker.ProjectStore,`:

```elixir
      Tracker.ProjectStore,
      Tracker.IssueStore,
```

- [ ] **Step 5: Add the LiveView auth `on_mount` hook to `UserAuth`**

In `lessons/27-liveview-1/solutions/lib/tracker_web/user_auth.ex`, add these two functions just before the final `end` of the module (the module already has `use TrackerWeb, :verified_routes`, `alias Tracker.Accounts`, and `alias Tracker.Accounts.Scope`, so `~p`, `Accounts`, and `Scope` are available):

```elixir
  @doc """
  Handles mounting and authenticating the current_scope in LiveViews.

  Used by `live_session` in the router:

      live_session :require_authenticated,
        on_mount: [{TrackerWeb.UserAuth, :require_authenticated}] do
        ...
      end
  """
  def on_mount(:require_authenticated, _params, session, socket) do
    socket = mount_current_scope(socket, session)

    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/users/log-in")

      {:halt, socket}
    end
  end

  defp mount_current_scope(socket, session) do
    Phoenix.Component.assign_new(socket, :current_scope, fn ->
      with token when is_binary(token) <- session["user_token"],
           {user, _} <- Accounts.get_user_by_session_token(token) do
        Scope.for_user(user)
      else
        _ -> nil
      end
    end)
  end
```

(`Accounts.get_user_by_session_token/1` returns `{user, inserted_at}` or `nil`, hence the `{user, _}` match. The session key is the string `"user_token"`.)

- [ ] **Step 6: Create `ProjectBoardLive`**

`lessons/27-liveview-1/solutions/lib/tracker_web/live/project_board_live.ex`:

```elixir
defmodule TrackerWeb.ProjectBoardLive do
  use TrackerWeb, :live_view

  alias Tracker.{Projects, Issues}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    project = Projects.get_project!(String.to_integer(id))

    if project.user_id == socket.assigns.current_scope.user.id do
      {:ok, assign_board(socket, project)}
    else
      {:ok,
       socket
       |> put_flash(:error, "That project isn't yours.")
       |> redirect(to: ~p"/projects")}
    end
  end

  defp assign_board(socket, project) do
    socket
    |> assign(:project, project)
    |> assign(:issues, Issues.list_issues(project.id))
    |> assign(:form, to_form(Issues.change_issue(), as: :issue))
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@project.name} — board</.header>

      <.form for={@form} phx-submit="add_issue">
        <.input field={@form[:title]} label="New issue" />
        <.button>Add</.button>
      </.form>

      <ul id="issues">
        <li :for={issue <- @issues} id={"issue-#{issue.id}"}>
          <span class="title">{issue.title}</span>
          <span class="status">{issue.status}</span>
          <button phx-click="toggle" phx-value-id={issue.id}>Toggle</button>
        </li>
      </ul>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("add_issue", %{"issue" => params}, socket) do
    case Issues.create_issue(socket.assigns.project.id, params) do
      {:ok, _issue} ->
        {:noreply, assign_board(socket, socket.assigns.project)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :issue))}
    end
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    Issues.toggle_issue(String.to_integer(id))
    {:noreply, assign(socket, :issues, Issues.list_issues(socket.assigns.project.id))}
  end
end
```

- [ ] **Step 7: Add the live route inside an authenticated `live_session`**

In `lessons/27-liveview-1/solutions/lib/tracker_web/router.ex`, immediately after the authenticated projects scope (the `scope` block whose only route is `resources "/projects", ...` under `pipe_through [:browser, :require_authenticated_user]`), add:

```elixir
  live_session :require_authenticated,
    on_mount: [{TrackerWeb.UserAuth, :require_authenticated}] do
    scope "/", TrackerWeb do
      pipe_through [:browser, :require_authenticated_user]

      live "/projects/:id/board", ProjectBoardLive
    end
  end
```

- [ ] **Step 8: Link the board from the project show page**

Overwrite `lessons/27-liveview-1/solutions/lib/tracker_web/controllers/project_html/show.html.heex`:

```heex
<Layouts.app flash={@flash}>
  <.header>{@project.name}</.header>
  <p>Status: {@project.status}</p>
  <.button navigate={~p"/projects/#{@project.id}/board"}>Open board</.button>
</Layouts.app>
```

- [ ] **Step 9: Add the `Tracker.Issues` context test**

`lessons/27-liveview-1/solutions/test/tracker/issues_test.exs`:

```elixir
defmodule Tracker.IssuesTest do
  use Tracker.DataCase, async: false

  alias Tracker.Issues

  test "create_issue/2 with a title stores an open issue" do
    assert {:ok, issue} = Issues.create_issue(1, %{"title" => "Write tests"})
    assert issue.title == "Write tests"
    assert issue.status == "open"
    assert issue.project_id == 1
  end

  test "create_issue/2 with a blank title returns an error changeset" do
    assert {:error, changeset} = Issues.create_issue(1, %{"title" => ""})
    refute changeset.valid?
  end

  test "list_issues/1 returns only that project's issues" do
    {:ok, a} = Issues.create_issue(101, %{"title" => "A"})
    {:ok, b} = Issues.create_issue(102, %{"title" => "B"})

    ids = Enum.map(Issues.list_issues(101), & &1.id)
    assert a.id in ids
    refute b.id in ids
  end

  test "toggle_issue/1 flips status" do
    {:ok, issue} = Issues.create_issue(1, %{"title" => "Toggle me"})
    assert Issues.toggle_issue(issue.id).status == "closed"
    assert Issues.toggle_issue(issue.id).status == "open"
  end
end
```

- [ ] **Step 10: Add the `ProjectBoardLive` test**

`lessons/27-liveview-1/solutions/test/tracker_web/live/project_board_live_test.exs`:

```elixir
defmodule TrackerWeb.ProjectBoardLiveTest do
  # async: false — IssueStore/ProjectStore are app-started singletons whose
  # state does not roll back with the SQL sandbox. Each test makes a fresh
  # user + project; assertions target a specific issue by id, never "the only
  # element on the board".
  use TrackerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import Tracker.AccountsFixtures

  alias Tracker.Accounts.Scope

  defp create_project(user) do
    {:ok, project} = Tracker.Projects.create_project(Scope.for_user(user), %{"name" => "Apollo"})
    project
  end

  test "redirects to log in when not authenticated", %{conn: conn} do
    user = user_fixture()
    project = create_project(user)

    assert {:error, {:redirect, %{to: path}}} = live(conn, ~p"/projects/#{project.id}/board")
    assert path == ~p"/users/log-in"
  end

  describe "as the owner" do
    setup :register_and_log_in_user

    test "adding an issue shows it on the board", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")

      html = view |> form("form", issue: %{title: "Fix login"}) |> render_submit()
      assert html =~ "Fix login"
    end

    test "toggling an issue flips its status", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, issue} = Tracker.Issues.create_issue(project.id, %{"title" => "Ship it"})
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert has_element?(view, "#issue-#{issue.id} .status", "open")

      view |> element("#issue-#{issue.id} button[phx-click=toggle]") |> render_click()
      assert has_element?(view, "#issue-#{issue.id} .status", "closed")
    end

    test "cannot open another user's board", %{conn: conn} do
      other = user_fixture()
      project = create_project(other)

      assert {:error, {:redirect, %{to: "/projects"}}} =
               live(conn, ~p"/projects/#{project.id}/board")
    end
  end
end
```

- [ ] **Step 11: Format and verify the solution is fully green**

```bash
cd lessons/27-liveview-1/solutions
mix deps.get
mix format
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
mix test 2>&1 | tail -n 3
cd /Users/ristkari/code/private/elixir-training
```

Expected: compile clean (no warnings); `113 tests, 0 failures` (105 carried from lesson 26 + 4 Issues context + 4 ProjectBoardLive). `mix test` creates+migrates the DB via the inherited alias.

- [ ] **Step 12: Commit the solution**

```bash
git add lessons/27-liveview-1/solutions
git status   # confirm NO deps/ _build/ priv/static/assets/ node_modules/ nested .git staged; mix.lock SHOULD be staged
git commit -m "$(cat <<'EOF'
Add lesson 27-liveview-1 solution: the live issue board

Threads Tracker from lesson 26 and introduces LiveView. Adds an in-memory
Issue concept (Tracker.IssueStore Agent + Tracker.Issues context) and a
ProjectBoardLive at /projects/:id/board: mount loads the owner's project
and its issues; handle_event("add_issue") and handle_event("toggle")
update the board live in one tab. Because lesson 26 generated
controller-based auth (no on_mount), a small on_mount hook is added to
UserAuth and the live route runs inside live_session :require_authenticated.
Issues stay in memory until lesson 29; streams/PubSub/comments are lesson 28.

Solution green against Postgres: 113 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Lesson 27 exercise — derive and stub the two callbacks

**Files:** create `lessons/27-liveview-1/exercises` as a copy of the finished solution, then stub the two `handle_event` callbacks and tag the two LiveView interaction tests pending.

- [ ] **Step 1: Derive the exercise from the finished solution**

```bash
cd /Users/ristkari/code/private/elixir-training
cp -R lessons/27-liveview-1/solutions lessons/27-liveview-1/exercises
rm -rf lessons/27-liveview-1/exercises/_build lessons/27-liveview-1/exercises/deps
```

- [ ] **Step 2: Set the exercise test_helper to exclude pending**

Overwrite `lessons/27-liveview-1/exercises/test/test_helper.exs`:

```elixir
ExUnit.start(exclude: [pending: true])
Ecto.Adapters.SQL.Sandbox.mode(Tracker.Repo, :manual)
```

- [ ] **Step 3: Stub the two `handle_event` callbacks**

In `lessons/27-liveview-1/exercises/lib/tracker_web/live/project_board_live.ex`, replace the two `handle_event` clauses with typed-placeholder no-ops:

```elixir
  @impl true
  def handle_event("add_issue", %{"issue" => _params}, socket) do
    # TODO: create the issue with Issues.create_issue(socket.assigns.project.id, params);
    # on {:ok, _} re-assign the board, on {:error, changeset} re-assign the form.
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle", %{"id" => _id}, socket) do
    # TODO: Issues.toggle_issue(String.to_integer(id)), then re-assign :issues
    # from Issues.list_issues(socket.assigns.project.id).
    {:noreply, socket}
  end
```

(Leave `mount`, `render`, `assign_board`, `IssueStore`, `Issues`, the `on_mount` hook, the route, and the show link as the provided solution versions.)

- [ ] **Step 4: Tag the two LiveView interaction tests `@tag :pending`**

In `lessons/27-liveview-1/exercises/test/tracker_web/live/project_board_live_test.exs`, add `@tag :pending` directly above these two tests:
- `test "adding an issue shows it on the board", %{conn: conn, user: user} do`
- `test "toggling an issue flips its status", %{conn: conn, user: user} do`

(Leave the `redirects to log in` and `cannot open another user's board` tests and the entire `Tracker.IssuesTest` un-tagged — they pass in the exercise because auth and the context are provided.)

- [ ] **Step 5: Format and verify exercise behavior**

```bash
cd lessons/27-liveview-1/exercises
mix deps.get
mix format
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
echo "--- pending EXCLUDED (must be 0 failures) ---"
mix test 2>&1 | tail -n 3
echo "--- pending INCLUDED (must fail exactly the 2 drill tests) ---"
mix test --include pending 2>&1 | tail -n 3
cd /Users/ristkari/code/private/elixir-training
```

Expected: compile clean (no warnings); pending excluded → `111 tests, 0 failures (2 excluded)`; pending included → `113 tests, 2 failures` (the add-issue and toggle tests).

- [ ] **Step 6: Commit the exercise**

```bash
git add lessons/27-liveview-1/exercises
git status   # confirm no build artifacts / nested .git staged
git commit -m "$(cat <<'EOF'
Add lesson 27-liveview-1 exercise: the handle_event drills

Derived from the lesson-27 solution, with the two handle_event callbacks
reverted to typed-placeholder no-op stubs: add_issue and toggle return
{:noreply, socket} without touching the board (each with a # TODO). The
mount/render, IssueStore, Issues context, on_mount auth, route, and show
link are all provided. The two LiveViewTest interaction tests are
@tag :pending; the auth-redirect, not-yours, and Issues context tests
pass. Exercise compiles warning-free and runs against Postgres.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Lesson 27 prose — README, HINTS, slides

**Files:** `lessons/27-liveview-1/README.md`, `HINTS.md`, `slides/slides.md`. Read `lessons/26-auth/README.md`, `lessons/25-contexts/HINTS.md`, and `lessons/26-auth/slides/slides.md` for house style first.

- [ ] **Step 1: Author `README.md`**

Sections:
1. Title + intro: by the end you'll have a live issue board for a project — list, add, and toggle issues live in one tab, no page reload — your first LiveView.
2. **What LiveView is.** A stateful process per connection: the first request renders HTML over HTTP (the "dead" render), then a websocket connects and the same LiveView keeps running on the server, re-rendering and pushing only diffs in response to events. Tie to Phase 2: "a LiveView is a process — like a GenServer — that holds your page's state."
3. **The lifecycle:** `mount/3` (set up `socket.assigns`), `render/1` (HEEx from assigns), `handle_event/3` (respond to `phx-` events, return `{:noreply, assign(...)}`). The page re-renders from assigns after every event.
4. **A new in-memory `Issue`.** `Tracker.IssueStore` (an Agent like `ProjectStore`) + `Tracker.Issues` (the context boundary). Issues belong to a project; they stay in memory until lesson 29 — same build-then-persist bridge as projects.
5. **LiveView auth (provided).** Lesson 26 generated controller-based auth, so there was no `on_mount` hook. We added one to `UserAuth`: the websocket mount can't read `conn.assigns`, so `on_mount` reads the session's `user_token` and assigns `current_scope` to the socket (redirecting to log in if absent). The board route lives in `live_session :require_authenticated, on_mount: [...]`. This is provided — study it as "how a LiveView knows who's logged in."
6. **The drills.** Implement the two `handle_event` callbacks in `ProjectBoardLive`: `"add_issue"` (create the issue, re-assign the board / re-render the form on error) and `"toggle"` (flip the issue's status, re-assign the list). `mount`/`render` and the context are provided.
7. **Common mistakes:** forgetting `docker compose up` (auth tests need the DB); returning the wrong shape from `handle_event` (must be `{:noreply, socket}`); expecting `current_user` instead of `current_scope.user`; in tests, selecting "the only button" when the in-memory store has leftover issues — target a specific `#issue-<id>` element.
8. **Links:** [Phoenix.LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html), [LiveView — bindings (`phx-click`/`phx-submit`)](https://hexdocs.pm/phoenix_live_view/bindings.html), [Phoenix.LiveViewTest](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html).

- [ ] **Step 2: Author `HINTS.md`** — two drill sections:
  - *Drill 1 (`add_issue`):* (1) the form submits `%{"issue" => params}`; call `Issues.create_issue(socket.assigns.project.id, params)`; (2) on `{:ok, _}` re-assign the board (issues + a fresh form), on `{:error, changeset}` re-assign the form so errors show; (3) show the full clause (the `case` + `assign_board` / `to_form(changeset, as: :issue)`).
  - *Drill 2 (`toggle`):* (1) the button sends `phx-value-id`, arriving as `%{"id" => id}` (a string); (2) `Issues.toggle_issue(String.to_integer(id))`, then re-assign `:issues`; (3) show the full clause.

- [ ] **Step 3: Author `slides/slides.md`** — replace the template. ~5 blocks (`---`/`--`): title; "What LiveView is (a process per connection; dead render → websocket → diffs)"; "The lifecycle: mount / render / handle_event"; "In-memory issues + the context"; "LiveView auth: live_session + on_mount". Closer → "Next: lesson 28 — streams & PubSub" with `make slides-dev LESSON=28-liveview-2`.

- [ ] **Step 4: Verify slides publish and commit**

```bash
cd /Users/ristkari/code/private/elixir-training
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist >/dev/null 2>&1 && grep -c "lessons/27-liveview-1/slides/" dist/index.html && rm -rf dist
git add lessons/27-liveview-1/README.md lessons/27-liveview-1/HINTS.md lessons/27-liveview-1/slides
git commit -m "$(cat <<'EOF'
Add lesson 27-liveview-1 prose: README, HINTS, slides

Explains LiveView (a stateful process per connection; dead render ->
websocket -> diffs), the mount/render/handle_event lifecycle, the new
in-memory Issue concept and its context, and the provided LiveView auth
(live_session + on_mount, needed because lesson 26 chose controller-based
auth). Drill is the two handle_event callbacks (add, toggle).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

Expected: build_index prints `1`.

---

## Task 4: Final smoke + PR

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

Expected: all green. Lesson 27's exercise (`make test`, pending excluded → 111/0) and solution (`make solutions-test`, incl. pending → 113/0) create+migrate their DB against the container.

- [ ] **Step 2: Confirm all 28 lessons publish**

```bash
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules \
         04-control-flow 05-recursion 06-enum-and-the-pipe 07-collections \
         08-strings-and-binaries 09-streams 10-structs-and-protocols 11-error-handling \
         12-mix-projects 13-processes 14-tasks-and-agents 15-genserver-1 16-genserver-2 \
         17-supervisors 18-otp-applications 19-ets 20-distribution 21-plug \
         22-phoenix-tour 23-controllers-and-heex 24-forms-and-changesets-preview 25-contexts \
         26-auth 27-liveview-1; do
  grep -q "lessons/$n/slides/" dist/index.html || echo "$n: MISSING"
done | grep -c MISSING | xargs -I{} echo "missing count: {} (expected 0)"
rm -rf dist
```

(`make slides-build` leaves `dist/`; if absent, re-run it before this loop.)

- [ ] **Step 3: Manual board check (optional but recommended)**

```bash
cd lessons/27-liveview-1/solutions && mix ecto.setup
# mix phx.server → register at /users/register, log in, open a project, click
# "Open board", add an issue, toggle it — all without a page reload. Ctrl-C to stop.
cd /Users/ristkari/code/private/elixir-training
```

- [ ] **Step 4: Push the branch and open the PR**

```bash
git push -u origin plan-g-phase-3b-ii
gh pr create --base main --head plan-g-phase-3b-ii \
  --title "Plan G: Phase 3b-ii lesson 27 liveview-1" \
  --body "$(cat <<'EOF'
## Summary
- Implements [Plan G](docs/superpowers/plans/2026-06-09-plan-g-phase-3b-ii-liveview-1.md) — lesson 27 (`liveview-1`), the first LiveView lesson.
- A live issue board at `/projects/:id/board`: `mount`/`render`/`handle_event` add and toggle issues live in one tab.
- New in-memory `Issue` concept (`IssueStore` + `Issues` context); issues stay in memory until lesson 29.

## What shipped
- **27-liveview-1** (2 drills): `handle_event("add_issue")` and `handle_event("toggle")`. `mount`/`render`, the context, and LiveView auth are provided.
- LiveView auth wired: lesson 26's controller-based auth generated no `on_mount`, so a small hook was added to `UserAuth` and the board route runs in `live_session :require_authenticated`.
- First use of `Phoenix.LiveViewTest`.

## Notes
- No new deps or CI changes — LiveView + the `/live` socket are already in the app, and lesson 26's Postgres service covers the DB.
- Solution derived first; exercise reverts only the two `handle_event` callbacks to typed-placeholder stubs. Exercise compiles warning-free; pending-excluded green; the 2 drill tests fail until implemented.
- Tests target a specific `#issue-<id>` element (the in-memory store doesn't roll back with the SQL sandbox).

## Test plan
- [ ] CI green with the Postgres service (ci-smoke, lint, exercises, solutions, slides-build, dist).
- [ ] After merge, Deploy republishes the slide site with lesson 27.
- [ ] Locally: `docker compose up -d postgres`, then `cd lessons/27-liveview-1/solutions && mix ecto.setup && mix phx.server`, open a project's board, add and toggle an issue live.

Local pipeline green against Postgres: solution 113/0; exercise 111/0 pending-excluded, 2 drill tests fail with pending; all 28 lessons publish.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 5: Watch CI; merge after green + approval**

```bash
gh pr checks <PR_NUMBER> --watch
```

If green and approved: `gh pr merge --squash --delete-branch` → triggers Deploy. (Leave the merge to the human, per prior phases.)

---

## Self-review checklist (applied)

**Spec coverage:** every spec section maps to a task. In-memory `IssueStore` + `Issues` context → Task 1 Steps 2–4. `ProjectBoardLive` (mount/render/handle_event) → Task 1 Step 6. LiveView auth (`on_mount` + `live_session`) → Task 1 Steps 5 & 7. Show-page link → Task 1 Step 8. Drill = the two `handle_event` callbacks → Task 1 Step 6 (solution), Task 2 Step 3 (stubs). `Phoenix.LiveViewTest` + the auth/add/toggle/not-yours tests, with only add+toggle pending → Task 1 Step 10 & Task 2 Step 4. Issues context tests → Task 1 Step 9. Test-isolation (`async: false`, target by `#issue-<id>`, fresh per-test user+project) → encoded in Task 1 Step 10 and the README (Task 3). Threading / derive-exercise → Tasks 1 & 2. Prose → Task 3. Smoke + all-lessons-publish + PR → Task 4. No CI task needed (Postgres service already exists from lesson 26).

**Placeholder scan:** none. Every code block is the verified prototype output (113 solution / 111+2 exercise, format-clean). `# TODO:` strings are intentional exercise stubs.

**Type consistency:** signatures consistent across tasks/dirs — `IssueStore.list/1` (project_id), `add/2` (project_id, attrs), `toggle/1`, `get/1`; `Issues.list_issues/1`, `create_issue/2`, `toggle_issue/1`, `change_issue/1`; `ProjectBoardLive` reads `socket.assigns.current_scope.user.id` and `socket.assigns.project.id`; `UserAuth.on_mount(:require_authenticated, ...)` matches the `live_session on_mount: [{TrackerWeb.UserAuth, :require_authenticated}]`. The solution defines these (Task 1); the exercise reverts only the two `handle_event` callbacks (Task 2).
