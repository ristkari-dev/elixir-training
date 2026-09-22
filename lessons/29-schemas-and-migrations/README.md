# Lesson 29: Schemas & migrations

By the end of this lesson, Tracker's own data lives in Postgres. Create a project, stop the server, start it again — it's still there. This opens Phase 4.

Lesson 25 made a promise and lessons 26–28 repeated it: the context is a **boundary**, so you can swap what's behind it and the web layer never notices. This is that swap. `Tracker.ProjectStore` and `Tracker.IssueStore` — the two `Agent`s, direct descendants of lesson 14's — are deleted, and `Tracker.Projects` and `Tracker.Issues` call `Repo` instead. Same function names, same arities, same return shapes. `ProjectController` and `ProjectBoardLive` are byte-identical to lesson 28: the web-layer diff is empty. Both domains move at once because they can't move separately — an issue's `project_id` has to point at a real `projects` row.

## What you should be able to do

After this lesson you should be able to:

- Write a migration (`mix ecto.gen.migration`, `create table`, `add`, `references`, `create index`) and run it with `mix ecto.migrate`.
- Write an `Ecto.Schema` and say which column each `field` maps to.
- Read and write rows with `Repo.insert/1`, `Repo.get!/2`, `Repo.update!/1` and `Repo.all/1`.
- Explain why a foreign key column gets an index.

## Key ideas

**A schema is a struct that names a table.** `use Ecto.Schema` plus `schema "projects" do ... end` defines `%Tracker.Projects.Project{}` — an ordinary struct, the same kind you met in lesson 10 — with one `field` per column, and an `:id` primary key Ecto adds without being asked. It is Elixir-side only: writing a schema describes what a row looks like, it does not create anything. The table is the migration's job.

**Migrations are ordered, and they run once.** `mix ecto.gen.migration create_projects` writes a timestamp-named file into `priv/repo/migrations/`. `mix ecto.migrate` runs every file that hasn't run yet, oldest first, and records each one in a `schema_migrations` table. The timestamps are therefore the order your database was built in — `create_issues` has to be stamped *after* `create_projects`, because it points at that table. And once a migration has run you don't edit it: the file is history. Editing it changes nothing, because its name is already recorded as done. You roll back, or you write a new migration on top. Lesson 26 already ran one of these (`create_users_auth_tables`, from `phx.gen.auth`) — you just didn't write it.

**`references` is the foreign key.** `add :project_id, references(:projects, on_delete: :delete_all), null: false` does three things at once: it creates a `bigint` column, it tells Postgres to reject any value that isn't an existing `projects.id`, and it says what happens when the parent row is deleted — `:delete_all` deletes that project's issues with it. `null: false` then rules out an issue belonging to no project at all. On the Elixir side the column is just `field :project_id, :id`; the association that would let you write `issue.project` is `belongs_to`, and that's lesson 32.

> 💡 **First time seeing this?** A **foreign key** is a column holding another table's id, plus a rule the database itself enforces: that id must exist over there. It's Postgres refusing to store an issue for project 999 when there is no project 999 — the guarantee lives in the database, not in your code.

**Why `project_id` is indexed.** Every board load asks for one project's issues, and a foreign key is a column you filter on constantly. Without `create index(:issues, [:project_id])`, Postgres has to read every row in `issues` to find the handful belonging to one project. With it, it jumps straight to them. Creating the foreign key does *not* create the index — that's a separate line, and forgetting it is a classic slow-app bug.

> 💡 **First time seeing this?** An **index** is a sorted lookup structure the database maintains beside the table, like the index at the back of a book. Looking a term up in the index beats reading every page. The cost is that writes have to update it too, which is why you index the columns you search by, not all of them.

**Fields map to column types.** `:string` becomes `varchar(255)`. `field :project_id, :id` becomes `bigint` — matching the `bigserial` primary key `references/2` points at. `timestamps type: :utc_datetime` becomes two columns, `inserted_at` and `updated_at`, of type `timestamp(0)` — whole seconds, no fractions; `psql`'s `\d issues` prints it as `timestamp(0) without time zone`. **Not `timestamptz`**, and that's the interesting part: `:utc_datetime` is a guarantee Ecto enforces in Elixir — it will only store a `DateTime` whose zone is `Etc/UTC` — so the column has no zone of its own to carry. The users migration shows one more: `:citext`, a case-insensitive text type that Postgres only has after `CREATE EXTENSION citext`, which is why that migration's first line runs it.

**The changeset finally has a schema behind it.** Lesson 24 cast into a `{data, types}` pair because there was no schema to cast into. Now it's `Ecto.Changeset.cast(%Project{}, attrs, [:name, :status])` and the types come from the schema. Everything else is what you already know: `validate_required/2`, `changeset.valid?`, and the `{:ok, project}` / `{:error, changeset}` shape the controller and the LiveView match on. Note what is *not* in the cast list: `user_id` and `project_id` are set on the struct (`%Issue{project_id: project_id}`), never cast, so no form submission can reassign an issue to somebody else's project.

**A blank status becomes `"open"` — twice over.** `change_project/1` requires `:name` and deliberately not `:status`. `cast/4` treats `""` as an empty value, substitutes the schema's `default: "open"` and records no change at all — so a `validate_required([:status])` here would be a check that can never fire. The database repeats the guarantee independently with `null: false, default: "open"`. Rejecting a status that isn't `"open"` or `"closed"` is a different job, and it's lesson 30's.

**A table has no order.** Rows come back however Postgres finds them, and toggling an issue rewrites its row — so without an explicit order the board would shuffle itself on reload. That's why `list_projects/1` and `list_issues/1` say `from(i in Issue, where: i.project_id == ^project_id, order_by: [asc: i.id])`. That line is the query DSL, which gets its own lesson (31). For now read it as "this project's rows, oldest first".

**One return shape does change.** `get_project!/1` is now `Repo.get!(Project, id)`, so a missing id raises `Ecto.NoResultsError` where lesson 25's `Agent` store raised a plain `RuntimeError`. That's the one deliberate break in "nothing changes", and it's an upgrade: Phoenix renders `Ecto.NoResultsError` as a **404** in production, where `RuntimeError` was a 500.

## The drills

Projects are the worked example and are done for you end to end — migration, schema and `Repo`-backed context are all in `exercises/`. Read them first. Issues are yours:

1. **The `create_issues` migration.** Run `mix ecto.gen.migration create_issues`, then fill in the table body: `title`, `status`, `project_id`, the timestamps and the index. `test/tracker/issues_table_test.exs` drives it — and it checks the *table*, not your Elixir, through `Repo.insert_all("issues", ...)` and raw SQL against `pg_indexes`. `insert_all` with a table name is the raw path and gives you none of `Repo.insert/1`'s conveniences — there's no schema involved, so nothing is autogenerated, which is why that test fills in `inserted_at`/`updated_at` by hand.
2. **The `Issue` schema and the `Issues` context.** Write `lib/tracker/issues/issue.ex` mirroring `Project`, then rewrite `lib/tracker/issues.ex` on `Repo`: `list_issues/1`, `change_issue/1`, `create_issue/2` and `toggle_issue/1`.

`mix test --include pending` shows **10** failing tests, more than the last few lessons. Four are drill 1. The rest need drill 2 — and they need drill 1 too, because no schema can store a row into a table that doesn't exist yet.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=29-schemas-and-migrations` from the repo root).
3. From the repo root, `docker compose up -d postgres`.
4. In `exercises/`, run `mix deps.get` and then `mix ecto.setup` — this lesson has its own database and it doesn't exist yet.
5. Run `mix test --include pending` — see the 10 failing drill tests. Make them pass.
6. Stuck? Read `HINTS.md` one hint at a time, and compare against `solutions/` only after you have a working answer.

## Try it

Start the app with `mix phx.server` and register at `/users/register`. No mail leaves your machine in dev, so open `/dev/mailbox` and click the login link there. Create a project, then stop the server with **Ctrl-C twice** and start it again. The project is still on the index — the thing three lessons of `Agent`s could never do.

Your lesson-28 login won't work here: from this lesson on, each lesson folder has its own database, so this one starts empty and you register again.

## Common mistakes

- **Postgres isn't running.** Every database call fails to connect. `docker compose up -d postgres` from the repo root.
- **No `mix ecto.setup` in this folder.** Each lesson folder now has its own database (`tracker_29_exercises_dev` here), and nothing creates it for you. Until you run it, `mix phx.server` answers every request with a phoenix_ecto error page — `mix ecto.create` while the database is missing, `mix ecto.migrate` once it exists but has no tables — instead of your app.
- **Editing a migration that already ran.** Nothing happens — `mix ecto.migrate` skips any file already recorded in `schema_migrations`. Roll it back first: `mix ecto.rollback` for the dev database, and `MIX_ENV=test mix ecto.rollback` for the test one, which is a *separate* database and doesn't notice the dev rollback. `MIX_ENV=test mix ecto.reset` is the bigger hammer.
- **`create_issues` stamped before `create_projects`.** Migrations run oldest first, so `references(:projects, ...)` would fail with a missing table. `mix ecto.gen.migration` stamps with the current time, so this only bites if you hand-write or copy the filename.

## Going further

- `mix phx.gen.schema Issues.Issue issues title:string status:string` would have written the schema *and* the migration for you. Try it in a scratch project and read what it produces — then note why this lesson doesn't use it: with a default scope configured (lesson 26 set that up), the generator writes a three-argument `changeset(issue, attrs, user_scope)` that `put_change`s the scope's id, which isn't the API our contexts expose.
- `status` as free text is loose. `Ecto.Enum` makes the schema itself reject anything but `"open"` and `"closed"` — lesson 30.
- `toggle_issue/1` loads a row and then writes it back. One `update_all` statement could flip it in the database without loading anything. Lessons 31 and 33.

## Links

- [`Ecto.Schema`](https://hexdocs.pm/ecto/Ecto.Schema.html)
- [`Ecto.Migration`](https://hexdocs.pm/ecto_sql/Ecto.Migration.html)
- [`Ecto.Repo`](https://hexdocs.pm/ecto/Ecto.Repo.html)
