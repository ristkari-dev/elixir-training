# Phase 1 Design — Elixir Core

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-05-26
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Course design:** [`2026-05-21-elixir-course-design.md`](2026-05-21-elixir-course-design.md)
**Phase 0 spec:** [`2026-05-22-phase-0-design.md`](2026-05-22-phase-0-design.md)

## Purpose

Phase 1 takes a learner who has just finished Phase 0 (basic types,
pattern matching, modules, functions, control flow) and brings them to
"can write idiomatic Elixir code that processes data." By the end of
Phase 1, the learner has:

- Written recursive list functions and seen them replaced by `Enum`.
- Internalised the pipe operator.
- Mapped, filtered, reduced, and lazily streamed data.
- Worked with maps, tuples, lists, keyword lists.
- Parsed strings and binaries.
- Defined structs and implemented one protocol.
- Used the `{:ok, _}` / `{:error, _}` convention with `with` chains.
- Built a tiny CLI tool with Mix and `mix escript.build` (the Phase 1 capstone).

Phase 1 lessons:

| # | Slug | Focus |
|---|---|---|
| 05 | `recursion` | Head/tail recursion on lists; replaces `for` loops mentally |
| 06 | `enum-and-the-pipe` | `Enum.map`/`filter`/`reduce`, the pipe operator |
| 07 | `collections` | Lists, tuples, maps, keyword lists; when to use which |
| 08 | `strings-and-binaries` | String ops, sigils, binary pattern matching |
| 09 | `streams` | Lazy enumeration; pure + file-based examples |
| 10 | `structs-and-protocols` | `defstruct` deep; `defprotocol` introduced lightly |
| 11 | `error-handling` | `{:ok, _}`/`{:error, _}`, `raise`, `with` revisited |
| 12 | `mix-projects` | Phase 1 capstone — build a `wc_ex` CLI with `mix escript.build` |

## Audience and posture

- **Starting point:** completed Phase 0. Knows basic types, atoms,
  tuples, pattern matching, modules, named/anonymous functions,
  multiple clauses, guards, `case`/`cond`/`with` (preview).
- **Tone:** carries over from Phase 0 — conversational + everyday
  analogies, patient mentor.
- **Cadence:** Phase 0 covered 5 lessons across foundational
  bootstrapping. Phase 1 covers 8 lessons of "the Elixir you actually
  write" plus a capstone CLI.

## Inherited conventions (all Phase 0 conventions apply)

- Standard lesson template: `README.md` (~600–900 words), `HINTS.md`
  (~200–500 words), `slides/index.html`, `slides/slides.md`
  (≤ 4 concept blocks, ≤ 20 slides), `exercises/`, `solutions/`.
- 3–5 micro-drills per lesson.
- REPL transcript convention: plain `iex>` (not numbered).
- Beginner asides marked with `> 💡 **First time seeing this?** …`.
- All exercise tests carry `@tag :pending`. Solution test files are
  byte-identical to exercise test files; the `test_helper.exs`
  difference (`exclude: [pending: true]` vs `ExUnit.start()`) is the
  only intentional divergence.
- `@moduledoc` required on every drill module.
- Lines ≤ 98 chars so `mix format` doesn't wrap.
- One module per file; one `_test.exs` per module.
- Slide style follows the heavy-explanatory pattern from
  `CONTRIBUTING.md` (motivation → basics → worked → mistake → recap,
  laid out vertically with `--`).

## Phase 1 conventions (new on top of Phase 0)

### "Recall from lesson NN" pointers

Phase 1 lessons build on each other. When a lesson directly uses a
concept from an earlier lesson, the `Key ideas` section opens with a
one-line "Recall from lesson NN: …" pointer. Example for lesson 06:

> Recall from lesson 05: you wrote recursive functions that walk a
> list head-by-tail. `Enum` is that recursion written for you.

Lesson 12 has several such pointers since it pulls from 06, 08, 09, 10.

### Test fixtures for file-based drills

Two lessons (09 and 12) need real files to read. Each gets a
`test/fixtures/` directory committed under both `exercises/` and
`solutions/`:

```
lessons/09-streams/exercises/test/fixtures/sample.log
lessons/09-streams/solutions/test/fixtures/sample.log     (byte-identical)
lessons/12-mix-projects/exercises/test/fixtures/lorem.txt
lessons/12-mix-projects/solutions/test/fixtures/lorem.txt (byte-identical)
```

Fixture files are small (10–50 lines), deterministic, committed.
Tests reference them via `Path.join(__DIR__, "fixtures/<name>")`
so they don't depend on `cwd`.

### Capstone CLI lives inside lesson 12 only

Lesson 12's `wc_ex` is a normal Mix project under
`lessons/12-mix-projects/{exercises,solutions}/` — same template
shape as every other lesson. The only deviations:

- `mix.exs` adds `escript: [main_module: WcEx.CLI]` so
  `mix escript.build` produces a runnable binary.
- The `solutions/` build produces a binary at
  `lessons/12-mix-projects/solutions/wc_ex` that's gitignored (root
  `.gitignore` already covers `_build/` and `*.ez`; this lesson's
  `.gitignore` adds an explicit `wc_ex` entry).
- The lesson README closes with
  `mix escript.build && ./wc_ex test/fixtures/lorem.txt` as the
  "demo it works" moment.

## Lessons 05–12 — concept breakdown

### Lesson 05 — `recursion`

**Concepts:** base case + recursive case on lists; head/tail
decomposition (`[h | t]`); the accumulator pattern (helper function
with an extra carrying argument); single-sentence mention of
tail-call optimisation (no deep dive — that's a stretch goal).

**Analogies:**

- Recursion is "calling yourself with the rest of the work."
- The base case is "what happens when there's no work left."
- The accumulator is "the jar you keep dropping things into as
  you go."

**Drills (4):**

1. `Sum.of/1` — sum a list of integers via head/tail.
2. `Counter.length/1` — your own `length` for a list.
3. `Mapper.double_all/1` — recursive analogue of `Enum.map` over
   doubling.
4. `Reverser.reverse/1` — uses the accumulator pattern (public
   `reverse/1` calls private `reverse/2` with an empty acc).

### Lesson 06 — `enum-and-the-pipe`

**Concepts:** `Enum.map/2`, `Enum.filter/2`, `Enum.reduce/3`. The
pipe operator `|>`. Why most idiomatic Elixir uses `Enum` + `|>`
rather than hand-rolled recursion.

**Recall from lesson 05:** "you wrote recursive functions that
walk a list head-by-tail. `Enum` is that recursion written for you."

**Analogies:**

- Pipe as a conveyor belt — value flows left to right through
  functions.
- `Enum.reduce/3` as "give me a starting jar and a recipe for adding
  the next item."

**Drills (4):**

1. `Lists.doubled/1` — same shape as lesson 05's
   `Mapper.double_all/1`, but using `Enum.map`. README explicitly
   compares.
2. `Lists.evens/1` — `Enum.filter`.
3. `Lists.sum/1` — `Enum.reduce` with `0` accumulator and `+`.
4. `Pipeline.pipeline/1` — given a list of integers, return the
   sum of squares of the even ones, in a single `|>` pipeline.

### Lesson 07 — `collections`

**Concepts:** lists (sequential, head-tail access), tuples (fixed-
size, positional), maps (key-value, atom or any-key), keyword lists
(`[name: "Aki"]` sugar over `[{:name, "Aki"}]`). `Map.get/2`,
`Map.put/3`, `Map.update/4`. Atom-keyed map shorthand `%{name: "Aki"}`.
Keyword-list lookup with `Keyword.get/3`.

**Drills (3):**

1. `Freq.count/1` — word-frequency map:
   `["a", "b", "a"] |> Freq.count()` → `%{"a" => 2, "b" => 1}`.
2. `Config.get/3` — keyword-list lookup with default:
   `Config.get([host: "x"], :host, "localhost")` returns `"x"`;
   missing key returns the default.
3. `MapMerge.deep/2` — recursive merge of two atom-keyed maps,
   merging nested maps key-by-key. Callback to lesson 05.

### Lesson 08 — `strings-and-binaries`

**Concepts:** `String.upcase`/`downcase`/`split`/`contains?`. The
`<<>>` binary syntax. Binary pattern matching to parse fixed-format
data. Sigils introduced briefly: `~w(a b c)` for word lists, `~r/.../`
for regex (mentioned only, no deep dive).

**Drills (4):**

1. `Letters.vowel_count/1` — count vowels in a string.
2. `Letters.title_case/1` — capitalize the first letter of every
   word.
3. `Header.parse/1` — given a binary like
   `<<version, length, rest::binary>>`, return `{version, length, rest}`.
4. `KV.parse_line/1` — parse `"name=Aki"` into `{"name", "Aki"}` via
   `String.split/2`.

### Lesson 09 — `streams`

**Concepts:** lazy enumeration as a recipe rather than a list.
`Stream.iterate/2`, `Stream.repeatedly/1`, `Stream.cycle/1`,
`Stream.map`, `Stream.filter`. The "you don't pay until you
`Enum.take` or pipe to an `Enum.*`" mental model. One file-based
worked example using `File.stream!`.

**Drills (3):**

1. `Fibs.take/1` — first N Fibonacci numbers via `Stream.iterate`
   over `{prev, curr}` pairs, then `Enum.take(n)` and `Enum.map(&elem(&1, 0))`.
2. `Naturals.evens_below/1` — first N even naturals via
   `Stream.iterate` + `Stream.filter` + `Stream.take`.
3. `LogStats.count_errors/1` — given a file path, count lines
   containing `"ERROR"`, processed lazily with
   `File.stream!(path) |> Stream.filter(...) |> Enum.count()`.
   Fixture: `test/fixtures/sample.log` with ~20 lines, 5 of them
   containing `ERROR`.

### Lesson 10 — `structs-and-protocols`

**Concepts:** `defstruct` with `@enforce_keys`. Struct creation
syntax `%MyStruct{x: 1, y: 2}`. Structs are maps under the hood
(`Map.get`, `Map.put` work; `Map.merge` may surprise — covered).
Protocols introduced lightly as "the mechanism that lets `Enum.map`
work on lists, ranges, and streams." One protocol drill
(`String.Chars`).

**Drills (3):**

1. `Point` — `defstruct [:x, :y]`, with `Point.new/2`,
   `Point.distance/2` (Euclidean distance between two points).
2. `Box` — `defstruct` with `@enforce_keys [:width, :height]`, plus
   `Box.area/1`. Test asserts that omitting a required key raises at
   compile/runtime.
3. `defimpl String.Chars, for: Point` so
   `to_string(%Point{x: 1, y: 2})` returns `"(1, 2)"`. The full
   protocol mental model is not required — this is "you can hook
   into a stdlib protocol."

### Lesson 11 — `error-handling`

**Concepts:** `{:ok, _}` / `{:error, _}` tagged-tuple convention.
`raise` for unrecoverable, returns for expected failures.
`try`/`rescue` briefly. `with` revisited deeper than lesson 04's
preview — explicit `else` clauses, multi-step chains.

**Drills (3):**

1. `SafeDiv.divide/2` — return `{:ok, q}` for normal,
   `{:error, :div_by_zero}` for divisor zero.
2. `Parse.integer/1` — wrap `Integer.parse/1` to return
   `{:ok, n}` / `{:error, :invalid}` (handles both the trailing-
   garbage case and the no-match case).
3. `Pipeline.run/1` — a `with` chain across three steps that may
   fail; uses a real `else` clause to remap errors.

### Lesson 12 — `mix-projects` (Phase 1 capstone)

**Concepts:** `mix new` with `--module`, `mix.exs` structure, `deps`
block, ExUnit, `mix test`, `mix format`, `mix escript.build`. The
relationship between `mix.exs` `app:` and module names.

**Recall from lessons 06, 08, 09, 10.** Lesson 12 explicitly threads
those concepts back together — Enum reductions, string splitting,
file streaming, and a small struct.

**Capstone — `wc_ex`:** a small CLI that reads a file path from
argv and prints `<lines>\t<words>\t<chars>\t<path>` to stdout —
mimicking Unix `wc`'s default output.

**Drills (3):**

1. `WcEx.Counts` — `defstruct [lines: 0, words: 0, chars: 0]` with
   `WcEx.Counts.add/2` (a reducer that takes the current `%Counts{}`
   and a line of text and returns an updated `%Counts{}`).
2. `WcEx.count_file/1` — takes a path, returns a `%Counts{}`. Uses
   `File.stream!` and `Enum.reduce` with `WcEx.Counts.add/2`.
3. `WcEx.CLI.main/1` — the escript entry point. Reads argv, calls
   `count_file/1`, formats output as `<lines>\t<words>\t<chars>\t<path>`,
   and prints via `IO.puts`. Run via `mix escript.build && ./wc_ex some.txt`.

**mix.exs additions** (in both exercises and solutions):

```elixir
def project do
  [
    app: :wc_ex,
    version: "0.1.0",
    elixir: "~> 1.18",
    escript: [main_module: WcEx.CLI],
    deps: deps(),
    test_coverage: [tool: ExCoveralls],
    preferred_cli_env: [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.html": :test
    ]
  ]
end
```

Lesson 12's `.gitignore` adds `wc_ex` (the built binary).

## Authoring conventions recap

- Length targets: README 600–900 words (700–1000 for lesson 12);
  HINTS 200–500 words; slides ≤ 20.
- Drill code is exact (modules, function names, doctest examples).
  README/HINTS/slides are detailed outlines — the implementer writes
  the prose within the structure.
- Closer slide on every lesson points to the next lesson with the
  `make slides-dev LESSON=…` command.

## Definition of done — Phase 1 v1

1. Eight lesson directories (`lessons/05-recursion/` …
   `lessons/12-mix-projects/`) exist and are committed.
2. `make solutions-test` is green across all eight (~28 new tests
   on top of Phase 0's 47).
3. `make lint` is clean.
4. `make slides-build` produces a `dist/index.html` with lessons
   00–12 lit up as "published"; Cloud Run deploy continues to work
   end-to-end.
5. `cd lessons/12-mix-projects/solutions && mix escript.build && \
   ./wc_ex test/fixtures/lorem.txt` prints a sensible
   `<lines>\t<words>\t<chars>\t<path>` line — the Phase 1 demo moment.
6. A learner who finished Phase 0 can work through lessons 05–12
   using only README + slides + hints + exercises, without outside
   help.

## Risks

- **Lesson 05 → 06 contrast.** If lesson 05's recursive drills don't
  have visible analogues in lesson 06's Enum drills, the "you don't
  have to write recursion every time" payoff disappears. The drill
  list above is deliberately paired
  (`Mapper.double_all/1` ↔ `Lists.doubled/1`). Author pass must keep
  the pairing visible — drop a sentence in lesson 06's README saying
  "compare to lesson 05's recursive version."
- **Lesson 09's `File.stream!` drill** could trip up beginners who've
  not yet seen path handling. Mitigation: fixture file at
  `test/fixtures/sample.log` relative to the test file; canonical
  pattern is `Path.join(__DIR__, "fixtures/sample.log")`. No prose
  section on "what's a path" — beginners saw that in lesson 00.
- **Lesson 10's protocol drill is short by design.** Risk: too thin
  for the concept to land. Mitigation: "Going further" includes a
  stretch problem implementing `String.Chars` for `Box` to reinforce.
- **Lesson 12's escript build adds a new toolchain step.** Risk:
  `mix escript.build` may surprise learners. Mitigation: the lesson
  narrative walks through the build output explicitly, including
  what the resulting binary actually is (a self-contained Erlang
  escript with a `#!` line).
- **Pacing.** Phase 1 is 8 lessons vs Phase 0's 5. Total Phase 1
  lessons + drills is ~1.5× Phase 0. Author/review fatigue is the
  main risk — split execution into batches if needed.

## Deferred decisions

- **Whether to introduce `defimpl Inspect` in lesson 10.** Currently
  `String.Chars` only. Punt to author-time call.
- **Whether `wc_ex` should also handle stdin** (Unix `wc` does).
  Punt — v1 capstone is file-only.
- **Whether to add a Phase 1 wrap-up slide deck.** Useful for a
  class teaching the course; for self-study, per-lesson slides plus
  the dist landing page are enough. Punt.

## Explicit non-goals (YAGNI)

- No property-based testing (StreamData) — that's lesson 34.
- No deep TCO discussion — one sentence in lesson 05, no more.
- No deep dive on protocol consolidation, fallback impls, or
  `@derive`. Lesson 10 stays at "you can implement
  `defprotocol`/`defimpl`."
- No `try`/`catch` (only `try`/`rescue`).
- No Mix umbrella projects. Lesson 12 builds one standalone Mix
  project, not an umbrella.
- No third-party deps in Phase 1 lessons except `:excoveralls`
  (already in the template). Phase 3 is when Hex deps land.
