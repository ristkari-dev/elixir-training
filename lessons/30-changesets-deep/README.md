# Lesson 30: Changesets deep dive

Lesson 29 gave Tracker real tables. This lesson makes them refuse bad data.

Today a project can be called `"!"`, its status can be `"sideways"`, and two issues in one project can share a title. By the end all three are rejected — and you will know *which machine* did the rejecting, because there are two of them and they cannot see the same things. **A validation runs in Elixir and can only see this changeset. A constraint runs in Postgres and is the only thing that can see the other rows.** That sentence is the whole lesson; everything below is a consequence of it.

One thing moves house. `changeset/2` leaves the context and becomes a *public* function on the schema module, beside the fields it talks about. Every context signature stays exactly as lesson 29 left it, so the controller and the LiveView don't move — and `Tracker.Accounts.User`, which has been shaped this way since lesson 26, stops looking arbitrary.

## What you should be able to do

After this lesson you should be able to:

- Declare a field as an `Ecto.Enum` and explain why a value outside the list fails at `cast/4` rather than in a validation.
- Add `validate_length/3` and read the `{message, opts}` pair an Ecto error is actually stored as.
- Write a validation of your own with `validate_change/3` and pipe it in beside Ecto's.
- Decide whether a rule belongs in Elixir or in the database, write the migration, and declare `unique_constraint/3` or `foreign_key_constraint/3` so a violation comes back as `{:error, changeset}` instead of raising.

## Key ideas

**A validation cannot see other rows.** `validate_length/3` is handed one changeset and asked a question about it. "Is this name already taken?" is not a question about this changeset — it is a question about every other row in the table, including rows another request is inserting right now. Only the database can answer that, and only at the instant it writes. So uniqueness is a **unique index** in a migration, and the Elixir side merely declares that it knows about it.

**`Ecto.Enum` is the first line of defence, and it isn't a validation.** `field :status, Ecto.Enum, values: [:open, :closed], default: :open`. No migration is needed: string-backed means the column stays the same `varchar` holding `"open"` and `"closed"`, while Elixir sees the atoms `:open` and `:closed`. A `"sideways"` in the params fails inside `cast/4` itself, as `["is invalid"]` on `:status` — it is the *type* refusing to convert. That is also why pairing it with `validate_inclusion/3` would be dead code: the failed cast records no change, and `validate_change/3` only runs where there is a change to look at.

**A blank status saves as `open`, and that is not a bug.** `cast/4` treats `""` as an empty value, substitutes the schema's `default: :open` and records no change at all — so nothing ever reaches the enum to be rejected. Lesson 29 said this about `change_project/1`; it matters more now, because the form finally offers a blank choice on purpose. `<.input type="select" prompt="Choose a status" options={Ecto.Enum.values(Tracker.Projects.Project, :status)} …>` renders an empty `<option>` only because `prompt` is given. That select is the **one** web-layer line this lesson changes; lesson 29 sold "the web layer didn't change", and here the streak breaks by exactly one line.

**Trim first, then measure.** `update_change(:name, &String.trim/1)` sits immediately after `cast/4`, before `validate_required/2` and `validate_length/3`. `update_change/3` rewrites the change that later steps read, so the order is load-bearing: trim *after* the length check and `min: 2` would measure `"  A  "` (five characters, passes) and store `"A"` (one). The trim is not cosmetic either — `cast/4`'s empty-value handling decides *emptiness* only and stores the original string, so without it `"Apollo"` and `"Apollo "` are two different names that would both satisfy the unique index.

**A validation is just `changeset -> changeset`.** That is why `|>` composes yours with Ecto's — `validate_name/1` is an ordinary private function in the pipe, and `validate_change/3` is the primitive inside it: give it a field and a function returning either `[]` or `[name: "message"]`. There is a second spelling, already in the tree: `User.validate_email_changed/1` reads the changeset with `get_field/2` and calls `add_error/3` directly. Same shape, no wrapper.

**An error is stored uninterpolated, as `{message, opts}`.** `validate_length(:title, max: 120)` records `{"should be at most %{count} character(s)", [count: 120, validation: :length, kind: :max, type: :string]}`. Two *independent* consumers fill in `%{count}` — they are not a chain. The test path: `errors_on/1` (in `test/support/data_case.ex`) runs its own `Regex.replace` over `opts` and never touches Gettext. The browser path: `<.input>` → `translate_error/1` → `Gettext.dngettext` → the msgids in `priv/gettext/en/LC_MESSAGES/errors.po`.

**A constraint error never arrives at `changeset.valid?` time.** `Repo.insert/1` on an invalid changeset issues **no SQL at all** — it returns `{:error, changeset}` without talking to Postgres. So the database only ever sees changesets that already passed every validation, and a validation error and a constraint error can never arrive together. A duplicate name is reported *after* the length check has passed, never alongside it.

> 💡 **Carried a habit from lesson 24?** Lessons 24, 25 and 29 all branched on `changeset.valid?` before deciding anything. That test is now incomplete: a changeset can be `valid?: true` and still come back from `Repo.insert/1` as `{:error, changeset}` with `"has already been taken"` on it. Branch on the `{:ok, _} | {:error, _}` tuple, not on `valid?`.

**The changeset helper enforces nothing — it translates.** `unique_constraint/3` adds no check to Elixir. All it does is register "if the adapter reports a violation of the index named *this*, turn it into an error on *that* field." Without the declaration a duplicate raises `Ecto.ConstraintError`, whose message helpfully names the constraint and tells you to call `unique_constraint/3` with it. With the declaration you get `{:error, changeset}`. The inverse is the dangerous half: declaring a constraint whose index **does not exist** is completely silent — no error, no warning, and duplicates simply land in the table. A missing migration is a data bug, not a crash, which is why `issue_changeset_test.exs` asks `pg_indexes` whether the index is really there.

**`NOT NULL` is the exception.** Postgres's not-null violation has no entry in the Postgres→Ecto constraint mapping, so there is no `null_constraint/3` to declare and Ecto re-raises the `Postgrex.Error` unchanged — which is exactly what `issues_table_test.exs` has been asserting since lesson 29. So the honest version of "the database is the last line of defence" is: **unique and foreign-key violations become changeset errors once you declare them; NOT NULL raises.**

**Which field the error lands on is your choice, and the default is wrong here.** `unique_constraint([:user_id, :name])` uses the list twice: to derive the index name (`projects_user_id_name_index`, matching what the migration builds — so write the columns in the same order in both places), and to pick the field the error attaches to, which is the **first** element. Without `error_key: :name` a duplicate project name lands on `:user_id` — a column with no input on any form. `<.input>` renders errors only for fields that were actually submitted, so the form would redisplay with *nothing shown at all*. That silent redisplay is the exact failure this lesson exists to remove, so both declarations pass `:error_key`.

**One error is invisible in the browser no matter what you do.** `foreign_key_constraint(:project_id)` attaches `"does not exist"` to `:project_id`, and no form has a `project_id` input — the context sets it on the struct. The test sees it; a person clicking around never will. That is correct: a bad `project_id` means something is wrong with your code or someone is tampering with URLs, not that the user mistyped. It is worth knowing which of your errors are for users and which are for you.

**`toggle_issue/1` skips the changeset on purpose, so none of this applies to it.** It flips a value the app controls; nothing came from a form, so it uses `Changeset.change/2` and never calls `Issue.changeset/2`. Note what `change/2` does *not* do: it neither casts nor validates. It asks whether each value differs from the struct's and stores what it is given. So a leftover `Changeset.change(issue, status: "closed")` — a string, after `status` became an enum — is `valid?: true` with no errors, and the failure comes one layer later, as an `Ecto.ChangeError` raised by `Repo.update!/1` when the enum refuses to dump a string. Loud, but not where you would look for it.

**This is not Tracker's first validation — it is the first *you* write.** `Tracker.Accounts.User` has shipped `validate_format/4`, `validate_length/3`, `validate_confirmation/3`, `unsafe_validate_unique/4` and `unique_constraint/3` since lesson 26, generated and unexplained. After this lesson there is nothing in that file you cannot read.

## The drills

Projects are the worked example and are done for you end to end — the enum, the trim, `validate_length`, the custom `validate_name/1`, the unique index migration and its declaration. Read `lib/tracker/projects/project.ex` first. Issues are yours:

1. **`Issue.changeset/2`.** Move the changeset out of `Tracker.Issues` into `lib/tracker/issues/issue.ex` as a public function, make `status` an `Ecto.Enum` and start casting it (today `Issues` doesn't cast `:status` at all), trim the title, add `validate_length(:title, max: 120)` and a custom `validate_title/1`. Then follow the atoms through: `flip/1` and `toggle_issue/1` still pattern-match strings. There is deliberately no `min:` on `:title` — carried tests use one-character titles.
2. **The issue constraints.** `mix ecto.gen.migration add_unique_issue_title_index` creating `unique_index(:issues, [:project_id, :title])`, then `unique_constraint([:project_id, :title], error_key: :title)` and `foreign_key_constraint(:project_id)` in `Issue.changeset/2`. The foreign key itself already exists from lesson 29; only the declaration is missing.

`mix test --include pending` shows **9** failing tests: six for drill 1 (four in `test/tracker/issue_changeset_test.exs`, two in `issues_test.exs` that now expect atoms) and three for drill 2.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=30-changesets-deep` from the repo root).
3. From the repo root, `docker compose up -d postgres`.
4. In `exercises/`, run `mix deps.get` and then `mix ecto.setup` — this lesson has its own database and it doesn't exist yet.
5. Run `mix test --include pending` — see the 9 failing drill tests. Make them pass.
6. Stuck? Read `HINTS.md` one hint at a time, and compare against `solutions/` only after you have a working answer.

## Try it

Start the app with `mix phx.server`, register at `/users/register` (open `/dev/mailbox` for the login link) and go to `/projects/new`. The status field is now a dropdown. Try a name of `"A"` — too short. Try `"!!!"` — no letter or number. Try saving with the status left on "Choose a status" — it saves as `open`, because a blank is an absent value, not a wrong one. Then create a second project with the **same name** as the first: the same form, the same red message, but that one round-tripped through Postgres to find out.

## Common mistakes

- **Postgres isn't running**, or you haven't run `mix ecto.setup` in this folder. Each lesson has its own database (`tracker_30_exercises_dev` here). See lesson 29's notes — the symptoms are identical.
- **The declared constraint name doesn't match the index.** `unique_constraint(:title)` infers `issues_title_index`; your migration creates `issues_project_id_title_index`. Nothing warns you — the duplicate just raises `Ecto.ConstraintError` at insert time. Pass the same column list, in the same order, as the index.
- **Editing a migration that already ran.** `mix ecto.migrate` skips any file already recorded in `schema_migrations`. Roll back first: `mix ecto.rollback` for the dev database, `MIX_ENV=test mix ecto.rollback` for the test one, which is separate and doesn't notice the dev rollback.
- **A half-finished enum.** `status` is an atom now, everywhere. Leave one `flip("open")` clause behind and `Repo.update!/1` raises `Ecto.ChangeError` — pointing at the dump, not at the clause you forgot.
- **`errors_on/1` raising instead of asserting.** It calls `String.to_existing_atom/1` on every `%{key}` it finds in a message, so a key whose atom hasn't been created anywhere in the VM blows up the helper rather than failing the assertion.

## Going further

- `check_constraint/3` moves an arbitrary SQL condition into the table. It is the one constraint with no inferrable name, so it **requires** `name:` — and a missing one raises `ArgumentError` while the changeset is being *built*, which breaks even an empty form.
- `unsafe_validate_unique/4` runs a `SELECT` during validation so the duplicate message arrives with the others. "Unsafe" is not a warning label but a fact: two simultaneous requests both see nothing and both insert. It is a nicety on top of the index, never a replacement — read its use in `lib/tracker/accounts/user.ex`.
- Live validation: a LiveView form with `phx-change="validate"` runs the changeset on every keystroke, and `Ecto.Changeset.apply_action(changeset, :validate)` is what forces the errors to show before anything is submitted.
- Now go read `lib/tracker/accounts/user.ex` top to bottom. It was generated in lesson 26 and you skipped it. There is no line in it you can't parse today.

## Links

- [`Ecto.Changeset`](https://hexdocs.pm/ecto/Ecto.Changeset.html)
- [`Ecto.Enum`](https://hexdocs.pm/ecto/Ecto.Enum.html)
- [Constraints and upserts](https://hexdocs.pm/ecto/constraints-and-upserts.html)
