# Plan H — Lesson 28 (`liveview-2`: streams + PubSub) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author lesson `28-liveview-2`: convert the issue board's list to a LiveView **stream** and add **Phoenix.PubSub** so adding/toggling an issue in one tab updates every tab viewing that project's board, live.

**Architecture:** Thread Tracker from lesson 27's solution. The only code that changes is `ProjectBoardLive` and its test: `mount` streams the issues and subscribes to a per-project topic; `handle_event` for add/toggle updates the caller's own stream (synchronous, local `stream_insert`) and `broadcast_from(self())` to other tabs; a `handle_info` clause applies broadcasts from other tabs via `stream_insert`. The drill is that real-time wiring (the two `handle_event` bodies + `handle_info`); the exercise is derived from the finished solution by stubbing them and tagging the three interaction tests `@tag :pending`. Closes Phase 3.

**Tech Stack:** Elixir 1.19.5-otp-28 / OTP 29.0.1; Phoenix `~> 1.8` (1.8.7); `phoenix_live_view ~> 1.1`; `Phoenix.PubSub` (already in the supervision tree); Ecto/Postgres (auth only); `Phoenix.LiveViewTest`. No new Hex deps.

**Spec:** `docs/superpowers/specs/2026-06-09-lesson-28-liveview-2-design.md`.

**This plan was prototyped end-to-end against Postgres + a live two-tab socket before being written.** The solution runs **114 tests / 0 failures**; the exercise compiles under `--warnings-as-errors`, passes **111** with the 3 drill tests excluded, and fails exactly **3** with pending included. All code below is verified and `mix format`-clean.

Two things the prototype pinned down (do not re-derive):
- **Two-path update, not single-path.** The caller updates its *own* tab with a local `stream_insert` and uses `broadcast_from(Tracker.PubSub, self(), ...)` (which excludes self) for other tabs. A single-path "broadcast only, handle_info updates everyone including self" makes the caller's own update async and produces flaky tests — avoid it.
- **Stream DOM ids are prefixed by the stream name.** The list is `stream(:issues, ...)`, so each row's `dom_id` is `issues-<id>` (plural). Tests target `#issues-<id>` — NOT lesson 27's `#issue-<id>`.

---

## Conventions (read once, apply throughout)

### Repo-root rule
All `tools/*` scripts run from the repo root `/Users/ristkari/code/private/elixir-training`. Per-lesson `mix` commands run inside `lessons/28-liveview-2/exercises` or `.../solutions`.

### Local Postgres (required — auth tests are DB-backed)
Bring up the compose service before any DB-backed `mix test`:

```bash
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
```

If host port 5432 is already taken by another container and you cannot free it, the tests will fail to connect — resolve the port before running (this plan assumes the compose `postgres` service is reachable at `localhost:5432`, matching `config/test.exs`).

### Commit style
GPG signing is automatic. Lesson commits use:
```
Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

### Module names & scope of change
App stays `Tracker` / `TrackerWeb`. Lesson 28 changes exactly two files versus lesson 27's solution: `lib/tracker_web/live/project_board_live.ex` and `test/tracker_web/live/project_board_live_test.exs`. Everything else (IssueStore, Issues context, route, auth, other tests) is carried unchanged.

### Build order
Build the full solution first (Task 1), then derive the exercise (Task 2) by stubbing the two `handle_event` bodies and `handle_info` and tagging the three interaction tests pending.

### Phoenix-era stub convention
Exercise stubs compile with zero warnings under `mix compile --warnings-as-errors`. The two `handle_event` stubs perform the data change (create/toggle) but do not `stream_insert` or broadcast; `handle_info` is a no-op. Each carries a `# TODO:` comment. (There is deliberately no `broadcast_*` private helper — inlining `broadcast_from/4` avoids an unused-private-function warning in the exercise.)

---

## Task 1: Lesson 28 solution

**Files:** scaffold `lessons/28-liveview-2`; copy lesson 27's solution into `solutions/`; overwrite `lib/tracker_web/live/project_board_live.ex` and `test/tracker_web/live/project_board_live_test.exs`.

- [ ] **Step 1: Scaffold and thread from lesson 27**

```bash
cd /Users/ristkari/code/private/elixir-training
tools/new-lesson 28-liveview-2
rm -rf lessons/28-liveview-2/exercises lessons/28-liveview-2/solutions
cp -R lessons/27-liveview-1/solutions lessons/28-liveview-2/solutions
rm -rf lessons/28-liveview-2/solutions/_build lessons/28-liveview-2/solutions/deps
docker compose up -d postgres
until docker exec elixir_training_postgres pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
```

Leave `lessons/28-liveview-2/exercises` ABSENT (Task 2 derives it). The scaffolder created `lessons/28-liveview-2/{README.md,HINTS.md,slides/}` — leave those for Task 3.

- [ ] **Step 2: Overwrite the LiveView with streams + PubSub**

`lessons/28-liveview-2/solutions/lib/tracker_web/live/project_board_live.ex`:

```elixir
defmodule TrackerWeb.ProjectBoardLive do
  use TrackerWeb, :live_view

  alias Tracker.{Projects, Issues}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    project = Projects.get_project!(String.to_integer(id))

    if project.user_id == socket.assigns.current_scope.user.id do
      if connected?(socket), do: Phoenix.PubSub.subscribe(Tracker.PubSub, topic(project.id))

      {:ok,
       socket
       |> assign(:project, project)
       |> assign(:form, to_form(Issues.change_issue(), as: :issue))
       |> stream(:issues, Issues.list_issues(project.id))}
    else
      {:ok,
       socket
       |> put_flash(:error, "That project isn't yours.")
       |> redirect(to: ~p"/projects")}
    end
  end

  defp topic(project_id), do: "board:#{project_id}"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>{@project.name} — board</.header>

      <.form for={@form} phx-submit="add_issue">
        <.input field={@form[:title]} label="New issue" />
        <.button>Add</.button>
      </.form>

      <ul id="issues" phx-update="stream">
        <li :for={{dom_id, issue} <- @streams.issues} id={dom_id}>
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
      {:ok, issue} ->
        Phoenix.PubSub.broadcast_from(
          Tracker.PubSub,
          self(),
          topic(socket.assigns.project.id),
          {:issue, issue}
        )

        {:noreply,
         socket
         |> stream_insert(:issues, issue)
         |> assign(:form, to_form(Issues.change_issue(), as: :issue))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :issue))}
    end
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    issue = Issues.toggle_issue(String.to_integer(id))

    Phoenix.PubSub.broadcast_from(
      Tracker.PubSub,
      self(),
      topic(socket.assigns.project.id),
      {:issue, issue}
    )

    {:noreply, stream_insert(socket, :issues, issue)}
  end

  @impl true
  def handle_info({:issue, issue}, socket) do
    {:noreply, stream_insert(socket, :issues, issue)}
  end
end
```

- [ ] **Step 3: Overwrite the board test (streams dom id + two-tab PubSub)**

`lessons/28-liveview-2/solutions/test/tracker_web/live/project_board_live_test.exs`:

```elixir
defmodule TrackerWeb.ProjectBoardLiveTest do
  # async: false — IssueStore/ProjectStore are app-started singletons whose
  # state does not roll back with the SQL sandbox. Each test makes a fresh
  # user + project; assertions target a specific issue by its stream dom id
  # (#issues-<id>), never "the only element on the board".
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
      view |> form("form", issue: %{title: "Fix login"}) |> render_submit()
      assert render(view) =~ "Fix login"
    end

    test "toggling an issue flips its status", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, issue} = Tracker.Issues.create_issue(project.id, %{"title" => "Ship it"})
      {:ok, view, _html} = live(conn, ~p"/projects/#{project.id}/board")
      assert has_element?(view, "#issues-#{issue.id} .status", "open")

      view |> element("#issues-#{issue.id} button[phx-click=toggle]") |> render_click()
      assert has_element?(view, "#issues-#{issue.id} .status", "closed")
    end

    test "a second tab sees a new issue live", %{conn: conn, user: user} do
      project = create_project(user)
      {:ok, tab_a, _} = live(conn, ~p"/projects/#{project.id}/board")
      {:ok, tab_b, _} = live(conn, ~p"/projects/#{project.id}/board")

      tab_a |> form("form", issue: %{title: "Broadcast me"}) |> render_submit()

      assert render(tab_b) =~ "Broadcast me"
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

- [ ] **Step 4: Format and verify the solution is fully green**

```bash
cd lessons/28-liveview-2/solutions
mix deps.get
mix format
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
mix test 2>&1 | tail -n 3
cd /Users/ristkari/code/private/elixir-training
```

Expected: compile clean (no warnings); `114 tests, 0 failures` (113 carried from lesson 27's suite with the board test now rewritten to 5 tests — 4 carried behaviors + the new two-tab test). If it fails, debug before committing — the prototype proved this passes.

- [ ] **Step 5: Commit the solution**

```bash
git add lessons/28-liveview-2/solutions
git status   # confirm NO deps/ _build/ priv/static/assets/ node_modules/ nested .git staged; mix.lock SHOULD be staged
git commit -m "$(cat <<'EOF'
Add lesson 28-liveview-2 solution: streams + PubSub multi-tab

Threads Tracker from lesson 27. Converts the issue board's list to a
LiveView stream (phx-update="stream") and adds Phoenix.PubSub so a change
in one tab appears live in every tab viewing that project's board. mount
subscribes to "board:<id>" (when connected) and streams the issues;
add/toggle update the caller's own stream and broadcast_from(self()) to
other tabs; handle_info applies broadcasts via stream_insert. The two-tab
LiveViewTest proves the cross-tab update. Closes Phase 3.

Solution green against Postgres: 114 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Lesson 28 exercise — derive and stub the real-time wiring

**Files:** create `lessons/28-liveview-2/exercises` as a copy of the finished solution, then stub the two `handle_event` bodies and `handle_info`, and tag the three interaction tests pending.

- [ ] **Step 1: Derive the exercise from the finished solution**

```bash
cd /Users/ristkari/code/private/elixir-training
cp -R lessons/28-liveview-2/solutions lessons/28-liveview-2/exercises
rm -rf lessons/28-liveview-2/exercises/_build lessons/28-liveview-2/exercises/deps
```

- [ ] **Step 2: Set the exercise test_helper to exclude pending**

Overwrite `lessons/28-liveview-2/exercises/test/test_helper.exs`:

```elixir
ExUnit.start(exclude: [pending: true])
Ecto.Adapters.SQL.Sandbox.mode(Tracker.Repo, :manual)
```

- [ ] **Step 3: Stub the two `handle_event` bodies and `handle_info`**

In `lessons/28-liveview-2/exercises/lib/tracker_web/live/project_board_live.ex`, replace the two `handle_event` clauses and the `handle_info` clause with these stubs (leave `mount`, `render`, and `topic/1` exactly as the solution):

```elixir
  @impl true
  def handle_event("add_issue", %{"issue" => params}, socket) do
    case Issues.create_issue(socket.assigns.project.id, params) do
      {:ok, _issue} ->
        # TODO: broadcast the new issue to other tabs with
        # Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic(...), {:issue, issue}),
        # and stream_insert it here so this tab shows it.
        {:noreply, assign(socket, :form, to_form(Issues.change_issue(), as: :issue))}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset, as: :issue))}
    end
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    Issues.toggle_issue(String.to_integer(id))
    # TODO: broadcast the toggled issue to other tabs and stream_insert it here
    # so the status updates live.
    {:noreply, socket}
  end

  @impl true
  def handle_info({:issue, _issue}, socket) do
    # TODO: stream_insert the issue so this tab updates when another tab changes it.
    {:noreply, socket}
  end
```

(These compile clean — `topic/1` is still used by `mount`'s subscribe, so there's no unused-function warning. The data is still created/toggled, so the `Issues` context tests stay green; only the board's live behavior is broken.)

- [ ] **Step 4: Tag the three interaction tests `@tag :pending`**

In `lessons/28-liveview-2/exercises/test/tracker_web/live/project_board_live_test.exs`, add `@tag :pending` directly above these three tests:
- `test "adding an issue shows it on the board", %{conn: conn, user: user} do`
- `test "toggling an issue flips its status", %{conn: conn, user: user} do`
- `test "a second tab sees a new issue live", %{conn: conn, user: user} do`

(Leave the `redirects to log in` and `cannot open another user's board` tests un-tagged — they pass because auth/mount are provided.)

- [ ] **Step 5: Format and verify exercise behavior**

```bash
cd lessons/28-liveview-2/exercises
mix deps.get
mix format
mix compile --force --warnings-as-errors 2>&1 | tail -n 2
echo "--- pending EXCLUDED (must be 0 failures) ---"
mix test 2>&1 | tail -n 3
echo "--- pending INCLUDED (must fail exactly the 3 drill tests) ---"
mix test --include pending 2>&1 | tail -n 3
cd /Users/ristkari/code/private/elixir-training
```

Expected: compile clean (no warnings); pending excluded → `111 tests, 0 failures (3 excluded)`; pending included → `114 tests, 3 failures` (add, toggle, two-tab).

- [ ] **Step 6: Commit the exercise**

```bash
git add lessons/28-liveview-2/exercises
git status   # confirm no build artifacts / nested .git staged
git commit -m "$(cat <<'EOF'
Add lesson 28-liveview-2 exercise: the streams + PubSub drills

Derived from the lesson-28 solution, with the real-time wiring reverted
to stubs: add/toggle change the data but don't stream_insert or broadcast,
and handle_info is a no-op (each with a # TODO). mount (subscribe +
stream), render (phx-update="stream"), and the Issues context are all
provided. The three LiveViewTest interaction tests (add, toggle, two-tab)
are @tag :pending; the auth-redirect and not-yours tests pass. Exercise
compiles warning-free and runs against Postgres.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Lesson 28 prose — README, HINTS, slides

**Files:** `lessons/28-liveview-2/README.md`, `HINTS.md`, `slides/slides.md`. Read `lessons/27-liveview-1/README.md`, `lessons/27-liveview-1/HINTS.md`, and `lessons/27-liveview-1/slides/slides.md` for house style first.

- [ ] **Step 1: Author `README.md`**

Sections:
1. Title + intro: the issue board becomes real-time — add or toggle an issue in one tab and it appears in every tab viewing that board, with the list rendered as a LiveView stream. Closes Phase 3.
2. **Streams — why.** The lesson-27 board kept the whole issue list in `assign(:issues, ...)` and re-rendered it. A **stream** stops holding and re-diffing the whole collection: the server sends per-item operations (`stream_insert`, delete) and the client patches the DOM. Container gets `phx-update="stream"` and a DOM id; rows iterate `@streams.issues` as `{dom_id, issue}` with `id={dom_id}`. Note the DOM id is `issues-<id>` (the stream name prefixes it).
3. **PubSub — multi-tab.** `Tracker.PubSub` is already running. `mount` subscribes (when `connected?/1`) to a per-project topic `"board:<id>"`. On a change, the LiveView updates its **own** stream and calls `Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic, {:issue, issue})` — `broadcast_from` sends to every *other* subscriber (not self). A `handle_info({:issue, issue}, socket)` clause receives those broadcasts and `stream_insert`s them. So each tab updates its own view directly, and tells the others via the broadcast.
4. **Why `broadcast_from(self())` and not `broadcast`.** If you broadcast to everyone including yourself and only update via `handle_info`, your own update becomes an async message — visible flakiness in tests and a beat of lag in the UI. Updating your own stream directly and broadcasting to *others* keeps your tab instant and the code testable.
5. **The drill.** `mount`/`render`/subscribe and the context are provided. Implement the real-time wiring in `lib/tracker_web/live/project_board_live.ex`: in `handle_event("add_issue"/"toggle")`, `broadcast_from` the changed issue and `stream_insert` it locally; in `handle_info({:issue, issue}, ...)`, `stream_insert` the broadcast payload.
6. **Common mistakes:** forgetting `docker compose up` (auth tests need the DB); using `broadcast` instead of `broadcast_from(self())` and double-inserting your own item; targeting `#issue-<id>` in a test when the stream dom id is `#issues-<id>`; forgetting `phx-update="stream"` on the container (rows won't patch).
7. **Going further:** many apps broadcast from the **context** (`Issues.create_issue` publishes) rather than the LiveView, so every writer notifies subscribers. Where would you move the broadcast? What would `handle_info` look like then?
8. **Links:** [LiveView — streams](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#stream/4), [Phoenix.PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html), [LiveView — testing](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html).

- [ ] **Step 2: Author `HINTS.md`** — two drill sections:
  - *Drill 1 (broadcast + local insert in `add`/`toggle`):* (1) after the data change, tell the *other* tabs with `Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic(socket.assigns.project.id), {:issue, issue})`, and update your own tab with `stream_insert(socket, :issues, issue)`; (2) show the `add_issue` `{:ok, issue}` branch (broadcast + `stream_insert` + reset the form); (3) show the full `toggle` clause (`issue = Issues.toggle_issue(...)`, broadcast, `stream_insert`).
  - *Drill 2 (`handle_info`):* (1) the broadcast arrives as `{:issue, issue}`; (2) `stream_insert(socket, :issues, issue)` inserts-or-updates by dom id; (3) show the full clause.

- [ ] **Step 3: Author `slides/slides.md`** — replace the template. ~5 blocks (`---`/`--`): title; "Streams: per-item ops, not whole-list re-render (`phx-update="stream"`, `@streams.issues`)"; "PubSub: subscribe in mount, broadcast on change, handle_info to receive"; "broadcast_from(self()): update your own tab, tell the others"; "the two-tab test". Closer → "Phase 3 done — next: Phase 4, Ecto (migrate issues to Postgres)" with `make slides-dev LESSON=29-schemas-and-migrations`.

- [ ] **Step 4: Verify slides publish and commit**

```bash
cd /Users/ristkari/code/private/elixir-training
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist >/dev/null 2>&1 && grep -c "lessons/28-liveview-2/slides/" dist/index.html && rm -rf dist
git add lessons/28-liveview-2/README.md lessons/28-liveview-2/HINTS.md lessons/28-liveview-2/slides
git commit -m "$(cat <<'EOF'
Add lesson 28-liveview-2 prose: README, HINTS, slides

Explains LiveView streams (per-item DOM ops, phx-update="stream", the
issues-<id> dom id), Phoenix.PubSub multi-tab updates (subscribe in
mount, broadcast_from(self) on change, handle_info to receive), and why
broadcast_from(self()) beats broadcast for your own tab. Drill is the
real-time wiring (broadcast + stream_insert in add/toggle, handle_info).

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

Expected: all green. Lesson 28's exercise (`make test`, pending excluded → 111/0) and solution (`make solutions-test`, incl. pending → 114/0) create+migrate their DB against the container.

- [ ] **Step 2: Confirm all 29 lessons publish**

```bash
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules \
         04-control-flow 05-recursion 06-enum-and-the-pipe 07-collections \
         08-strings-and-binaries 09-streams 10-structs-and-protocols 11-error-handling \
         12-mix-projects 13-processes 14-tasks-and-agents 15-genserver-1 16-genserver-2 \
         17-supervisors 18-otp-applications 19-ets 20-distribution 21-plug \
         22-phoenix-tour 23-controllers-and-heex 24-forms-and-changesets-preview 25-contexts \
         26-auth 27-liveview-1 28-liveview-2; do
  grep -q "lessons/$n/slides/" dist/index.html || echo "$n: MISSING"
done | grep -c MISSING | xargs -I{} echo "missing count: {} (expected 0)"
rm -rf dist
```

(`make slides-build` leaves `dist/`; if absent, re-run it before this loop.)

- [ ] **Step 3: Manual two-tab check (optional but recommended)**

```bash
cd lessons/28-liveview-2/solutions && mix ecto.setup
# mix phx.server → open the same project's /projects/:id/board in two browser
# tabs; add/toggle an issue in one; watch the other update live. Ctrl-C to stop.
cd /Users/ristkari/code/private/elixir-training
```

- [ ] **Step 4: Push the branch and open the PR**

```bash
git push -u origin plan-h-lesson-28
gh pr create --base main --head plan-h-lesson-28 \
  --title "Plan H: lesson 28 liveview-2 (streams + PubSub)" \
  --body "$(cat <<'EOF'
## Summary
- Implements [Plan H](docs/superpowers/plans/2026-07-08-plan-h-lesson-28-liveview-2.md) — lesson 28 (`liveview-2`), the final Phase 3 lesson.
- The issue board's list becomes a LiveView **stream**, and **Phoenix.PubSub** makes it multi-tab: adding/toggling an issue in one tab updates every tab viewing that project's board, live.

## What shipped
- **28-liveview-2** (drill: the real-time wiring): `handle_event` add/toggle `broadcast_from(self())` + local `stream_insert`; `handle_info` applies broadcasts. `mount`/`render`/subscribe and the context are provided.
- A two-tab `LiveViewTest` proves the cross-tab update.
- Comments and LiveComponents are intentionally out of scope (comments arrive in Phase 4 lesson 32, built in Postgres).

## Notes
- No new deps or CI changes — PubSub + the `/live` socket are already present; lesson 26's Postgres service covers the DB.
- Two-path pattern (own tab updates locally, `broadcast_from(self())` for others) — avoids the flaky self-broadcast race. Stream dom ids are `#issues-<id>` (stream-name prefixed).
- Solution built first; exercise reverts only the two `handle_event` bodies + `handle_info` to stubs. Exercise compiles warning-free; pending-excluded green; the 3 drill tests fail until implemented.

## Test plan
- [ ] CI green with the Postgres service (ci-smoke, lint, exercises, solutions, slides-build, dist).
- [ ] After merge, Deploy republishes the slide site with lesson 28.
- [ ] Locally: `docker compose up -d postgres`, then `cd lessons/28-liveview-2/solutions && mix ecto.setup && mix phx.server`, open a project's board in two tabs, add/toggle in one, watch the other update.

Local pipeline green against Postgres: solution 114/0; exercise 111/0 pending-excluded, 3 drill tests fail with pending; all 29 lessons publish.

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

**Spec coverage:** every spec section maps to a task. Streams conversion → Task 1 Step 2 (mount `stream`, render `phx-update="stream"`). PubSub subscribe/broadcast/handle_info → Task 1 Step 2. The drill (broadcast + stream_insert + handle_info) → Task 1 Step 2 (solution), Task 2 Step 3 (stubs). Testing incl. the two-tab test and `#issues-<id>` targeting and the synchronize-after-event pattern (`render(view)` / `has_element?`) → Task 1 Step 3. Three pending drill tests → Task 2 Step 4. Test isolation (`async: false`, fresh per-test user+project) → encoded in Task 1 Step 3 and the README (Task 3). Threading/derive-exercise → Tasks 1 & 2. Prose → Task 3. Smoke + all-lessons-publish + PR → Task 4. No CI task needed.

**Placeholder scan:** none. Every code block is the verified prototype output (114 solution / 111+3 exercise, format-clean). `# TODO:` strings are intentional exercise stubs.

**Type consistency:** consistent across tasks — the stream is `:issues` (dom ids `issues-<id>`); the topic helper is `topic(project_id) -> "board:#{project_id}"`; broadcasts and `handle_info` use `{:issue, issue}`; `broadcast_from(Tracker.PubSub, self(), topic(...), {:issue, issue})`. `IssueStore`/`Issues` (`list_issues/1`, `create_issue/2`, `toggle_issue/1`, `change_issue/1`) are carried unchanged from lesson 27. The solution defines the handlers (Task 1); the exercise reverts only the two `handle_event` bodies + `handle_info` (Task 2). Tests target `#issues-<id>`.
```
