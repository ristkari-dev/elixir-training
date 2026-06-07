# Lesson 26: Auth (the database, switched on)

By the end of this lesson, Tracker has a real `users` table in Postgres and a working register / log-in / log-out / settings flow — generated for you by `mix phx.gen.auth`. You'll protect the `/projects` pages behind login and make each user see only their own projects. This is the first lesson that uses a database.

Users now live in Postgres. Projects stay in the in-memory `ProjectStore` for one more phase — they move to Postgres in lesson 29. That hybrid is deliberate: you can't log in to an account that vanishes on restart, but projects can wait.

## What you should be able to do

After this lesson you should be able to:

- Switch a dormant Ecto Repo on: supervision tree, the `ecto.create`/`ecto.migrate` test alias, and the SQL sandbox for isolated DB tests.
- Generate a controller-based auth system with `mix phx.gen.auth` and explain what it produces (the `Accounts` context, `User`/`UserToken`, the users migration, the auth plugs and controllers).
- Protect routes behind `require_authenticated_user`, and reach the logged-in user via `conn.assigns.current_scope.user`.
- Scope domain data to the current user through a context that takes a `scope`.

## Key ideas

**The database, switched on.** Lesson 22 generated a full database layer and then kept it *dormant* — the Repo was out of the supervision tree and the `test` alias didn't touch a database. This lesson switches it on (in both `exercises/` and `solutions/`): `Tracker.Repo` joins the supervision tree, the `test` alias is back to `["ecto.create --quiet", "ecto.migrate --quiet", "test"]`, and `ConnCase`/`DataCase` check out the **SQL sandbox** — each test runs in a transaction that is rolled back, so tests never see each other's rows. You need Postgres: from the repo root, `docker compose up -d postgres`; then `mix ecto.setup` inside the lesson creates+migrates your dev database.

> 💡 **First time seeing this?** The SQL sandbox is why DB-backed tests are fast and isolated — every `INSERT` happens inside a transaction the sandbox rolls back when the test finishes, so nothing is really written.

**`mix phx.gen.auth` (controller-based).** The whole auth system is generated, then committed as provided code — you study it, you don't hand-write it. We ran `mix phx.gen.auth Accounts User users` and answered **no** to "Do you want to create a LiveView based authentication system?", so the pages are plain **controllers** (the kind you know from lessons 23–25). LiveView is lesson 27. It generated the `Accounts` context, `User`/`UserToken`/`UserNotifier`, a `users` migration, `TrackerWeb.UserAuth` (the auth plugs), and the session/registration/settings controllers + templates, and it added the `bcrypt_elixir` dependency.

> 💡 **First time seeing this?** Generators are first-class in Phoenix — you're expected to run them *and* read what they produce. Open `lib/tracker/accounts.ex` and `lib/tracker_web/user_auth.ex` and follow the flow.

**Scopes: `current_scope.user`.** Phoenix 1.8 introduces scopes. The generated `:browser` pipeline runs `fetch_current_scope_for_user`, which puts a `Tracker.Accounts.Scope` on `conn.assigns.current_scope`. The logged-in user is `conn.assigns.current_scope.user` (`nil` when nobody is logged in) — not a bare `current_user`. Contexts take a `scope` so they can enforce ownership; that's why `Projects.list_projects/1` and `create_project/2` now receive a scope.

**Protecting routes.** `require_authenticated_user` is a generated plug. Any route in a scope that does `pipe_through [:browser, :require_authenticated_user]` redirects a logged-out visitor to `~p"/users/log-in"` (302). The generator already protects `/users/settings` that way.

## The drills

The generated auth is done for you. Two integration holes are yours:

1. **Protect the projects routes.** In `lib/tracker_web/router.ex`, the `/projects` resources currently sit in the public `pipe_through :browser` scope. Move them into a scope that does `pipe_through [:browser, :require_authenticated_user]`, so anonymous visitors are redirected to log in.
2. **Scope the store to the owner.** `Tracker.ProjectStore.list/1` and `add/2` take a `user_id` but ignore it. Make `list/1` return only that user's projects and `add/2` record `:user_id` on the stored project. The `Projects` context and `ProjectController` already pass `current_scope` through for you.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=26-auth` from the repo root to view).
3. From the repo root, `docker compose up -d postgres`.
4. Open `exercises/` and run `mix test --include pending` — see the four failing drill tests. Make them pass.
5. Stuck? Read `HINTS.md` one hint at a time.
6. Compare against `solutions/` only after you have a working answer.

## Common mistakes

- **Postgres isn't running.** `mix test` fails to connect — run `docker compose up -d postgres` from the repo root first.
- **Reaching for `current_user`.** In 1.8 it's `conn.assigns.current_scope.user`.
- **Asserting on a global project count.** The in-memory `ProjectStore` is an app-started singleton — its state does *not* roll back between tests like the database does. The tests register a fresh user each time and assert on *that user's* visibility, never on a global count or an empty store.

## Going further

- Read `lib/tracker_web/user_auth.ex`: how does `log_in_user/3` rotate the session, and what does `require_authenticated_user` store so it can send you back after login?
- Register a user, then visit `/dev/mailbox` (dev only) to see the confirmation email the `UserNotifier` "sent."

## Links

- [Phoenix — `mix phx.gen.auth`](https://hexdocs.pm/phoenix/mix_phx_gen_auth.html)
- [Phoenix — authentication overview](https://hexdocs.pm/phoenix/authentication.html)
- [`Ecto.Adapters.SQL.Sandbox`](https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.Sandbox.html)
