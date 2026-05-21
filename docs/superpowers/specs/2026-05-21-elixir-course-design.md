# Elixir Training — Course Design

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-05-21
**Author:** Aki Ristkari (`aki@ristkari.dev`)

## Purpose

Design a self-study-friendly Elixir programming course that takes complete
beginners from "never written a line of code" to "shipped a small Phoenix web
app to production". The course is delivered as code (per-lesson Mix projects
with failing tests as the spec) plus reveal.js slide decks, following the same
shape as the prior intended Go course but expanded to incorporate Phoenix and
Ecto.

## Audience and outcome

- **Audience:** Complete beginners to programming. Elixir is their first
  language. The course teaches programming itself alongside the language.
- **End state:** A learner who completes the course can ship a small Phoenix
  web app — backed by Postgres via Ecto, with authentication, LiveView-powered
  interactive UI, background jobs, tests, and a Docker-image-based deployment
  pipeline — to a real host.
- **Engineering posture:** "Real Elixir engineer" rather than "Phoenix
  scripter". Heavy OTP foundation (processes, GenServer, supervisors, ETS,
  distribution) lands *before* Phoenix is introduced, so Phoenix is understood
  as "an OTP application that happens to serve HTTP".

## Curriculum

The course is a linear sequence of **41 numbered lessons** organized into
seven phases. Each lesson is one focused topic sized for roughly 1–2 hours of
work for a beginner.

### Phase 0 — Programming-101 in Elixir (lessons 00–04)

| # | Slug | Focus |
|---|---|---|
| 00 | `setup` | Install Erlang/OTP + Elixir via `asdf`, IEx, `mix new`, editor setup |
| 01 | `values-and-types` | Integers, floats, strings vs charlists, atoms, booleans, the shell as REPL |
| 02 | `pattern-matching` | `=` as match (not assignment); destructuring; cornerstone concept |
| 03 | `functions-and-modules` | Named/anonymous functions, arity, multiple clauses, guards |
| 04 | `control-flow` | `if`/`unless`, `case`, `cond`, `with`; "no loops" foreshadowed |

### Phase 1 — Elixir core (lessons 05–12)

| # | Slug | Focus |
|---|---|---|
| 05 | `recursion` | Head/tail recursion on lists; replaces `for` loops mentally |
| 06 | `enum-and-the-pipe` | `Enum`, `|>`, why immutability makes composition cheap |
| 07 | `collections` | Lists, tuples, maps, keyword lists; when to use which |
| 08 | `strings-and-binaries` | String ops, sigils, binary pattern matching |
| 09 | `streams` | Lazy enumeration, large-file processing |
| 10 | `structs-and-protocols` | `defstruct`, `defprotocol`, polymorphism Elixir-style |
| 11 | `error-handling` | `{:ok, _}`/`{:error, _}`, `raise` vs returning, `with` revisited |
| 12 | `mix-projects` | `mix new`, deps, `mix.exs`, ExUnit, formatter |

### Phase 2 — Concurrency & OTP (lessons 13–20)

| # | Slug | Focus |
|---|---|---|
| 13 | `processes` | `spawn`, `send`/`receive`, mailbox, isolation, "let it crash" intro |
| 14 | `tasks-and-agents` | Light-weight concurrency for common cases |
| 15 | `genserver-1` | State in a process; `call`/`cast`/`init`/`handle_*` |
| 16 | `genserver-2` | Timeouts, `handle_info`, common patterns, testing GenServers |
| 17 | `supervisors` | Supervision trees, restart strategies, `Supervisor.child_spec` |
| 18 | `otp-applications` | Application callback, app config, `mix release` preview |
| 19 | `ets` | Fast in-memory storage; when ETS vs GenServer |
| 20 | `distribution` | Node connections, `:rpc`, `Node`, libcluster overview |

### Phase 3 — Phoenix (lessons 21–28)

The threaded example app (`Tracker`, a small issue tracker) begins here.

| # | Slug | Focus |
|---|---|---|
| 21 | `plug` | `Plug.Conn`, function/module plugs, the request pipeline |
| 22 | `phoenix-tour` | `mix phx.new`, project structure, endpoint, router, dev workflow |
| 23 | `controllers-and-heex` | `conn`, actions, HEEx templates, layouts, core components |
| 24 | `forms-and-changesets-preview` | Render a form; just enough changesets to validate |
| 25 | `contexts` | The Phoenix context pattern; organizing business logic |
| 26 | `auth` | `mix phx.gen.auth`, sessions, route protection |
| 27 | `liveview-1` | mount/render/handle_event; server-rendered interactivity |
| 28 | `liveview-2` | Streams, PubSub, components, broadcasting updates |

### Phase 4 — Ecto deep dive (lessons 29–33)

| # | Slug | Focus |
|---|---|---|
| 29 | `schemas-and-migrations` | `schema`, `field`, types, migrations, indexes; migrates `Tracker`'s domain (projects, issues) from in-memory to Postgres (the users table was introduced in lesson 26 with `phx.gen.auth`) |
| 30 | `changesets-deep` | `cast`, validations, constraints, custom validations |
| 31 | `queries` | Query DSL, joins, preloads, dynamic queries |
| 32 | `associations` | `has_many`, `belongs_to`, `many_to_many`, preload strategies |
| 33 | `multi-and-transactions` | `Ecto.Multi`, transactions, rollback patterns |

### Phase 5 — Production (lessons 34–38)

| # | Slug | Focus |
|---|---|---|
| 34 | `testing` | ExUnit deep dive; `DataCase`/`ConnCase`/`LiveViewTest`; fixtures vs factories |
| 35 | `observability` | `Logger`, `:telemetry`, LiveDashboard, structured logs |
| 36 | `background-jobs` | Oban: workers, queues, scheduling, retries |
| 37 | `releases-and-docker` | `mix release`, runtime config, Dockerfile, Postgres via docker-compose |
| 38 | `fly-deploy` | Fly.io as a Docker-image platform shortcut |

### Phase 6 — Capstone (lessons 39–40)

| # | Slug | Focus |
|---|---|---|
| 39 | `capstone-build` | Final feature work on `Tracker` (learner picks from a small menu) |
| 40 | `capstone-ship` | Deploy to Fly, smoke-test, retrospective |

## Lesson template

Every lesson directory follows this shape:

```
lessons/NN-name/
├── README.md          self-study notes: objectives, key ideas, links
├── HINTS.md           progressively-revealed hints (beginner safety rail)
├── slides/
│   ├── index.html     reveal.js entry point (uses vendored runtime)
│   └── slides.md      lesson content in markdown
├── exercises/
│   ├── mix.exs        independent Mix project
│   ├── lib/           starter code with stubs (`raise "not implemented"`)
│   └── test/          failing ExUnit tests — the spec
└── solutions/
    ├── mix.exs
    ├── lib/           reference implementation
    └── test/          identical to exercises/test
```

### Conventions

- `exercises/` and `solutions/` are independent Mix projects (no umbrella).
  Learners can copy any single lesson directory elsewhere and have it work.
- `README.md` is self-study notes, not slide text. Top of every README is a
  "What you should be able to do" learning-objectives block.
- Slides are markdown rendered by reveal.js at runtime. reveal.js is vendored
  once under `shared/reveal/`.
- `HINTS.md` contains progressively-disclosed nudges. Order: try alone →
  read hint 1 → hint 2 → … → look at `solutions/`.

### Phoenix-era variant (lessons 21–40)

The same template, but `exercises/` and `solutions/` carry the threaded
`Tracker` app. Each Phase 3+ lesson's `exercises/` starts as the previous
lesson's `solutions/` plus new failing tests for the new feature. The lesson
adds one focused thing; this is a discipline enforced by review, not by tooling.

## Threaded example app: `Tracker`

A small issue tracker that grows lesson-by-lesson from Phase 3 onward.
Selected because it naturally exercises every concept the course teaches —
CRUD, contexts, auth, associations, joins, real-time updates, background
jobs — without bolting features on artificially.

### Data model (final)

- `User` — built by `phx.gen.auth`
- `Project` — `belongs_to :user`, `has_many :issues`
- `Issue` — `belongs_to :project`, `has_many :comments`, `many_to_many :assignees, User`
- `Comment` — `belongs_to :issue`, `belongs_to :user`

### Lesson-by-lesson growth

| Lesson | What it adds |
|---|---|
| 22 | `mix phx.new tracker` skeleton |
| 23 | Static "projects" index page from a hard-coded list |
| 24 | New-project form (in-memory; no DB yet) |
| 25 | `Projects` context, still in-memory |
| 26 | `phx.gen.auth` — introduces Postgres (users table only); projects still in-memory but now belong to a user |
| 27 | LiveView project board: issues update live in one tab |
| 28 | Multi-tab live updates via PubSub; live comments |
| 29 | Migrate projects/issues from in-memory to Postgres; deeper schemas + migrations |
| 30 | Validations, unique constraints, custom changeset functions |
| 31 | "My open issues across projects" — joins, preloads, dynamic queries |
| 32 | Issue ↔ Project, Issue ↔ Comment, Issue ↔ Assignees associations |
| 33 | Atomic "move issue between projects" via `Ecto.Multi` |
| 34 | Full test suite for `Tracker` |
| 35 | Telemetry + LiveDashboard for `Tracker` |
| 36 | Oban worker: email digest of stale issues |
| 37 | `mix release`, Dockerfile, docker-compose with Postgres |
| 38 | Push `Tracker` to Fly.io with a Postgres add-on |
| 39 | Learner-picked capstone feature (menu: search across issues / attachments / export) |
| 40 | Production deploy, smoke tests, retrospective |

## Tooling

### Toolchain learners install

- **Erlang/OTP and Elixir via `asdf`**, pinned in a top-level `.tool-versions`.
- **Docker** (for Postgres from lesson 26 onward — `phx.gen.auth` is the
  first DB-requiring lesson — and for the Phase 5 release lesson).
- An editor of their choice; lesson 00 lists known-good setups for VS Code
  (ElixirLS) and Neovim.

### Per-lesson Mix defaults

- `ExUnit` (the failing tests *are* the spec).
- `mix format` with a shared `.formatter.exs` at the repo root.
- `Credo` and `Dialyxir` — introduced from lesson 34 onward (not Phase 0, to
  avoid drowning beginners in warnings).
- `ExCoveralls` introduced alongside the testing deep-dive.

### Phoenix/Ecto-era additions

- `Phoenix`, `Phoenix.LiveView`, `Phoenix.PubSub`, `Ecto`, `Postgrex`.
- `Oban` for background jobs (lesson 36).
- `Swoosh` for email (used by Oban worker in lesson 36).
- Pinned versions in every `mix.lock`. Lock files are committed.

### Slides

- `reveal.js` vendored under `shared/reveal/`. Lesson `slides/index.html`
  loads the runtime; `slides/slides.md` is the lesson content.
- A small local HTTP server (matching the Go template's `make slides-dev`)
  serves them during authoring/teaching.

### Repo-level build tooling (Makefile targets)

- `make help` — list targets
- `make new-lesson NAME=NN-foo` — scaffold a new lesson from
  `shared/lesson-template/`
- `make slides-dev LESSON=NN-foo` — serve one lesson's slides on localhost
- `make test` — run every lesson's tests, excluding `@tag :pending`
- `make test-lesson LESSON=NN-foo` — run one lesson's tests
- `make lint` — formatter check + Credo across every Mix project
- `make solutions-test` — assert every `solutions/` project passes

`tools/` holds the actual scripts the Makefile invokes
(`tools/new-lesson`, `tools/slides-dev`, `tools/run-all-tests`,
`tools/check-solutions`, `tools/lint-all`). Elixir scripts where natural,
shell where not.

### CI

GitHub Actions workflow:

- Matrix across lesson directories
- Runs `make solutions-test` and `make lint`
- Slide-link check (catches dead links in markdown)
- Runs on the pinned `.tool-versions` Elixir + OTP

## Repository layout

```
elixir-training/
├── README.md                  course overview, prerequisites, quick start
├── .tool-versions             pinned Elixir + Erlang/OTP (asdf)
├── .formatter.exs             shared formatter rules
├── .credo.exs                 shared Credo config (active from lesson 34)
├── docker-compose.yml         Postgres for lessons that need a DB
├── Makefile                   help / new-lesson / slides-dev / test / lint / ci
│
├── lessons/                   all course content, numbered 00–40
│   ├── 00-setup/
│   └── ... through 40-capstone-ship/
│
├── shared/
│   ├── reveal/                vendored reveal.js + custom theme (no hand-edits)
│   └── lesson-template/       scaffold copied by `make new-lesson`
│       ├── README.md
│       ├── HINTS.md
│       ├── slides/
│       │   ├── index.html
│       │   └── slides.md
│       ├── exercises/
│       │   ├── mix.exs
│       │   ├── lib/.gitkeep
│       │   └── test/.gitkeep
│       └── solutions/
│           ├── mix.exs
│           ├── lib/.gitkeep
│           └── test/.gitkeep
│
├── tools/                     dev scripts the Makefile invokes
│   ├── new-lesson
│   ├── slides-dev
│   ├── run-all-tests
│   ├── check-solutions
│   └── lint-all
│
├── docs/
│   └── superpowers/
│       ├── specs/             this document
│       └── plans/             writing-plans output
│
└── .github/
    └── workflows/
        └── ci.yml
```

Notes:

- **No top-level Mix project, no umbrella.** Each `exercises/` and
  `solutions/` is independent so one lesson's deps cannot constrain another's
  and learners can copy a single lesson elsewhere and have it work.
- **The threaded `Tracker` app is not a special directory** — it lives inside
  each Phase 3+ lesson's `exercises/` and `solutions/`. The "thread" is the
  convention that each lesson's exercise starter is the previous lesson's
  solution.

## Testing strategy: failing tests as the spec

### What makes a good exercise test

- Imports the learner's not-yet-written module and calls it — failing first
  for the right reason (`UndefinedFunctionError`), then a wrong assertion,
  then green.
- Names the function/module the learner must create — beginners shouldn't
  invent APIs.
- Asserts behavior, not implementation. No tests against private internals.
- Clear failure message — readable without reading the test source.

Example exercise (lesson 05):

```elixir
# exercises/05-recursion/lib/sum.ex
defmodule Sum do
  @doc "Sum a list of integers."
  def of(_list), do: raise "not implemented"
end

# exercises/05-recursion/test/sum_test.exs
defmodule SumTest do
  use ExUnit.Case
  doctest Sum

  test "Sum.of/1 sums a list of integers" do
    assert Sum.of([1, 2, 3, 4]) == 10
  end

  test "Sum.of/1 returns 0 for an empty list" do
    assert Sum.of([]) == 0
  end
end
```

### Hints, not solutions

`HINTS.md` per lesson, progressive:

```
## Hint 1
Recursion on lists splits into "what to do with an empty list" and
"what to do with [head | tail]".

## Hint 2
Empty list: the sum is 0.

## Hint 3
Non-empty: head + recurse on the tail.
```

### Tags

- `@tag :pending` — tests in `exercises/` that *should* fail before the
  learner starts. `make test` skips them by default; learners run
  `mix test --include pending` inside the lesson directory.
- `@tag :solution` — optional, for tests that should only run in
  `solutions/` (e.g., longer property-based tests).

### CI-enforced invariants

1. **Every `solutions/` project must pass `mix test`** with zero failures and
   zero warnings. `tools/check-solutions` is the runner.
2. **Every `exercises/` project must compile.** Tests can fail; the project
   must build.

### Phoenix-era twist

From Phase 3 onward, lessons use `ConnCase` for controller actions,
`LiveViewTest` for LiveView, `DataCase` for Ecto. Lesson 34 teaches these
patterns properly; earlier Phase 3 lessons use them and reference docs
without ceremony.

### LiveView caveat

`Phoenix.LiveViewTest` is good but doesn't fully exercise browser behavior.
We use it for what it covers and accept one or two manual-verification steps
in the Phase 6 capstone. We do **not** introduce a browser-driver dependency
(Wallaby/Hound) — too much surface for this audience.

## Pedagogical design notes

- **Beginners-first, generators-aware.** Phoenix generators (`phx.gen.html`,
  `phx.gen.context`, `phx.gen.live`, `phx.gen.auth`) are taught explicitly —
  beginners learn the generators *and* what they generate.
- **Bottom-up Phoenix.** Plug first (the conn pipeline), then controllers +
  HEEx, then LiveView. Learners understand the whole stack before reaching
  the modern default.
- **OTP before Phoenix.** Phase 2 finishes (including a distribution intro)
  before Phase 3 starts. By the time learners see LiveView ("a stateful
  process per connection") they already understand processes and state.
- **One growing app from Phase 3 on, one new test file per lesson.** A
  discipline that keeps Phoenix-era lessons honest in scope.

## Deferred decisions

- **Exact slide content and pacing.** Spec defines the lesson list and
  template; slide narrative is authored lesson-by-lesson. Style guide
  stabilizes after the first one or two lessons.
- **Capstone feature menu (lesson 39).** Pick from search across issues /
  file attachments / issue export when we get there.
- **Property-based testing (StreamData) lesson.** Mentioned in lesson 34 as
  an aside; whether it earns its own sub-lesson is an authoring-time call.
- **Internationalization / Gettext.** Brief mention in the LiveView lesson,
  no dedicated lesson.

## Risks

1. **Phoenix version drift.** Phoenix iterates fast. Mitigation: pin versions
   in every `mix.exs`, document the pin in lesson READMEs, run CI on pinned
   `.tool-versions`.
2. **Beginner overload at the OTP → Phoenix transition.** Phase 2 ends with
   distribution; Phase 3 starts with Plug. Mitigation: a deliberately gentle
   lesson 21 framing Phoenix as "an OTP application that handles HTTP",
   tying back to Phase 2 mental models.
3. **`asdf` install friction on Apple Silicon for older OTP.** Lesson 00
   should include known-good install commands and link to community docs.
   Test setup on macOS and Linux before publishing.
4. **`solutions/` rot.** `make solutions-test` in CI is the safety net.
   `mix.lock` committed for every project.
5. **`Tracker` scope creep.** One focused addition per Phase 3+ lesson;
   exceptions need a comment in the lesson README explaining why.
6. **Authoring effort.** ~41 lessons × (README + slides + exercises +
   solutions + hints) is substantial. Suggested authoring order: Phase 0 → 1
   → 2 → 3 first so the course is shippable in stages, then 4–6.

## Explicit non-goals (YAGNI)

- No Nerves / embedded Elixir track.
- No Nx / ML track.
- No GraphQL (Absinthe) track. JSON via Phoenix controllers is enough.
- No Phoenix Channels lesson — LiveView covers the real-time use case for
  this audience.
- No deep multi-node Phoenix cluster deployment — distribution is taught in
  Phase 2 as a BEAM concept; we do not run a distributed `Tracker`.
- No third-party auth providers (Auth0, OAuth) — `phx.gen.auth` only.
- No course-management web app, video infrastructure, or auto-grader beyond
  `mix test`.
- No custom slide build system — markdown + vendored reveal.js is enough.

## Success criteria

The course is "done" (v1) when:

- All 41 lesson directories exist and pass `make solutions-test` in CI.
- A new learner with no prior programming experience can work through Phase 0
  using only the lesson README, slides, hints, and exercises — without
  outside help — and pass the tests.
- A learner who completes lessons 22–40 has a working `Tracker` deployed on
  Fly.io reachable at a public URL.
- `make new-lesson NAME=NN-foo` produces a working lesson skeleton in under
  five seconds.
- The README explains how to use the course as both self-study and
  instructor-led material.
