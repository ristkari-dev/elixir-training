# Phase 0 Design — Programming-101 in Elixir

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-05-22
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Course design:** [`2026-05-21-elixir-course-design.md`](2026-05-21-elixir-course-design.md)

## Purpose

This spec covers the five lessons of Phase 0 — the entry phase of the
Elixir course — for an audience of complete beginners to programming.
By the end of Phase 0, a learner has installed Elixir, written code in
IEx and in a Mix project, and absorbed the four foundational concepts
the rest of the course leans on: values & types, pattern matching,
functions & modules, and control flow.

Phase 0 lessons:

| # | Slug | Focus |
|---|---|---|
| 00 | `setup` | What programming is, install Erlang/OTP + Elixir via asdf, IEx, first Mix project, editor setup |
| 01 | `values-and-types` | Integers, floats, booleans, atoms, strings vs charlists, the REPL |
| 02 | `pattern-matching` | `=` as match (not assign); destructuring; the cornerstone idea |
| 03 | `functions-and-modules` | Named/anonymous functions, arity, multiple clauses, guards |
| 04 | `control-flow` | `case`, `cond`, `with` preview; pattern matching reframed as control flow |

## Audience and posture

- **Starting point:** computer-literate but never programmed. The
  learner can install software and use a browser. They have not opened
  a terminal, not edited code in a text editor, and do not know what a
  variable, function, or "running a program" means in a technical
  sense.
- **Tone:** conversational + everyday analogies. Writes like a patient
  mentor. Acknowledges "this feels weird at first" moments. No
  textbook stiffness; no sparse code-only slides.
- **Posture about IEx vs Mix:** hybrid — REPL is the teacher (instant
  feedback during exploration), Mix is the gym (small failing tests
  that build muscle memory).

## Per-lesson shape (lessons 01–04)

Each Phase 0 lesson uses the existing `shared/lesson-template/`
template scaffolded by `tools/new-lesson`. Lesson 00 is the one
deviation — it has no `exercises/` or `solutions/` Mix project (see
"Lesson 00 — deviation from the template" below).

### `README.md` (~600–900 words, conversational tone)

- One-paragraph hook ("By the end of this lesson, you'll be able to…").
- "Key ideas" — 2–4 concepts, each explained with one everyday
  analogy.
- "How to work this lesson" — read README → skim slides → IEx
  exploration → make exercise tests pass → check `solutions/`.
- "Common mistakes" — 3–4 things beginners hit.
- "Going further" — 2–3 stretch ideas, no reference solutions.
- "Links" — 2–3 canonical Elixir docs / HexDocs entries.

### `HINTS.md`

Three progressively-revealed hints (gentle → specific →
almost-the-answer) per main exercise. Beginners read them one at a
time when stuck.

### `slides/slides.md`

Uses the heavy-explanatory pattern from `CONTRIBUTING.md`:

1. Title slide (lesson #, title, one-sentence goal).
2. One concept block per topic. Each block = motivation → basics →
   worked example → common mistake → recap, laid out as vertical sub-
   slides (`--` separator) so reveal.js's "code goes down" navigation
   gives learners the explanation and the code on different presses.
3. Closing slide pointing to the next lesson.
4. Speaker notes (`Note:`) for live-lecture commentary.

Cap: ≤ 4 concept blocks per lesson, ≤ 20 slides total.

### `exercises/`

A small Mix project with **3–5 micro-drills**. Each drill:

- One function (or small module) with a `raise "TODO: ..."` stub.
- 1–2 ExUnit tests carrying `@tag :pending`.
- Learner runs `mix test --include pending`, sees the failures, makes
  them pass.

File layout — one module per file, one `_test.exs` per module:

```
lessons/01-values-and-types/exercises/
├── mix.exs
├── lib/
│   ├── math.ex       # defmodule Math do
│   ├── greet.ex      # defmodule Greet do
│   └── status.ex     # defmodule Status do
└── test/
    ├── math_test.exs
    ├── greet_test.exs
    └── status_test.exs
```

This sets the convention later lessons follow.

### `solutions/`

Same shape as `exercises/`, reference implementation, all tests pass.

## Lesson 00 — deviation from the template

Lesson 00 is the patient onboarding lesson. It has **no** `exercises/`
or `solutions/` Mix project — the "exercise" is "you successfully ran
code on your machine."

### Scope

`README.md` — ~1500–2000 words:

- "What is programming, and what is Elixir?" — 3-paragraph
  orientation. Programming as instructions for a computer; Elixir as
  a friendly, fault-tolerant language that runs on the BEAM virtual
  machine. No analogies that mislead later.
- "What you'll need" — a computer (macOS or Linux), ~5 GB free disk
  (asdf + OTP + Elixir + Xcode CLT or build tools), internet, a
  couple of hours.
- "macOS path" — install Homebrew → install `asdf` via Homebrew → add
  asdf to shell → `asdf install` Erlang + Elixir. Annotated commands
  with expected output snippets.
- "Linux path" — install asdf via git clone → add to shell → `asdf
  install` Erlang + Elixir.
- "Windows learners — use WSL2" — short pointer to Microsoft's WSL2
  install guide; from inside WSL2, follow the Linux path.
- "Your first Elixir program" — open IEx, type `1 + 1`, type
  `IO.puts("Hello, Elixir!")`. Screenshots of expected output.
- "Your first Elixir file" — install VS Code + ElixirLS extension,
  `mix new hello`, edit `lib/hello.ex`, run `mix test`.
- "Troubleshooting" — six common failure modes with explicit fixes
  (PATH not updated, OpenSSL missing on Linux, Rosetta/Apple Silicon
  issues, line-ending issues, etc.).
- "What we did, and what's next" — short recap pointing to lesson 01.

`slides/slides.md` — ~12–15 slides:

- Title + "what we'll do today".
- "What is Elixir?" — one slide of vibes, one of "real things people
  build with it".
- One slide per major install step, with the actual command +
  expected output.
- A "you just ran code" celebration slide.
- Closer pointing to lesson 01.

`HINTS.md` — has "stuck on install?" sections per platform with
troubleshooting flowcharts rather than progressive hints.

### Why the deviation

Forcing a Mix exercise into lesson 00 would compete for attention
against the install/setup work. The lesson's purpose is to get a
working Elixir on the learner's machine and prove it with `1 + 1` in
IEx. Adding `mix test` ceremony dilutes that.

The lesson 00 directory still gets `README.md`, `HINTS.md`, and
`slides/` — the four-part shape minus exercises/solutions. The
`tools/new-lesson` scaffolder is **not** used; lesson 00 is
hand-crafted. The README for lesson 00 carries a note explaining the
deviation so future authors don't think the template was forgotten.

`tools/run-all-tests`, `tools/check-solutions`, and `tools/lint-all`
already use `nullglob` so an absent `exercises/`/`solutions/` doesn't
break CI.

## Lessons 01–04 — concept breakdown

### Lesson 01 — `values-and-types`

**Concepts:** integers, floats, booleans, atoms (`:ok`, `:error`),
strings (binaries) vs charlists, the shell as REPL. Variable binding
(`x = 1`) introduced briefly but reframed as "match" rather than
"assign" so lesson 02 doesn't surprise.

**Analogies:**

- An atom is a named constant — a bookmark with no contents, just the
  name.
- A string is text in quotes.
- `x = 1` is "give the name `x` to the value `1`" (deliberately not
  "assign" — sets up lesson 02).

**Micro-drills (3):**

1. `Math.add/2` — sum of two integers.
2. `Greet.hello/1` — takes a name string, returns `"Hello, <name>!"`.
3. `Status.ok?/1` — `true` if argument is the atom `:ok`, else
   `false`.

### Lesson 02 — `pattern-matching`

**Concepts:** `=` as *match* not assign; destructuring tuples and
lists; the `_` wildcard; matching on literal values; rebinding caveat
(Elixir allows it, unlike Erlang).

**Analogies:**

- Pattern matching as "checking a parcel against a shape on the
  table" — if it fits, the parts get names; if it doesn't, the
  program complains. The variable's name labels a slot the parcel
  must fill.

**Micro-drills (4):**

1. `Pairs.first/1` — destructure `{first, _}` from a tuple.
2. `Pairs.second/1` — destructure `{_, second}`.
3. `Status.unwrap/1` — match `{:ok, value}` and return `value`;
   `{:error, _}` returns `nil`.
4. `Coords.origin?/1` — match `{0, 0}`, return `true`; otherwise
   `false`.

### Lesson 03 — `functions-and-modules`

**Concepts:** named functions in modules (`defmodule … do … def
name(args) do … end end`), anonymous functions (`fn x -> x + 1 end`
and the `&` shorthand), arity (`name/2`), multiple function clauses,
guards (`when is_integer(x)`).

**Analogies:**

- A module is a folder of related functions.
- A function is a recipe with named ingredients (arguments) that
  produces a result.
- Multiple clauses are "try this clause first; if its pattern doesn't
  match, try the next one."
- Guards are an extra "and the value must be an integer" check.

**Micro-drills (5):**

1. `MyMath.double/1` — return `x * 2`.
2. `MyMath.area_of_rectangle/2` — return `w * h`.
3. `Greeter.hello/1` with two clauses: matches `"world"` → `"Hello,
   world!"`; anything else → `"Hello, <name>!"`.
4. `Numbers.classify/1` with guards: negative → `:negative`, zero →
   `:zero`, positive → `:positive`.
5. `Apply.twice/2` — takes a function and a value; returns `f.(f.(x))`.
   Exercises anonymous-function passing.

### Lesson 04 — `control-flow`

**Concepts:** `if`/`unless` (mention but de-emphasise — they're
sugar), `case`, `cond`, `with` (preview only — full treatment in
lesson 11). Pattern matching is the *real* control flow in Elixir;
this lesson reframes the `if`/`else` mindset.

**Analogies:**

- `case` is "try each pattern in order until one matches" — the same
  shape as multiple function clauses, just inline.
- `cond` is "first true wins" (like `else if` chains in other
  languages).
- `with` is "a chain of OK-or-fail steps that short-circuits."

**Micro-drills (5):**

1. `Sign.of/1` — `cond` returning `:negative` / `:zero` / `:positive`.
   Compare against lesson 03's guard-based version.
2. `Traffic.action/1` — `case` matching atom `:red` → `"stop"`,
   `:yellow` → `"slow"`, `:green` → `"go"`.
3. `Account.status/1` — `case` matching `{:ok, balance}` when `balance
   > 0` → `:open`, `{:ok, 0}` → `:empty`, `{:error, _}` → `:closed`.
4. `Steps.run/1` — `with` chaining `{:ok, _}` returns from three
   helper functions; any `:error` short-circuits.
5. `Pick.first_match/2` — given a list and a predicate (anonymous
   function), return the first element where the predicate is true;
   otherwise `nil`. Reinforces lesson 03's anonymous-function passing
   inside a `case`.

### Concept progression

The progression is deliberate:

- Lesson 02 plants the "matching" idea.
- Lesson 03 uses it in function clauses and adds guards.
- Lesson 04 generalises it: `case` is inline clauses; `cond` is
  chained ifs; `with` is chained `{:ok, _}` steps.

By the end of Phase 0 the learner has touched every building block
they'll see in Phase 1 (recursion needs lesson 03's clauses; `Enum`
lessons will use lesson 04's `case`/`with`).

## Authoring conventions

### REPL-transcript formatting

When a slide or README shows IEx output, format consistently:

```
iex> 1 + 1
2
iex> name = "Aki"
"Aki"
iex> "Hello, " <> name <> "!"
"Hello, Aki!"
```

- Prompt is always `iex>`. Continuation is `...>`.
- Output goes on the line immediately below the input, no blank
  line.
- We do **not** show `iex(1)>` numbered prompts — they're noise for
  beginners.

### Inline "first time?" beginner asides

Drop short asides where a beginner is likely to be lost:

> 💡 **First time seeing this?** A "function" is a named recipe —
> `add(2, 3)` calls the recipe named `add` with ingredients `2` and
> `3`, and gets back `5`.

The `> 💡` marker lets beginners spot asides while experienced
readers skim past them.

## Definition of done — Phase 0 v1

1. All five lesson directories (`lessons/00-setup/` …
   `lessons/04-control-flow/`) exist and are committed.
2. `make solutions-test` is green (lessons 01–04 contribute; lesson 00
   has nothing to test).
3. `make lint` is clean.
4. `make slides-build` produces a `dist/index.html` where lessons
   00–04 light up as "published" (not future cards). The Cloud Run
   deploy continues to work end-to-end.
5. A complete beginner with a fresh macOS or Linux box can work
   through lessons 00–04 using only the README + slides + hints +
   exercises, without outside help, and finish with `make
   solutions-test` green on their machine.

## Risks

- **Lesson 00 install instructions drift.** asdf, Homebrew, apt/dnf,
  OpenSSL packaging all evolve. Add a CI smoke that runs the lesson 00
  install commands inside a fresh container periodically (post–Plan B
  follow-up; out of scope for the initial author pass).
- **Analogy mismatch with later content.** A lesson-01 analogy that
  misleads about lesson-13 process behaviour is worse than no analogy.
  Author pass should sanity-check every analogy against the
  Phase 2/3 lessons that depend on the same mental model — flagged
  for the writing-plans pass.
- **Pacing for the very first hour.** Lesson 00 + Lesson 01 together
  may be too much in one sitting. We won't enforce a sitting boundary;
  lesson 00's README ends with "take a break before lesson 01."
- **Heavy-explanatory slide pattern can balloon.** Five concept blocks
  × five sub-slides = 25 slides per lesson, which is too much. Cap
  ≤ 4 concept blocks per lesson, ≤ 20 slides total (enforced by author
  discipline; reviewer to flag overflow).

## Deferred decisions

- **The exact troubleshooting list** for lesson 00 is best assembled
  after the first beginner actually runs through it; the spec lists
  the categories, the writing-plans pass commits to concrete entries.
- **Whether to add a Phase 0 "graduation" mini-project** (e.g., a
  tiny ROT13 cipher) as a Phase 0 capstone lesson `04a`. Decided
  against for now — Phase 1 lesson 05 (recursion) is the natural next
  thing. Revisit if beginner feedback says Phase 0 ends too abruptly.

## Explicit non-goals (YAGNI)

- No Windows-native install path. WSL2 pointer only.
- No browser-based playground / online IEx. Learners install locally.
- No video walkthroughs in v1.
- No solutions to "Going further" stretch problems — deliberate.
- No automated grader beyond `mix test --include pending`.
- No per-lesson glossary; common terms get covered in the lesson
  where they first appear.
