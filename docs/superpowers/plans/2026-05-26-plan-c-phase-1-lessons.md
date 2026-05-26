# Plan C — Phase 1 Lessons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the eight Phase 1 lessons (05-recursion through 12-mix-projects) so a learner who has completed Phase 0 can write idiomatic Elixir, process data with Enum/Stream, work with structs and protocols, handle errors with `{:ok, _}` chains, and build a tiny CLI tool with Mix and `mix escript.build`.

**Architecture:** Eight lessons using the existing `shared/lesson-template/` scaffolded by `tools/new-lesson`, with hand-authored README/HINTS/slides + 3–5 micro-drill Mix exercises per lesson. Lessons 09 (streams) and 12 (mix-projects) add `test/fixtures/` directories with small committed files. Lesson 12 also adds `escript: [main_module: WcEx.CLI]` to its `mix.exs` so `mix escript.build` produces a runnable `wc_ex` binary — the Phase 1 capstone.

**Tech Stack:** Elixir 1.18 + Erlang/OTP 27, ExUnit (with `@tag :pending` skipped by default in exercises), reveal.js 5.1.0 for slides, the repo's existing Makefile + tools (`new-lesson`, `run-all-tests`, `check-solutions`, `lint-all`, `build_index`). No new Hex deps beyond what the lesson template already carries (`:excoveralls`).

**Pre-flight:** Run from repo root `/Users/ristkari/code/private/elixir-training/`. Current branch `main` is up-to-date and includes the merged Plan B (Phase 0 lessons). Work happens on a new branch `plan-c-phase-1` (created in Task 0). All commits are GPG-signed.

**Spec:** [`docs/superpowers/specs/2026-05-26-phase-1-design.md`](../specs/2026-05-26-phase-1-design.md).

---

## Inherited conventions (all from Phase 0, recap)

- Standard four-part lesson template: `README.md` (600–900 words, 700–1000 for lesson 12), `HINTS.md` (200–500 words), `slides/index.html` (boilerplate; one title substitution), `slides/slides.md` (≤ 4 concept blocks, ≤ 20 slides), `exercises/`, `solutions/`.
- Tone: conversational + everyday analogies, patient mentor.
- REPL transcript formatting: plain `iex>` (never numbered `iex(N)>`). Output line directly under input, no blank line.
- Beginner asides: `> 💡 **First time seeing this?** …` callouts where beneficial (≥ 2 per lesson).
- Slide style: heavy-explanatory pattern (motivation → basics → worked → mistake → recap), vertical `--` sub-slides for "code goes down."
- All exercise tests carry `@tag :pending`. Solution test files are byte-identical to exercise test files (copy via `cp`). `test_helper.exs` differs (exercises exclude pending; solutions don't) — that's from the scaffold template.
- `@moduledoc` required on every drill module (one line is fine).
- Lines ≤ 98 chars so `mix format` doesn't wrap them.
- One module per file; one `*_test.exs` per module.
- Closer slide on every lesson points to the next lesson with the `make slides-dev LESSON=…` command.

## Phase 1 conventions (new)

- **"Recall from lesson NN" pointer** at the top of `Key ideas` for any lesson that directly builds on a prior lesson. Lessons 06, 09, 10, 11, 12 all need this.
- **Test fixtures** for file-based drills. Two lessons have a `test/fixtures/` directory under both `exercises/` and `solutions/`:
  - `lessons/09-streams/{exercises,solutions}/test/fixtures/sample.log` — ~20 lines, 5 of them containing `ERROR`.
  - `lessons/12-mix-projects/{exercises,solutions}/test/fixtures/lorem.txt` — ~10 lines of Lorem Ipsum.
  Tests reference them via `Path.join(__DIR__, "fixtures/<name>")`.
- **Lesson 12 escript additions:** `mix.exs` gets an `escript: [main_module: WcEx.CLI]` line; the lesson directory gets a `.gitignore` containing just `wc_ex` so the built binary is ignored.

---

## File map (summary)

Per-lesson file inventory follows the Phase 0 pattern. Lesson 09 adds `test/fixtures/sample.log` to both exercises and solutions. Lesson 12 adds `test/fixtures/lorem.txt`, an `escript:` line in `mix.exs`, and a `.gitignore` for `wc_ex`.

Modules (by lesson):

| Lesson | Modules |
|---|---|
| 05 | `Sum`, `Counter`, `Mapper`, `Reverser` |
| 06 | `Lists` (with `doubled/1`, `evens/1`, `sum/1`), `Pipeline` |
| 07 | `Freq`, `Config`, `MapMerge` |
| 08 | `Letters` (with `vowel_count/1`, `title_case/1`), `Header`, `KV` |
| 09 | `Fibs`, `Naturals`, `LogStats` |
| 10 | `Point`, `Box` (`String.Chars` impl for `Point` lives in `point.ex`) |
| 11 | `SafeDiv`, `Parse`, `Pipeline` |
| 12 | `WcEx.Counts`, `WcEx`, `WcEx.CLI` |

---

## Task 0: Branch + spec reference

**Files:** none changed; just create the working branch.

- [ ] **Step 1: Confirm clean working tree on main**

```bash
git status
git log --oneline -1
```

Expected: `nothing to commit, working tree clean`, last commit is the most recent Phase 0 merge (`50d1b89` or newer).

- [ ] **Step 2: Create and switch to the working branch**

```bash
git checkout -b plan-c-phase-1
git status
```

Expected: `On branch plan-c-phase-1`, working tree clean.

- [ ] **Step 3: Verify the spec is present**

```bash
test -f docs/superpowers/specs/2026-05-26-phase-1-design.md && echo OK
```

Expected: prints `OK`.

No commit in this task.

---

## Task 1: Lesson 05 — `recursion`

**Files (after scaffold):**
- Scaffold creates: `lessons/05-recursion/` with template README/HINTS/slides + Mix project skeletons.
- Replace: `lessons/05-recursion/README.md`, `HINTS.md`, `slides/slides.md`.
- Create drill module+test pairs in both `exercises/` and `solutions/`:
  - `lib/sum.ex` + `test/sum_test.exs`
  - `lib/counter.ex` + `test/counter_test.exs`
  - `lib/mapper.ex` + `test/mapper_test.exs`
  - `lib/reverser.ex` + `test/reverser_test.exs`

### Step 1: Scaffold

```bash
tools/new-lesson 05-recursion
```

Expected: `Created lessons/05-recursion`.

### Step 2: Replace README

`lessons/05-recursion/README.md` — length target: 600–900 words.

Sections in order:

1. `# Lesson 05: Recursion` + hook: "By the end of this lesson, you'll write your own recursive list functions — the way Elixir replaces `for` loops. You'll see the base-case-plus-recursive-case shape that shows up in every Elixir codebase you'll ever read."
2. `## Key ideas`:
   - **Recursion is calling yourself with the rest of the work.** A recursive function does a small amount of work on one piece, then calls itself with everything except that piece. Eventually it runs out of work and stops (the base case).
   - **The base case is what happens when there's no work left.** For lists, that's the empty list `[]`. Define this clause first; it's how recursion terminates.
   - **Head/tail decomposition.** `[h | t] = [1, 2, 3]` gives `h = 1` and `t = [2, 3]`. Patterns in function heads use this to peel off one element at a time. (Recall from lesson 02.)
   - **The accumulator pattern.** Sometimes you need to "carry forward" a running result while you recurse. The trick: write a helper function with an extra argument (the accumulator), and a public wrapper that supplies the initial value.
   - **One sentence on tail-call optimisation.** Elixir is smart about recursion: if the recursive call is the very last thing in a function, the runtime doesn't grow the stack. So infinite-looking recursion (millions of items) doesn't blow up. You'll rarely have to think about it.
3. `## Try it in IEx` — REPL transcript showing two-clause definition of `Sum.of/1` interactively. Use `iex(1)>` plain — sorry I mean plain `iex>`.
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Forgetting the base case. Without it, the recursion never stops and you get a `FunctionClauseError`.
   - Putting the recursive case before the base case. Clause order matters; specific (literal) patterns must come before catch-all (variable) patterns.
   - Trying to update a "running total" by reassigning a variable. Elixir is immutable — use the accumulator pattern instead.
6. `## Going further`:
   - Try implementing `MyEnum.filter/2` with recursion. What's the base case? What does the recursive case do when the predicate is true vs false?
   - Look up "tail call optimisation Elixir" and read one short article. What does it mean for `Mapper.double_all/1` vs `Reverser.reverse/1`?
7. `## Links`:
   - [HexDocs — List](https://hexdocs.pm/elixir/List.html)
   - [Elixir School — Recursion](https://elixirschool.com/en/lessons/basics/recursion/)

Use ≥ 2 `> 💡` callouts. Natural spots: the first head/tail snippet (referencing lesson 02), the accumulator pattern (it's the conceptually trickier part).

### Step 3: Replace HINTS

`lessons/05-recursion/HINTS.md` — length ~350 words.

Four `## Drill N: <name>` sections (one per drill), three sub-hints each.

Drill 1 — `Sum.of/1`:
- Hint 1: "Two clauses. The first matches `[]` and returns `0`. The second matches `[h | t]` and recursively sums."
- Hint 2: "`def of([]), do: 0` / `def of([h | t]), do: h + of(t)`."
- Hint 3: full code.

Drill 2 — `Counter.length/1`:
- Hint 1: "Same shape as `Sum.of/1`. Base case returns `0`. Recursive case adds `1` plus a recursive call on the tail."
- Hint 2: "`def length([]), do: 0` / `def length([_ | t]), do: 1 + length(t)`."
- Hint 3: full code.

Drill 3 — `Mapper.double_all/1`:
- Hint 1: "Return a new list. Base case returns `[]`. Recursive case prepends `h * 2` to the recursive result on the tail."
- Hint 2: "`def double_all([]), do: []` / `def double_all([h | t]), do: [h * 2 | double_all(t)]`."
- Hint 3: full code.

Drill 4 — `Reverser.reverse/1`:
- Hint 1: "Two functions — a public `reverse/1` that calls a private `reverse/2` with an empty accumulator. The accumulator collects elements as you walk the list, so reversed order falls out naturally."
- Hint 2: "Public clause: `def reverse(list), do: do_reverse(list, [])`. Private base: `defp do_reverse([], acc), do: acc`. Private recursive: `defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])`."
- Hint 3: full code.

### Step 4: Replace slides

`lessons/05-recursion/slides/slides.md` — ≤ 20 slides, ≤ 4 concept blocks.

Concept blocks (each 4–5 vertical sub-slides per the heavy-explanatory pattern):

1. **Recursion is just calling yourself**:
   - motivation: "you've seen iex's `Enum.map`. Under the hood, that's recursion. Today you learn what's there."
   - basics: tiny `Countdown.go(3)` → prints 3, 2, 1, "blast off".
   - worked: `Sum.of([1, 2, 3])` walked step-by-step on the slide.
   - common mistake: forgetting the base case → `FunctionClauseError`.
   - recap.
2. **Head/tail decomposition**:
   - motivation: "lists in Elixir aren't arrays — they're linked. `[1, 2, 3]` is really `1 :: 2 :: 3 :: []`."
   - basics: `[h | t] = [1, 2, 3]` in iex.
   - worked: `Sum.of/1` using `[h | t]`.
   - common mistake: pattern on a non-list raises `FunctionClauseError`.
   - recap.
3. **The accumulator pattern**:
   - motivation: "sometimes you want to *collect* as you recurse. The result depends on order."
   - basics: a `do_reverse/2` helper with `acc`.
   - worked: trace `Reverser.reverse([1, 2, 3])` through `do_reverse(_, _)`.
   - common mistake: trying to use a regular variable as an accumulator. Elixir's immutability forces the extra argument.
   - recap.
4. **A glimpse of tail-call optimisation**:
   - motivation: "what happens to the stack when recursion runs millions of times?"
   - basics: "if the recursive call is the *last* thing in your function (no `+` after it), the Erlang VM reuses the stack frame. No overflow."
   - worked: `Sum.of/1` vs `Reverser.do_reverse/2` — which is tail-recursive? (`do_reverse/2` is; `Sum.of/1` isn't because of the `+`.)
   - common mistake: assuming all recursion is fine. Naïve recursion on a million-element list can blow the stack.
   - recap.

Title at top, closer at bottom: "Next: lesson 06 — `Enum` and the pipe. That recursion you just wrote? Most of the time you don't have to. Run: `make slides-dev LESSON=06-enum-and-the-pipe`."

### Step 5: Drill 1 — `Sum.of/1`

`lessons/05-recursion/exercises/lib/sum.ex`:

```elixir
defmodule Sum do
  @moduledoc "Recursive sum over a list of integers."

  @doc """
  Sum a list of integers using head/tail recursion.

      iex> Sum.of([1, 2, 3])
      6
      iex> Sum.of([])
      0
  """
  def of(_list), do: raise("TODO: two clauses — base case [] returns 0, recursive case sums h + of(t)")
end
```

`lessons/05-recursion/exercises/test/sum_test.exs`:

```elixir
defmodule SumTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Sum.of/1 sums a non-empty list" do
    assert Sum.of([1, 2, 3, 4]) == 10
  end

  @tag :pending
  test "Sum.of/1 returns 0 for the empty list" do
    assert Sum.of([]) == 0
  end

  @tag :pending
  test "Sum.of/1 handles negative integers" do
    assert Sum.of([-1, 1, -2, 2]) == 0
  end
end
```

`lessons/05-recursion/solutions/lib/sum.ex`:

```elixir
defmodule Sum do
  @moduledoc "Recursive sum over a list of integers."

  @doc """
  Sum a list of integers using head/tail recursion.

      iex> Sum.of([1, 2, 3])
      6
      iex> Sum.of([])
      0
  """
  def of([]), do: 0
  def of([h | t]), do: h + of(t)
end
```

`cp` test file to solutions.

### Step 6: Drill 2 — `Counter.length/1`

`lessons/05-recursion/exercises/lib/counter.ex`:

```elixir
defmodule Counter do
  @moduledoc "Recursive length over a list."

  @doc """
  Count the elements of a list without using `Kernel.length/1`.

      iex> Counter.length([:a, :b, :c])
      3
      iex> Counter.length([])
      0
  """
  def length(_list), do: raise("TODO: base case [] returns 0; recursive case adds 1 + length(t)")
end
```

`lessons/05-recursion/exercises/test/counter_test.exs`:

```elixir
defmodule CounterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Counter.length/1 counts a non-empty list" do
    assert Counter.length([:a, :b, :c, :d]) == 4
  end

  @tag :pending
  test "Counter.length/1 returns 0 for the empty list" do
    assert Counter.length([]) == 0
  end

  @tag :pending
  test "Counter.length/1 works on a singleton" do
    assert Counter.length([1]) == 1
  end
end
```

`lessons/05-recursion/solutions/lib/counter.ex`:

```elixir
defmodule Counter do
  @moduledoc "Recursive length over a list."

  @doc """
  Count the elements of a list without using `Kernel.length/1`.

      iex> Counter.length([:a, :b, :c])
      3
      iex> Counter.length([])
      0
  """
  def length([]), do: 0
  def length([_ | t]), do: 1 + length(t)
end
```

`cp` test file.

### Step 7: Drill 3 — `Mapper.double_all/1`

`lessons/05-recursion/exercises/lib/mapper.ex`:

```elixir
defmodule Mapper do
  @moduledoc "Recursive map over a list, doubling each element."

  @doc """
  Return a new list with each element doubled.

      iex> Mapper.double_all([1, 2, 3])
      [2, 4, 6]
      iex> Mapper.double_all([])
      []
  """
  def double_all(_list), do: raise("TODO: prepend h*2 to the recursive call on the tail")
end
```

`lessons/05-recursion/exercises/test/mapper_test.exs`:

```elixir
defmodule MapperTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Mapper.double_all/1 doubles every element" do
    assert Mapper.double_all([1, 2, 3]) == [2, 4, 6]
  end

  @tag :pending
  test "Mapper.double_all/1 returns [] for the empty list" do
    assert Mapper.double_all([]) == []
  end

  @tag :pending
  test "Mapper.double_all/1 handles a singleton" do
    assert Mapper.double_all([5]) == [10]
  end
end
```

`lessons/05-recursion/solutions/lib/mapper.ex`:

```elixir
defmodule Mapper do
  @moduledoc "Recursive map over a list, doubling each element."

  @doc """
  Return a new list with each element doubled.

      iex> Mapper.double_all([1, 2, 3])
      [2, 4, 6]
      iex> Mapper.double_all([])
      []
  """
  def double_all([]), do: []
  def double_all([h | t]), do: [h * 2 | double_all(t)]
end
```

`cp` test file.

### Step 8: Drill 4 — `Reverser.reverse/1`

`lessons/05-recursion/exercises/lib/reverser.ex`:

```elixir
defmodule Reverser do
  @moduledoc "Reverse a list using an accumulator helper."

  @doc """
  Reverse a list using the accumulator pattern.

      iex> Reverser.reverse([1, 2, 3])
      [3, 2, 1]
      iex> Reverser.reverse([])
      []
  """
  def reverse(_list), do: raise("TODO: delegate to a private do_reverse/2 with an empty accumulator")
end
```

`lessons/05-recursion/exercises/test/reverser_test.exs`:

```elixir
defmodule ReverserTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Reverser.reverse/1 reverses a non-empty list" do
    assert Reverser.reverse([1, 2, 3]) == [3, 2, 1]
  end

  @tag :pending
  test "Reverser.reverse/1 returns [] for the empty list" do
    assert Reverser.reverse([]) == []
  end

  @tag :pending
  test "Reverser.reverse/1 handles a singleton" do
    assert Reverser.reverse([:only]) == [:only]
  end
end
```

`lessons/05-recursion/solutions/lib/reverser.ex`:

```elixir
defmodule Reverser do
  @moduledoc "Reverse a list using an accumulator helper."

  @doc """
  Reverse a list using the accumulator pattern.

      iex> Reverser.reverse([1, 2, 3])
      [3, 2, 1]
      iex> Reverser.reverse([])
      []
  """
  def reverse(list), do: do_reverse(list, [])

  defp do_reverse([], acc), do: acc
  defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
end
```

`cp` test file.

### Step 9: Verify and commit

```bash
cd lessons/05-recursion/solutions && mix deps.get && mix test --include pending; cd -
```

Expected: `12 tests, 0 failures`.

```bash
tools/check-solutions
tools/lint-all
```

Both pass. check-solutions shows Phase 0 (47 tests) + lesson 05 (12 tests) green.

```bash
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist
grep -c 'lessons/05-recursion/slides/' dist/index.html
rm -rf dist
```

Expected: prints `1`.

```bash
git add lessons/05-recursion
git commit -m "Add lesson 05-recursion: base case + recursive case + accumulator

Four drills covering recursive list processing: Sum.of/1 (head/tail
sum), Counter.length/1 (no Kernel.length), Mapper.double_all/1
(recursive analogue of Enum.map), and Reverser.reverse/1 (the
accumulator pattern with a private do_reverse/2 helper).

README frames recursion as 'calling yourself with the rest of the
work', with the base case as 'what happens when there's no work
left'. Slides have four concept blocks (recursion intro, head/tail,
accumulator, TCO glimpse) under the 20-slide cap. The TCO concept
block is deliberately shallow — full TCO treatment is a stretch
goal.

Solutions green: 12 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Lesson 06 — `enum-and-the-pipe`

**Files (after scaffold):**
- Scaffold creates `lessons/06-enum-and-the-pipe/`.
- Replace README, HINTS, slides.
- Drill module+test pairs in both `exercises/` and `solutions/`:
  - `lib/lists.ex` + `test/lists_test.exs` (contains `doubled/1`, `evens/1`, `sum/1`)
  - `lib/pipeline.ex` + `test/pipeline_test.exs`

### Step 1: Scaffold

```bash
tools/new-lesson 06-enum-and-the-pipe
```

### Step 2: Replace README

`lessons/06-enum-and-the-pipe/README.md` — length 600–900 words.

Sections:

1. Hook: "By the end of this lesson, you'll use `Enum.map`, `Enum.filter`, and `Enum.reduce` plus the pipe operator `|>` — the way most Elixir code actually walks lists."
2. `## Key ideas`:
   - **Recall from lesson 05:** you wrote recursive functions that walk a list head-by-tail. `Enum` is that recursion written for you.
   - **`Enum.map/2`** — apply a function to every element; return a list the same length. Replaces lesson 05's `Mapper.double_all/1` shape.
   - **`Enum.filter/2`** — keep only the elements where a predicate returns truthy.
   - **`Enum.reduce/3`** — generalised fold. "Give me a starting jar and a recipe for adding the next item." Sum, count, build-up-a-map — all `reduce`.
   - **The pipe operator `|>`** — `x |> f()` is equivalent to `f(x)`. Chains let you read transformations left-to-right.
3. `## Try it in IEx` — transcript: `Enum.map([1,2,3], &(&1 * 2))`, `Enum.filter([1,2,3,4], &rem(&1, 2) == 0)`, `Enum.reduce([1,2,3], 0, &+/2)`, then the same composed: `[1,2,3,4] |> Enum.filter(&rem(&1, 2) == 0) |> Enum.map(&(&1 * &1)) |> Enum.sum()`.
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Confusing `&(&1 + 1)` (anon fn shorthand) with `&Foo.bar/1` (function capture). Both work; the first is inline, the second references an existing function.
   - Putting `|>` at the start of a line vs the end. Both are valid Elixir, but the community convention is `|>` at the start of the continuation line so commenting out a step is easy.
   - Using `Enum.map` when `Enum.reduce` is the right tool (or vice versa). Rule of thumb: `map` if the output is one-per-input; `reduce` if you're collapsing to a single value or building something different-shaped.
6. `## Going further`:
   - Find an `Enum.reduce` in your own code (or any open-source Elixir project) and trace what's happening on each iteration.
   - Try `Enum.flat_map/2` — when is it different from `Enum.map/2 |> Enum.concat/1`?
7. `## Links`:
   - [HexDocs — Enum](https://hexdocs.pm/elixir/Enum.html)
   - [Elixir School — Enum](https://elixirschool.com/en/lessons/basics/enum/)
   - [Pipe operator](https://hexdocs.pm/elixir/Kernel.html#%7C%3E/2)

Use ≥ 2 `> 💡` callouts.

### Step 3: Replace HINTS

`lessons/06-enum-and-the-pipe/HINTS.md` — ~350 words. Four sections (three drills are inside `Lists`; the fourth is `Pipeline`).

`## Drills 1-3: Lists.doubled/1, Lists.evens/1, Lists.sum/1`:
- Hint 1: "Each is a one-liner with a single Enum function."
- Hint 2: "`def doubled(list), do: Enum.map(list, &(&1 * 2))`. `def evens(list), do: Enum.filter(list, &(rem(&1, 2) == 0))`. `def sum(list), do: Enum.reduce(list, 0, &+/2)`."
- Hint 3: full module code.

`## Drill 4: Pipeline.pipeline/1`:
- Hint 1: "Three steps — filter to evens, square each one, sum. All in a `|>` chain starting from the input list."
- Hint 2: "`list |> Enum.filter(...) |> Enum.map(...) |> Enum.sum()`."
- Hint 3: full one-liner.

### Step 4: Replace slides

`lessons/06-enum-and-the-pipe/slides/slides.md` — ≤ 20 slides, ≤ 4 concept blocks:

1. **`Enum.map`** — motivation ("you don't have to write `[h | double_all(t)]` ever again"), basics (`Enum.map([1,2,3], &(&1 * 2))`), worked (lesson 05's `double_all` rewritten with `Enum.map`), common mistake (passing the function the wrong arity), recap.
2. **`Enum.filter`** — motivation, basics, worked (lesson 06 drill 2), common mistake (returning a non-boolean from the predicate — truthy/falsy still works but is confusing), recap.
3. **`Enum.reduce`** — motivation ("the universal fold"), basics with explicit initial accumulator, worked (sum + collecting into a map), common mistake (forgetting the initial accumulator → `Enum.reduce/2` exists but errors on empty list), recap.
4. **The pipe `|>`** — motivation ("read left to right, not inside-out"), basics, worked (the lesson 06 drill 4 pipeline), common mistake (piping into a function that doesn't accept its arg first → "the pipe always feeds the first arg"), recap.

Closer: "Next: lesson 07 — collections. We've been on lists. There's more — tuples, maps, keyword lists. Run: `make slides-dev LESSON=07-collections`."

### Step 5: Drills 1-3 — `Lists.doubled/1`, `Lists.evens/1`, `Lists.sum/1`

`lessons/06-enum-and-the-pipe/exercises/lib/lists.ex`:

```elixir
defmodule Lists do
  @moduledoc "Enum drills for lesson 06."

  @doc """
  Return a new list with each element doubled.

      iex> Lists.doubled([1, 2, 3])
      [2, 4, 6]
  """
  def doubled(_list), do: raise("TODO: use Enum.map with &(&1 * 2)")

  @doc """
  Return only the even integers from the list.

      iex> Lists.evens([1, 2, 3, 4])
      [2, 4]
  """
  def evens(_list), do: raise("TODO: use Enum.filter with a rem/2 predicate")

  @doc """
  Sum the list of integers.

      iex> Lists.sum([1, 2, 3])
      6
  """
  def sum(_list), do: raise("TODO: use Enum.reduce with 0 and &+/2")
end
```

`lessons/06-enum-and-the-pipe/exercises/test/lists_test.exs`:

```elixir
defmodule ListsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Lists.doubled/1 doubles each element" do
    assert Lists.doubled([1, 2, 3]) == [2, 4, 6]
  end

  @tag :pending
  test "Lists.doubled/1 returns [] for an empty list" do
    assert Lists.doubled([]) == []
  end

  @tag :pending
  test "Lists.evens/1 returns only even integers" do
    assert Lists.evens([1, 2, 3, 4, 5, 6]) == [2, 4, 6]
  end

  @tag :pending
  test "Lists.evens/1 returns [] when none are even" do
    assert Lists.evens([1, 3, 5]) == []
  end

  @tag :pending
  test "Lists.sum/1 sums a non-empty list" do
    assert Lists.sum([1, 2, 3, 4]) == 10
  end

  @tag :pending
  test "Lists.sum/1 returns 0 for an empty list" do
    assert Lists.sum([]) == 0
  end
end
```

`lessons/06-enum-and-the-pipe/solutions/lib/lists.ex`:

```elixir
defmodule Lists do
  @moduledoc "Enum drills for lesson 06."

  @doc """
  Return a new list with each element doubled.

      iex> Lists.doubled([1, 2, 3])
      [2, 4, 6]
  """
  def doubled(list), do: Enum.map(list, &(&1 * 2))

  @doc """
  Return only the even integers from the list.

      iex> Lists.evens([1, 2, 3, 4])
      [2, 4]
  """
  def evens(list), do: Enum.filter(list, &(rem(&1, 2) == 0))

  @doc """
  Sum the list of integers.

      iex> Lists.sum([1, 2, 3])
      6
  """
  def sum(list), do: Enum.reduce(list, 0, &+/2)
end
```

`cp` test file.

### Step 6: Drill 4 — `Pipeline.pipeline/1`

`lessons/06-enum-and-the-pipe/exercises/lib/pipeline.ex`:

```elixir
defmodule Pipeline do
  @moduledoc "A single |> chain composing filter, map, and reduce."

  @doc """
  Return the sum of squares of the even integers in the list, in one pipeline.

      iex> Pipeline.pipeline([1, 2, 3, 4])
      20
  """
  def pipeline(_list), do: raise("TODO: list |> Enum.filter(evens) |> Enum.map(square) |> Enum.sum()")
end
```

`lessons/06-enum-and-the-pipe/exercises/test/pipeline_test.exs`:

```elixir
defmodule PipelineTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pipeline.pipeline/1 sums squares of evens" do
    # evens: 2, 4 → squares: 4, 16 → sum: 20
    assert Pipeline.pipeline([1, 2, 3, 4]) == 20
  end

  @tag :pending
  test "Pipeline.pipeline/1 returns 0 when nothing is even" do
    assert Pipeline.pipeline([1, 3, 5]) == 0
  end

  @tag :pending
  test "Pipeline.pipeline/1 returns 0 for an empty list" do
    assert Pipeline.pipeline([]) == 0
  end
end
```

`lessons/06-enum-and-the-pipe/solutions/lib/pipeline.ex`:

```elixir
defmodule Pipeline do
  @moduledoc "A single |> chain composing filter, map, and reduce."

  @doc """
  Return the sum of squares of the even integers in the list, in one pipeline.

      iex> Pipeline.pipeline([1, 2, 3, 4])
      20
  """
  def pipeline(list) do
    list
    |> Enum.filter(&(rem(&1, 2) == 0))
    |> Enum.map(&(&1 * &1))
    |> Enum.sum()
  end
end
```

`cp` test file.

### Step 7: Verify and commit

```bash
cd lessons/06-enum-and-the-pipe/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: lesson 06 contributes `9 tests, 0 failures`. All previous lessons still green.

```bash
git add lessons/06-enum-and-the-pipe
git commit -m "Add lesson 06-enum-and-the-pipe: Enum.map/filter/reduce + |>

Four drills bundled into two modules: Lists (with doubled/1, evens/1,
sum/1 — one per Enum operation) and Pipeline.pipeline/1 (a single
filter→map→sum chain). README opens with 'Recall from lesson 05'
and frames Enum as 'the recursion you don't have to write.' Slides
have four concept blocks (map, filter, reduce, pipe) under the
20-slide cap.

Solutions green: 9 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Lesson 07 — `collections`

**Files:**
- Scaffold + replace prose.
- Drills: `lib/freq.ex`, `lib/config.ex`, `lib/map_merge.ex` with matching tests.

### Step 1: Scaffold

```bash
tools/new-lesson 07-collections
```

### Step 2: Replace README

Length 600–900 words. Sections:

1. Hook: "By the end of this lesson, you'll know when to reach for lists, tuples, maps, and keyword lists — Elixir's four core collection types."
2. `## Key ideas`:
   - **Lists `[1, 2, 3]`** — sequential, head/tail access. Best for "process every element."
   - **Tuples `{:ok, 42}`** — fixed-size, positional. Best for return values and small records.
   - **Maps `%{name: "Aki"}` / `%{"k" => "v"}`** — key-value. Atom-keyed shorthand vs general `%{}` syntax. `Map.get/2`, `Map.put/3`, `Map.update/4`. Beginners' default for "I want to look something up by name."
   - **Keyword lists `[name: "Aki", age: 30]`** — syntactic sugar over `[{:name, "Aki"}, {:age, 30}]`. Used for function options (`String.split("a-b", "-", trim: true)`). `Keyword.get/3`.
3. `## Try it in IEx` — transcript covering each collection: create one, read from one, modify one.
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Reaching for a list when you want O(1) lookup. Use a map.
   - Using `[]` as the empty map. They look similar in printed output (`[]` vs `%{}`) but they're different types.
   - Confusing `%{name: "x"}` with `%{"name" => "x"}`. The first is atom-keyed; the second is string-keyed. They don't match each other in pattern matching.
6. `## Going further`:
   - When would `MapSet` (mentioned but not introduced in this lesson) be a better choice than `Map`?
   - Look up `Map.merge/3` (the three-arg version with a conflict resolver) and explain when it's useful.
7. `## Links`:
   - [HexDocs — Map](https://hexdocs.pm/elixir/Map.html)
   - [HexDocs — Keyword](https://hexdocs.pm/elixir/Keyword.html)

### Step 3: Replace HINTS

`lessons/07-collections/HINTS.md` — ~300 words. Three sections.

`## Drill 1: Freq.count/1`:
- Hint 1: "Use `Enum.reduce` with an empty map as the accumulator. For each word, increment its count (or set to 1 if absent)."
- Hint 2: "`Enum.reduce(words, %{}, fn word, acc -> Map.update(acc, word, 1, &(&1 + 1)) end)`."
- Hint 3: full code.

`## Drill 2: Config.get/3`:
- Hint 1: "`Keyword.get/3` is exactly what you need."
- Hint 2: "`def get(opts, key, default), do: Keyword.get(opts, key, default)`."
- Hint 3: full code.

`## Drill 3: MapMerge.deep/2`:
- Hint 1: "Walk the keys of the second map. For each key, if both maps have a value AND both values are maps themselves, recurse; otherwise the second map's value wins."
- Hint 2: "`Map.merge(map1, map2, fn _k, v1, v2 -> if is_map(v1) and is_map(v2), do: deep(v1, v2), else: v2 end)`."
- Hint 3: full code.

### Step 4: Replace slides

≤ 20 slides, ≤ 4 concept blocks: Lists & tuples (combined), Maps, Keyword lists, "when to use which."

Closer: "Next: lesson 08 — strings and binaries. Run: `make slides-dev LESSON=08-strings-and-binaries`."

### Step 5: Drill 1 — `Freq.count/1`

`lessons/07-collections/exercises/lib/freq.ex`:

```elixir
defmodule Freq do
  @moduledoc "Build a frequency map from a list."

  @doc """
  Count how many times each element appears in the list.

      iex> Freq.count(["a", "b", "a", "c", "b", "a"])
      %{"a" => 3, "b" => 2, "c" => 1}
  """
  def count(_list), do: raise("TODO: Enum.reduce into a map; use Map.update with default 1")
end
```

`lessons/07-collections/exercises/test/freq_test.exs`:

```elixir
defmodule FreqTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Freq.count/1 counts occurrences" do
    assert Freq.count(["a", "b", "a"]) == %{"a" => 2, "b" => 1}
  end

  @tag :pending
  test "Freq.count/1 returns an empty map for an empty list" do
    assert Freq.count([]) == %{}
  end

  @tag :pending
  test "Freq.count/1 works with atoms" do
    assert Freq.count([:x, :y, :x, :x]) == %{x: 3, y: 1}
  end
end
```

`lessons/07-collections/solutions/lib/freq.ex`:

```elixir
defmodule Freq do
  @moduledoc "Build a frequency map from a list."

  @doc """
  Count how many times each element appears in the list.

      iex> Freq.count(["a", "b", "a", "c", "b", "a"])
      %{"a" => 3, "b" => 2, "c" => 1}
  """
  def count(list) do
    Enum.reduce(list, %{}, fn item, acc -> Map.update(acc, item, 1, &(&1 + 1)) end)
  end
end
```

`cp` test file.

### Step 6: Drill 2 — `Config.get/3`

`lessons/07-collections/exercises/lib/config.ex`:

```elixir
defmodule Config do
  @moduledoc "Keyword-list lookup with a default."

  @doc """
  Look up `key` in a keyword-list `opts`; return `default` if absent.

      iex> Config.get([host: "elixir.dev"], :host, "localhost")
      "elixir.dev"
      iex> Config.get([], :host, "localhost")
      "localhost"
  """
  def get(_opts, _key, _default), do: raise("TODO: delegate to Keyword.get/3")
end
```

`lessons/07-collections/exercises/test/config_test.exs`:

```elixir
defmodule ConfigTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Config.get/3 returns the existing value" do
    assert Config.get([host: "x"], :host, "localhost") == "x"
  end

  @tag :pending
  test "Config.get/3 returns the default for a missing key" do
    assert Config.get([], :host, "localhost") == "localhost"
  end

  @tag :pending
  test "Config.get/3 returns the default for a different missing key" do
    assert Config.get([port: 4000], :host, "localhost") == "localhost"
  end
end
```

`lessons/07-collections/solutions/lib/config.ex`:

```elixir
defmodule Config do
  @moduledoc "Keyword-list lookup with a default."

  @doc """
  Look up `key` in a keyword-list `opts`; return `default` if absent.

      iex> Config.get([host: "elixir.dev"], :host, "localhost")
      "elixir.dev"
      iex> Config.get([], :host, "localhost")
      "localhost"
  """
  def get(opts, key, default), do: Keyword.get(opts, key, default)
end
```

`cp` test file.

### Step 7: Drill 3 — `MapMerge.deep/2`

`lessons/07-collections/exercises/lib/map_merge.ex`:

```elixir
defmodule MapMerge do
  @moduledoc "Recursive deep merge of two maps."

  @doc """
  Merge two maps recursively. When both maps have a value for the same
  key AND both values are themselves maps, recurse. Otherwise, the
  second map's value wins.

      iex> MapMerge.deep(%{a: 1, b: %{c: 2}}, %{b: %{d: 3}, e: 4})
      %{a: 1, b: %{c: 2, d: 3}, e: 4}
  """
  def deep(_a, _b), do: raise("TODO: Map.merge with a 3-arg merger that recurses on map-map conflicts")
end
```

`lessons/07-collections/exercises/test/map_merge_test.exs`:

```elixir
defmodule MapMergeTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "MapMerge.deep/2 merges top-level keys" do
    assert MapMerge.deep(%{a: 1}, %{b: 2}) == %{a: 1, b: 2}
  end

  @tag :pending
  test "MapMerge.deep/2 recurses on nested maps" do
    assert MapMerge.deep(%{a: %{b: 1}}, %{a: %{c: 2}}) == %{a: %{b: 1, c: 2}}
  end

  @tag :pending
  test "MapMerge.deep/2 lets the second map override a non-map value" do
    assert MapMerge.deep(%{a: 1}, %{a: 2}) == %{a: 2}
  end

  @tag :pending
  test "MapMerge.deep/2 handles mixed nested and flat" do
    assert MapMerge.deep(%{a: 1, b: %{c: 2}}, %{b: %{d: 3}, e: 4}) ==
             %{a: 1, b: %{c: 2, d: 3}, e: 4}
  end
end
```

`lessons/07-collections/solutions/lib/map_merge.ex`:

```elixir
defmodule MapMerge do
  @moduledoc "Recursive deep merge of two maps."

  @doc """
  Merge two maps recursively. When both maps have a value for the same
  key AND both values are themselves maps, recurse. Otherwise, the
  second map's value wins.

      iex> MapMerge.deep(%{a: 1, b: %{c: 2}}, %{b: %{d: 3}, e: 4})
      %{a: 1, b: %{c: 2, d: 3}, e: 4}
  """
  def deep(a, b) do
    Map.merge(a, b, fn _k, v1, v2 ->
      if is_map(v1) and is_map(v2), do: deep(v1, v2), else: v2
    end)
  end
end
```

`cp` test file.

### Step 8: Verify and commit

```bash
cd lessons/07-collections/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: lesson 07 contributes `10 tests, 0 failures`.

```bash
git add lessons/07-collections
git commit -m "Add lesson 07-collections: lists, tuples, maps, keyword lists

Three drills: Freq.count/1 (Enum.reduce into a map with Map.update),
Config.get/3 (keyword-list lookup with default), MapMerge.deep/2
(recursive map merge — callback to lesson 05). README walks through
each collection's strengths and when to reach for which. Slides
have four concept blocks under the 20-slide cap.

Solutions green: 10 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Lesson 08 — `strings-and-binaries`

**Files:**
- Scaffold + replace prose.
- Drills: `lib/letters.ex` (with `vowel_count/1`, `title_case/1`), `lib/header.ex`, `lib/kv.ex` + matching tests.

### Step 1: Scaffold

```bash
tools/new-lesson 08-strings-and-binaries
```

### Step 2: Replace README

Length 600–900 words. Sections:

1. Hook: "By the end of this lesson, you'll be comfortable manipulating strings with the `String` module and you'll have used Elixir's binary pattern matching to peel structure out of raw bytes."
2. `## Key ideas`:
   - **Strings are binaries.** `"hello"` is just five bytes (UTF-8 encoded). The `String` module knows about characters; the `Kernel`/`Bitwise` modules know about bytes.
   - **`String.upcase`, `.downcase`, `.split`, `.contains?`, `.replace`, `.trim`** — the everyday ops.
   - **Binary syntax `<<>>`.** `<<104, 101, 108, 108, 111>>` is `"hello"` (same bytes). You can pattern-match into a binary: `<<first_byte, rest::binary>> = "hello"` gives `first_byte = 104` and `rest = "ello"`.
   - **Sigils** — `~w(a b c)` is `["a", "b", "c"]`. `~r/foo/` is a regex. There are others (`~D`, `~T`, `~U` for dates/times) — mentioned but not central.
3. `## Try it in IEx` — transcript showing String calls + a binary destructure.
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Reaching for `String.length/1` when you want byte count. `byte_size/1` gives bytes; `String.length/1` gives characters (which are sometimes multi-byte).
   - Treating `<<>>` patterns as if size were optional. Specify sizes when matching multi-byte fields.
   - Forgetting that string concatenation is `<>` (not `+`). (Already covered in lesson 01, repeated here.)
6. `## Going further`:
   - Look up `String.graphemes/1` vs `String.codepoints/1`. When does the difference matter?
   - Write a tiny binary parser for a fixed-format record (4-byte version, 2-byte length, payload).
7. `## Links`:
   - [HexDocs — String](https://hexdocs.pm/elixir/String.html)
   - [Binary pattern matching in Elixir](https://hexdocs.pm/elixir/patterns-and-guards.html#binaries)

### Step 3: Replace HINTS

Four sections (three drills, but `Letters` bundles two ops).

`## Drills 1+2: Letters.vowel_count/1 and Letters.title_case/1`:
- Hints for `vowel_count`: 1) "use `String.graphemes/1` to split into characters, then `Enum.count` with a vowel predicate." 2) "`s |> String.downcase() |> String.graphemes() |> Enum.count(&(&1 in [\"a\", \"e\", \"i\", \"o\", \"u\"]))`." 3) full code.
- Hints for `title_case`: 1) "split on spaces, capitalise each word, join." 2) "`s |> String.split(\" \") |> Enum.map(&String.capitalize/1) |> Enum.join(\" \")`." 3) full code.

`## Drill 3: Header.parse/1`:
- Hint 1: "Pattern-match the first two bytes into named values; bind the rest as a binary."
- Hint 2: "`<<version, length, rest::binary>> = bin`. Return `{version, length, rest}`."
- Hint 3: full code.

`## Drill 4: KV.parse_line/1`:
- Hint 1: "`String.split/2` with `\"=\"` as the separator. Pattern-match the result list."
- Hint 2: "`[key, value] = String.split(line, \"=\", parts: 2); {key, value}`."
- Hint 3: full code.

### Step 4: Replace slides

4 concept blocks: String ops, Binary syntax & pattern matching, Sigils, Putting it together (the lesson 08 drill 4 KV parser as the worked example). ≤ 20 slides.

Closer: "Next: lesson 09 — streams. Run: `make slides-dev LESSON=09-streams`."

### Step 5: Drills 1+2 — `Letters.vowel_count/1` and `Letters.title_case/1`

`lessons/08-strings-and-binaries/exercises/lib/letters.ex`:

```elixir
defmodule Letters do
  @moduledoc "String-processing drills for lesson 08."

  @doc """
  Count the vowels in a string (case-insensitive).

      iex> Letters.vowel_count("Hello, Aki!")
      4
  """
  def vowel_count(_s), do: raise("TODO: lowercase, graphemes, Enum.count with vowel membership check")

  @doc """
  Title-case a sentence — capitalize each word.

      iex> Letters.title_case("hello, lovely day")
      "Hello, Lovely Day"
  """
  def title_case(_s), do: raise("TODO: String.split on space, Enum.map(&String.capitalize/1), Enum.join")
end
```

`lessons/08-strings-and-binaries/exercises/test/letters_test.exs`:

```elixir
defmodule LettersTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Letters.vowel_count/1 counts vowels in a short string" do
    assert Letters.vowel_count("Aki") == 2
  end

  @tag :pending
  test "Letters.vowel_count/1 is case-insensitive" do
    assert Letters.vowel_count("HELLO") == 2
  end

  @tag :pending
  test "Letters.vowel_count/1 returns 0 for a vowel-less string" do
    assert Letters.vowel_count("bcdfg") == 0
  end

  @tag :pending
  test "Letters.title_case/1 capitalizes each word" do
    assert Letters.title_case("hello world") == "Hello World"
  end

  @tag :pending
  test "Letters.title_case/1 returns single word capitalized" do
    assert Letters.title_case("elixir") == "Elixir"
  end
end
```

`lessons/08-strings-and-binaries/solutions/lib/letters.ex`:

```elixir
defmodule Letters do
  @moduledoc "String-processing drills for lesson 08."

  @doc """
  Count the vowels in a string (case-insensitive).

      iex> Letters.vowel_count("Hello, Aki!")
      4
  """
  def vowel_count(s) do
    s
    |> String.downcase()
    |> String.graphemes()
    |> Enum.count(&(&1 in ["a", "e", "i", "o", "u"]))
  end

  @doc """
  Title-case a sentence — capitalize each word.

      iex> Letters.title_case("hello, lovely day")
      "Hello, Lovely Day"
  """
  def title_case(s) do
    s
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
```

`cp` test file.

### Step 6: Drill 3 — `Header.parse/1`

`lessons/08-strings-and-binaries/exercises/lib/header.ex`:

```elixir
defmodule Header do
  @moduledoc "Binary pattern matching for a tiny header format."

  @doc """
  Parse a binary `<<version, length, rest::binary>>` into a tuple
  `{version, length, rest}`.

      iex> Header.parse(<<1, 4, "data">>)
      {1, 4, "data"}
  """
  def parse(_bin), do: raise("TODO: binary pattern match <<version, length, rest::binary>>")
end
```

`lessons/08-strings-and-binaries/exercises/test/header_test.exs`:

```elixir
defmodule HeaderTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Header.parse/1 extracts version, length, and payload" do
    assert Header.parse(<<1, 4, "data">>) == {1, 4, "data"}
  end

  @tag :pending
  test "Header.parse/1 works with an empty payload" do
    assert Header.parse(<<2, 0>>) == {2, 0, ""}
  end

  @tag :pending
  test "Header.parse/1 handles a longer payload" do
    assert Header.parse(<<7, 11, "hello world">>) == {7, 11, "hello world"}
  end
end
```

`lessons/08-strings-and-binaries/solutions/lib/header.ex`:

```elixir
defmodule Header do
  @moduledoc "Binary pattern matching for a tiny header format."

  @doc """
  Parse a binary `<<version, length, rest::binary>>` into a tuple
  `{version, length, rest}`.

      iex> Header.parse(<<1, 4, "data">>)
      {1, 4, "data"}
  """
  def parse(<<version, length, rest::binary>>), do: {version, length, rest}
end
```

`cp` test file.

### Step 7: Drill 4 — `KV.parse_line/1`

`lessons/08-strings-and-binaries/exercises/lib/kv.ex`:

```elixir
defmodule KV do
  @moduledoc "Parse a 'key=value' line into a tuple."

  @doc """
  Split `"key=value"` on the first `=` and return `{key, value}`.

      iex> KV.parse_line("name=Aki")
      {"name", "Aki"}
      iex> KV.parse_line("greeting=hello=world")
      {"greeting", "hello=world"}
  """
  def parse_line(_line), do: raise("TODO: String.split with parts: 2 and pattern-match [key, value]")
end
```

`lessons/08-strings-and-binaries/exercises/test/kv_test.exs`:

```elixir
defmodule KVTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "KV.parse_line/1 splits at the first =" do
    assert KV.parse_line("name=Aki") == {"name", "Aki"}
  end

  @tag :pending
  test "KV.parse_line/1 keeps later = in the value" do
    assert KV.parse_line("greeting=hello=world") == {"greeting", "hello=world"}
  end

  @tag :pending
  test "KV.parse_line/1 handles empty value" do
    assert KV.parse_line("empty=") == {"empty", ""}
  end
end
```

`lessons/08-strings-and-binaries/solutions/lib/kv.ex`:

```elixir
defmodule KV do
  @moduledoc "Parse a 'key=value' line into a tuple."

  @doc """
  Split `"key=value"` on the first `=` and return `{key, value}`.

      iex> KV.parse_line("name=Aki")
      {"name", "Aki"}
      iex> KV.parse_line("greeting=hello=world")
      {"greeting", "hello=world"}
  """
  def parse_line(line) do
    [key, value] = String.split(line, "=", parts: 2)
    {key, value}
  end
end
```

`cp` test file.

### Step 8: Verify and commit

```bash
cd lessons/08-strings-and-binaries/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `11 tests, 0 failures`.

```bash
git add lessons/08-strings-and-binaries
git commit -m "Add lesson 08-strings-and-binaries: String ops + binary patterns

Four drills bundled into three modules: Letters (vowel_count/1 +
title_case/1), Header.parse/1 (binary pattern match
<<version, length, rest::binary>>), and KV.parse_line/1 (String.split
with parts: 2). Sigils mentioned in slides but no sigil drills.
Slides have four concept blocks: String ops, binary syntax, sigils,
the KV parser as the worked-example tie-back.

Solutions green: 11 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Lesson 09 — `streams`

**Files:**
- Scaffold + replace prose.
- Drills: `lib/fibs.ex`, `lib/naturals.ex`, `lib/log_stats.ex` + matching tests.
- Fixture: `test/fixtures/sample.log` in both exercises and solutions (byte-identical).

### Step 1: Scaffold

```bash
tools/new-lesson 09-streams
```

### Step 2: Replace README

Length 600–900 words. Sections:

1. Hook: "By the end of this lesson, you'll use `Stream` to define infinite sequences and to process files lazily — bigger than memory if needed."
2. `## Key ideas`:
   - **Recall from lesson 06:** `Enum.map` returns a new list immediately. Sometimes you don't want that.
   - **Streams are recipes, not results.** `Stream.iterate(0, &(&1 + 1))` describes "every natural number." Nothing is computed until you ask for elements (with `Enum.take/2`, `Enum.to_list/1`, etc.).
   - **`Stream.iterate`, `Stream.repeatedly`, `Stream.cycle`** — three ways to make an infinite stream.
   - **`Stream.map`, `Stream.filter`** — same as `Enum` versions but lazy. Chain them; nothing happens until you cap the stream with an `Enum.*` call.
   - **`File.stream!`** — opens a file as a line-by-line stream. Lets you process arbitrarily big files in constant memory.
3. `## Try it in IEx` — transcript: `Stream.iterate(1, &(&1 * 2)) |> Enum.take(5)` (first 5 powers of 2).
4. `## How to work this lesson` — standard. Mention that drill 3 needs a fixture file.
5. `## Common mistakes`:
   - Calling `Enum.map` on a stream — it works but you've thrown away laziness.
   - Forgetting to "cap" the stream. `Stream.iterate(0, &(&1 + 1))` by itself does nothing useful — pipe it into `Enum.take/2` or `Enum.reduce_while/3`.
   - Using `File.read!` when the file is huge. `File.read!` slurps the whole file into memory; `File.stream!` reads line by line.
6. `## Going further`:
   - Implement a streaming `Enum.uniq` equivalent — keep a `MapSet` of seen items.
   - What does `Stream.transform/3` do? Find one use case it makes easier.
7. `## Links`:
   - [HexDocs — Stream](https://hexdocs.pm/elixir/Stream.html)
   - [HexDocs — File](https://hexdocs.pm/elixir/File.html)

### Step 3: Replace HINTS

Three sections.

`## Drill 1: Fibs.take/1`:
- Hint 1: "`Stream.iterate` carries state forward — iterate over `{prev, curr}` pairs."
- Hint 2: "`Stream.iterate({0, 1}, fn {a, b} -> {b, a + b} end) |> Enum.take(n) |> Enum.map(&elem(&1, 0))`."
- Hint 3: full code.

`## Drill 2: Naturals.evens_below/1`:
- Hint 1: "Stream the naturals, filter to even, take while less than the bound."
- Hint 2: "`Stream.iterate(0, &(&1 + 1)) |> Stream.filter(&(rem(&1, 2) == 0)) |> Stream.take_while(&(&1 < bound)) |> Enum.to_list()`."
- Hint 3: full code.

`## Drill 3: LogStats.count_errors/1`:
- Hint 1: "`File.stream!` opens the file as a line stream. Filter to lines containing 'ERROR'. Count with `Enum.count`."
- Hint 2: "`path |> File.stream!() |> Stream.filter(&String.contains?(&1, \"ERROR\")) |> Enum.count()`."
- Hint 3: full code.

### Step 4: Replace slides

4 concept blocks: Streams as recipes (motivation, basics, `Stream.iterate`), Lazy `map`/`filter`, Capping with `Enum.take`/`Enum.to_list`, File streaming as the worked example. ≤ 20 slides.

Closer: "Next: lesson 10 — structs and protocols. Run: `make slides-dev LESSON=10-structs-and-protocols`."

### Step 5: Create the fixture file

`lessons/09-streams/exercises/test/fixtures/sample.log` (and identical copy under solutions):

```
2026-05-26T10:00:01 INFO  starting up
2026-05-26T10:00:02 DEBUG loaded config
2026-05-26T10:00:03 INFO  listening on :4000
2026-05-26T10:00:05 ERROR could not connect to upstream
2026-05-26T10:00:07 WARN  retry 1/3
2026-05-26T10:00:08 ERROR connection refused
2026-05-26T10:00:10 WARN  retry 2/3
2026-05-26T10:00:11 ERROR timeout reading socket
2026-05-26T10:00:13 INFO  worker ack
2026-05-26T10:00:14 DEBUG flushing buffer
2026-05-26T10:00:15 INFO  processed 42 items
2026-05-26T10:00:17 ERROR upstream returned 500
2026-05-26T10:00:18 WARN  retry 3/3
2026-05-26T10:00:19 ERROR giving up
2026-05-26T10:00:20 INFO  scheduling retry in 60s
```

5 lines contain `ERROR`, 15 lines total.

```bash
mkdir -p lessons/09-streams/exercises/test/fixtures
mkdir -p lessons/09-streams/solutions/test/fixtures
# Author the file once at exercises/test/fixtures/sample.log, then:
cp lessons/09-streams/exercises/test/fixtures/sample.log \
   lessons/09-streams/solutions/test/fixtures/sample.log
```

### Step 6: Drill 1 — `Fibs.take/1`

`lessons/09-streams/exercises/lib/fibs.ex`:

```elixir
defmodule Fibs do
  @moduledoc "Fibonacci stream — first N numbers."

  @doc """
  Return the first n Fibonacci numbers starting from 0, 1, 1, 2, 3, ...

      iex> Fibs.take(6)
      [0, 1, 1, 2, 3, 5]
  """
  def take(_n), do: raise("TODO: Stream.iterate over {prev, curr} pairs, take n, map &elem(&1, 0)")
end
```

`lessons/09-streams/exercises/test/fibs_test.exs`:

```elixir
defmodule FibsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Fibs.take/1 returns the first six numbers" do
    assert Fibs.take(6) == [0, 1, 1, 2, 3, 5]
  end

  @tag :pending
  test "Fibs.take/1 returns [] for n=0" do
    assert Fibs.take(0) == []
  end

  @tag :pending
  test "Fibs.take/1 returns [0] for n=1" do
    assert Fibs.take(1) == [0]
  end
end
```

`lessons/09-streams/solutions/lib/fibs.ex`:

```elixir
defmodule Fibs do
  @moduledoc "Fibonacci stream — first N numbers."

  @doc """
  Return the first n Fibonacci numbers starting from 0, 1, 1, 2, 3, ...

      iex> Fibs.take(6)
      [0, 1, 1, 2, 3, 5]
  """
  def take(n) do
    {0, 1}
    |> Stream.iterate(fn {a, b} -> {b, a + b} end)
    |> Enum.take(n)
    |> Enum.map(&elem(&1, 0))
  end
end
```

`cp` test file.

### Step 7: Drill 2 — `Naturals.evens_below/1`

`lessons/09-streams/exercises/lib/naturals.ex`:

```elixir
defmodule Naturals do
  @moduledoc "Stream the natural numbers; filter and bound."

  @doc """
  Return all even naturals strictly less than `bound`, in ascending order.

      iex> Naturals.evens_below(10)
      [0, 2, 4, 6, 8]
  """
  def evens_below(_bound), do: raise("TODO: Stream.iterate +1, Stream.filter even, Stream.take_while < bound")
end
```

`lessons/09-streams/exercises/test/naturals_test.exs`:

```elixir
defmodule NaturalsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Naturals.evens_below/1 returns evens up to but not including the bound" do
    assert Naturals.evens_below(10) == [0, 2, 4, 6, 8]
  end

  @tag :pending
  test "Naturals.evens_below/1 returns [] for bound 0" do
    assert Naturals.evens_below(0) == []
  end

  @tag :pending
  test "Naturals.evens_below/1 returns [0] for bound 1" do
    assert Naturals.evens_below(1) == [0]
  end
end
```

`lessons/09-streams/solutions/lib/naturals.ex`:

```elixir
defmodule Naturals do
  @moduledoc "Stream the natural numbers; filter and bound."

  @doc """
  Return all even naturals strictly less than `bound`, in ascending order.

      iex> Naturals.evens_below(10)
      [0, 2, 4, 6, 8]
  """
  def evens_below(bound) do
    0
    |> Stream.iterate(&(&1 + 1))
    |> Stream.filter(&(rem(&1, 2) == 0))
    |> Stream.take_while(&(&1 < bound))
    |> Enum.to_list()
  end
end
```

`cp` test file.

### Step 8: Drill 3 — `LogStats.count_errors/1`

`lessons/09-streams/exercises/lib/log_stats.ex`:

```elixir
defmodule LogStats do
  @moduledoc "File-based stream drill — count ERROR lines in a log."

  @doc """
  Open `path` as a line stream; count lines containing the substring "ERROR".

  Returns an integer.
  """
  def count_errors(_path), do: raise("TODO: File.stream! the path, Stream.filter contains? ERROR, Enum.count")
end
```

`lessons/09-streams/exercises/test/log_stats_test.exs`:

```elixir
defmodule LogStatsTest do
  use ExUnit.Case, async: true

  @sample_path Path.join(__DIR__, "fixtures/sample.log")

  @tag :pending
  test "LogStats.count_errors/1 counts ERROR lines in the fixture" do
    assert LogStats.count_errors(@sample_path) == 5
  end

  @tag :pending
  test "LogStats.count_errors/1 returns 0 for a fixture without ERROR" do
    path = Path.join(__DIR__, "fixtures/no_errors.log")
    File.write!(path, "INFO ok\nDEBUG fine\n")
    try do
      assert LogStats.count_errors(path) == 0
    after
      File.rm!(path)
    end
  end
end
```

`lessons/09-streams/solutions/lib/log_stats.ex`:

```elixir
defmodule LogStats do
  @moduledoc "File-based stream drill — count ERROR lines in a log."

  @doc """
  Open `path` as a line stream; count lines containing the substring "ERROR".

  Returns an integer.
  """
  def count_errors(path) do
    path
    |> File.stream!()
    |> Stream.filter(&String.contains?(&1, "ERROR"))
    |> Enum.count()
  end
end
```

`cp` test file.

### Step 9: Verify and commit

```bash
cd lessons/09-streams/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `8 tests, 0 failures` for lesson 09 (Fibs 3 + Naturals 3 + LogStats 2).

```bash
git add lessons/09-streams
git commit -m "Add lesson 09-streams: lazy enumeration, pure + file-based

Three drills: Fibs.take/1 (Stream.iterate over pair-carrying state),
Naturals.evens_below/1 (Stream.iterate + filter + take_while), and
LogStats.count_errors/1 (File.stream! over a log fixture). The
fixture sample.log has 15 lines with 5 ERROR lines. README opens
with 'Recall from lesson 06' and frames streams as 'recipes, not
results.' Slides have four concept blocks under the 20-slide cap.

Solutions green: 8 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Lesson 10 — `structs-and-protocols`

**Files:**
- Scaffold + replace prose.
- Drills: `lib/point.ex` (with `defstruct`, `new/2`, `distance/2`, AND `defimpl String.Chars`), `lib/box.ex` (with `@enforce_keys`, `area/1`).

### Step 1: Scaffold

```bash
tools/new-lesson 10-structs-and-protocols
```

### Step 2: Replace README

Length 600–900 words.

1. Hook: "By the end of this lesson, you'll define your own structs (Elixir's named records) and you'll see how protocols let one function (`to_string`, `Enum.map`, etc.) work across types."
2. `## Key ideas`:
   - **`defstruct`.** A named, fixed-shape map with default values. `%MyStruct{}` creates one; `%MyStruct{field: value}` overrides defaults.
   - **`@enforce_keys`.** Lists fields that *must* be provided at creation time. `%Box{}` would raise; `%Box{width: 1, height: 2}` works.
   - **Structs are maps.** `%Point{x: 1, y: 2} |> Map.get(:x)` returns `1`. But pattern matching distinguishes them: `%Point{x: x}` won't match a plain map with `:x` and `:y`.
   - **Protocols, briefly.** A protocol declares a function signature. Different types provide their own implementations. `to_string/1` is a protocol (`String.Chars`); `Enum.map/2` is built on the `Enumerable` protocol. You'll implement `String.Chars` for `Point` in drill 3.
3. `## Try it in IEx` — transcript: define `Point` in iex, create one, call `Map.get`, then `to_string` (which fails until you `defimpl`).
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Treating a struct like a plain map for pattern matching. `%{x: x} = %Point{x: 1, y: 2}` works (struct *is* a map); `%Point{x: x} = %{x: 1, y: 2}` does NOT work (specific struct, not the right shape).
   - Forgetting `@enforce_keys`. Without it, every field defaults to `nil`. That's often not what you want.
   - Trying to call `to_string/1` on a struct without implementing `String.Chars`. You get a Protocol.UndefinedError.
6. `## Going further`:
   - Implement `String.Chars` for `Box` so `to_string(%Box{width: 3, height: 4})` returns `"3×4"`.
   - Look up `@derive [String.Chars]` — when can you use it? When can't you?
7. `## Links`:
   - [HexDocs — defstruct](https://hexdocs.pm/elixir/structs.html)
   - [HexDocs — defprotocol](https://hexdocs.pm/elixir/protocols.html)

### Step 3: Replace HINTS

Three sections.

`## Drill 1: Point with new/2 + distance/2`:
- Hint 1: "Two fields x and y. Plus a `new/2` constructor and `distance/2` between two points (Euclidean: `:math.sqrt((x2-x1)^2 + (y2-y1)^2)`)."
- Hint 2: "`defstruct [:x, :y]`. `new(x, y), do: %__MODULE__{x: x, y: y}`. `distance(a, b), do: :math.sqrt(:math.pow(b.x - a.x, 2) + :math.pow(b.y - a.y, 2))`."
- Hint 3: full code.

`## Drill 2: Box with @enforce_keys + area/1`:
- Hint 1: "`@enforce_keys [:width, :height]` then `defstruct [:width, :height]`. `area/1` multiplies them."
- Hint 2: "`def area(%Box{width: w, height: h}), do: w * h`."
- Hint 3: full code.

`## Drill 3: defimpl String.Chars for Point`:
- Hint 1: "Inside `point.ex`, add `defimpl String.Chars, for: Point do def to_string(%Point{x: x, y: y}), do: \"(#{x}, #{y})\" end`."
- Hint 2: "Place the `defimpl` after the `defmodule Point`."
- Hint 3: full code.

### Step 4: Replace slides

4 concept blocks: defstruct + creation, @enforce_keys + struct-as-map, Protocols (motivation + basics), Implementing String.Chars (worked example tying it together). ≤ 20 slides.

Closer: "Next: lesson 11 — error handling. Run: `make slides-dev LESSON=11-error-handling`."

### Step 5: Drill 1+3 — `Point` (struct + distance + String.Chars impl)

`lessons/10-structs-and-protocols/exercises/lib/point.ex`:

```elixir
defmodule Point do
  @moduledoc "A 2D point with a Euclidean-distance function."

  defstruct [:x, :y]

  @doc """
  Build a new point.

      iex> Point.new(1, 2)
      %Point{x: 1, y: 2}
  """
  def new(_x, _y), do: raise("TODO: return %__MODULE__{x: x, y: y}")

  @doc """
  Euclidean distance between two points.

      iex> Point.distance(Point.new(0, 0), Point.new(3, 4))
      5.0
  """
  def distance(_a, _b), do: raise("TODO: :math.sqrt(:math.pow(dx, 2) + :math.pow(dy, 2))")
end

defimpl String.Chars, for: Point do
  def to_string(%Point{x: _x, y: _y}), do: raise("TODO: return \"(x, y)\" as a string")
end
```

`lessons/10-structs-and-protocols/exercises/test/point_test.exs`:

```elixir
defmodule PointTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Point.new/2 builds a struct" do
    assert Point.new(1, 2) == %Point{x: 1, y: 2}
  end

  @tag :pending
  test "Point.distance/2 returns 0 for the same point" do
    p = Point.new(7, 8)
    assert Point.distance(p, p) == 0.0
  end

  @tag :pending
  test "Point.distance/2 computes a 3-4-5 triangle" do
    assert Point.distance(Point.new(0, 0), Point.new(3, 4)) == 5.0
  end

  @tag :pending
  test "String.Chars for Point formats as (x, y)" do
    assert to_string(Point.new(1, 2)) == "(1, 2)"
  end
end
```

`lessons/10-structs-and-protocols/solutions/lib/point.ex`:

```elixir
defmodule Point do
  @moduledoc "A 2D point with a Euclidean-distance function."

  defstruct [:x, :y]

  @doc """
  Build a new point.

      iex> Point.new(1, 2)
      %Point{x: 1, y: 2}
  """
  def new(x, y), do: %__MODULE__{x: x, y: y}

  @doc """
  Euclidean distance between two points.

      iex> Point.distance(Point.new(0, 0), Point.new(3, 4))
      5.0
  """
  def distance(%Point{x: ax, y: ay}, %Point{x: bx, y: by}) do
    :math.sqrt(:math.pow(bx - ax, 2) + :math.pow(by - ay, 2))
  end
end

defimpl String.Chars, for: Point do
  def to_string(%Point{x: x, y: y}), do: "(#{x}, #{y})"
end
```

`cp` test file.

### Step 6: Drill 2 — `Box`

`lessons/10-structs-and-protocols/exercises/lib/box.ex`:

```elixir
defmodule Box do
  @moduledoc "A box with enforced width and height keys."

  @enforce_keys [:width, :height]
  defstruct [:width, :height]

  @doc """
  Return the area of the box.

      iex> Box.area(%Box{width: 3, height: 4})
      12
  """
  def area(_box), do: raise("TODO: pattern-match %Box{width: w, height: h} and return w * h")
end
```

`lessons/10-structs-and-protocols/exercises/test/box_test.exs`:

```elixir
defmodule BoxTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Box.area/1 multiplies width by height" do
    assert Box.area(%Box{width: 3, height: 4}) == 12
  end

  @tag :pending
  test "Box.area/1 returns 0 for a zero dimension" do
    assert Box.area(%Box{width: 0, height: 7}) == 0
  end

  @tag :pending
  test "creating a Box without enforced keys raises" do
    assert_raise ArgumentError, fn -> struct!(Box, %{width: 1}) end
  end
end
```

`lessons/10-structs-and-protocols/solutions/lib/box.ex`:

```elixir
defmodule Box do
  @moduledoc "A box with enforced width and height keys."

  @enforce_keys [:width, :height]
  defstruct [:width, :height]

  @doc """
  Return the area of the box.

      iex> Box.area(%Box{width: 3, height: 4})
      12
  """
  def area(%Box{width: w, height: h}), do: w * h
end
```

`cp` test file.

### Step 7: Verify and commit

```bash
cd lessons/10-structs-and-protocols/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `7 tests, 0 failures`.

```bash
git add lessons/10-structs-and-protocols
git commit -m "Add lesson 10-structs-and-protocols: defstruct deep, protocols preview

Three drills bundled into two modules: Point (defstruct, new/2,
distance/2, plus defimpl String.Chars in the same file) and Box
(defstruct with @enforce_keys, area/1, plus a test that confirms
struct! raises when an enforced key is missing). Protocols are
introduced lightly — just enough to implement one stdlib protocol.
Full protocols treatment deferred to a later phase.

Solutions green: 7 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Lesson 11 — `error-handling`

**Files:**
- Scaffold + replace prose.
- Drills: `lib/safe_div.ex`, `lib/parse.ex`, `lib/pipeline.ex` + matching tests.

### Step 1: Scaffold

```bash
tools/new-lesson 11-error-handling
```

### Step 2: Replace README

Length 600–900 words.

1. Hook: "By the end of this lesson, you'll know when to return `{:ok, _}`/`{:error, _}` vs when to raise, and you'll have written `with` chains that compose fallible steps cleanly."
2. `## Key ideas`:
   - **The tagged-tuple convention.** `{:ok, value}` for success; `{:error, reason}` for expected failure. Used everywhere in Elixir (Phoenix, Ecto, Plug, …).
   - **Recall from lesson 04:** `with` chains lets you destructure each `{:ok, _}` and short-circuit on the first `{:error, _}`. Lesson 04 saw a preview; this lesson goes deeper with `else` clauses.
   - **`raise` is for things that should never happen.** Network call failed? Return `{:error, _}`. File didn't have the expected format because the file is corrupt and you don't know how to recover? Raise.
   - **`try`/`rescue` exists** but is rarely needed if you're working with `{:ok, _}`/`{:error, _}` consistently. Use it for cleaning up resources or for interop with code that raises.
3. `## Try it in IEx` — transcript showing tagged-tuple destructuring, then a `with` chain.
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Returning bare values instead of tagged tuples. `def fetch(url), do: response` is less composable than `def fetch(url), do: {:ok, response}`.
   - Rescuing too broadly. `rescue _ -> ...` swallows all errors, including bugs you want to see.
   - Forgetting the `else` clause in `with`. Without it, the first non-matching `<-` value falls through as the whole expression's result — which is sometimes what you want, but be explicit.
6. `## Going further`:
   - Write a `with` chain where the `else` clause logs the error and returns a sentinel `:fallback`.
   - Look up `Kernel.then/2` — when is it useful inside a `with` chain?
7. `## Links`:
   - [HexDocs — with](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1)
   - [HexDocs — try/rescue](https://hexdocs.pm/elixir/try-catch-and-rescue.html)

### Step 3: Replace HINTS

Three sections.

`## Drill 1: SafeDiv.divide/2`:
- Hint 1: "Two clauses on the divisor. If it's `0`, return `{:error, :div_by_zero}`. Otherwise return `{:ok, a / b}`."
- Hint 2: "`def divide(_a, 0), do: {:error, :div_by_zero}` / `def divide(a, b), do: {:ok, a / b}`."
- Hint 3: full code.

`## Drill 2: Parse.integer/1`:
- Hint 1: "`Integer.parse/1` returns `{n, rest}` on success or `:error` on failure. You also want to reject inputs with trailing garbage."
- Hint 2: "`case Integer.parse(s) do {n, \"\"} -> {:ok, n}; _ -> {:error, :invalid} end`."
- Hint 3: full code.

`## Drill 3: Pipeline.run/1`:
- Hint 1: "Three helper functions (`step_a/1`, `step_b/1`, `step_c/1`) defined in the same module. The `run/1` function chains them with `with`."
- Hint 2: "`with {:ok, a} <- step_a(x), {:ok, b} <- step_b(a), {:ok, c} <- step_c(b), do: {:ok, c}, else: ({:error, _} = err -> err)`."
- Hint 3: full code.

### Step 4: Replace slides

4 concept blocks: tagged tuples, raise vs return, with revisited, try/rescue glimpse. ≤ 20 slides.

Closer: "Next: lesson 12 — Mix projects. Time to build something. Run: `make slides-dev LESSON=12-mix-projects`."

### Step 5: Drill 1 — `SafeDiv.divide/2`

`lessons/11-error-handling/exercises/lib/safe_div.ex`:

```elixir
defmodule SafeDiv do
  @moduledoc "Division returning a tagged tuple."

  @doc """
  Divide `a` by `b`. Returns `{:ok, q}` for normal division and
  `{:error, :div_by_zero}` when `b` is zero.

      iex> SafeDiv.divide(10, 2)
      {:ok, 5.0}
      iex> SafeDiv.divide(1, 0)
      {:error, :div_by_zero}
  """
  def divide(_a, _b), do: raise("TODO: two clauses — the second arg matches 0 first, then a catch-all")
end
```

`lessons/11-error-handling/exercises/test/safe_div_test.exs`:

```elixir
defmodule SafeDivTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "SafeDiv.divide/2 returns {:ok, q} for normal division" do
    assert SafeDiv.divide(10, 2) == {:ok, 5.0}
  end

  @tag :pending
  test "SafeDiv.divide/2 returns {:error, :div_by_zero} when divisor is 0" do
    assert SafeDiv.divide(1, 0) == {:error, :div_by_zero}
  end

  @tag :pending
  test "SafeDiv.divide/2 handles negative numerators" do
    assert SafeDiv.divide(-6, 3) == {:ok, -2.0}
  end
end
```

`lessons/11-error-handling/solutions/lib/safe_div.ex`:

```elixir
defmodule SafeDiv do
  @moduledoc "Division returning a tagged tuple."

  @doc """
  Divide `a` by `b`. Returns `{:ok, q}` for normal division and
  `{:error, :div_by_zero}` when `b` is zero.

      iex> SafeDiv.divide(10, 2)
      {:ok, 5.0}
      iex> SafeDiv.divide(1, 0)
      {:error, :div_by_zero}
  """
  def divide(_a, 0), do: {:error, :div_by_zero}
  def divide(a, b), do: {:ok, a / b}
end
```

`cp` test file.

### Step 6: Drill 2 — `Parse.integer/1`

`lessons/11-error-handling/exercises/lib/parse.ex`:

```elixir
defmodule Parse do
  @moduledoc "Parse helpers that return tagged tuples."

  @doc """
  Parse a string as an integer. Returns `{:ok, n}` for a clean integer
  string; `{:error, :invalid}` for anything else.

      iex> Parse.integer("42")
      {:ok, 42}
      iex> Parse.integer("oops")
      {:error, :invalid}
      iex> Parse.integer("42abc")
      {:error, :invalid}
  """
  def integer(_s), do: raise("TODO: case Integer.parse(s) → {n, \"\"} / _ → :invalid")
end
```

`lessons/11-error-handling/exercises/test/parse_test.exs`:

```elixir
defmodule ParseTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Parse.integer/1 returns {:ok, n} for a clean integer string" do
    assert Parse.integer("42") == {:ok, 42}
  end

  @tag :pending
  test "Parse.integer/1 returns {:error, :invalid} for non-numeric input" do
    assert Parse.integer("oops") == {:error, :invalid}
  end

  @tag :pending
  test "Parse.integer/1 returns {:error, :invalid} for trailing garbage" do
    assert Parse.integer("42abc") == {:error, :invalid}
  end

  @tag :pending
  test "Parse.integer/1 handles negative integers" do
    assert Parse.integer("-7") == {:ok, -7}
  end
end
```

`lessons/11-error-handling/solutions/lib/parse.ex`:

```elixir
defmodule Parse do
  @moduledoc "Parse helpers that return tagged tuples."

  @doc """
  Parse a string as an integer. Returns `{:ok, n}` for a clean integer
  string; `{:error, :invalid}` for anything else.

      iex> Parse.integer("42")
      {:ok, 42}
      iex> Parse.integer("oops")
      {:error, :invalid}
      iex> Parse.integer("42abc")
      {:error, :invalid}
  """
  def integer(s) do
    case Integer.parse(s) do
      {n, ""} -> {:ok, n}
      _ -> {:error, :invalid}
    end
  end
end
```

`cp` test file.

### Step 7: Drill 3 — `Pipeline.run/1`

`lessons/11-error-handling/exercises/lib/pipeline.ex`:

```elixir
defmodule Pipeline do
  @moduledoc "Chain three fallible steps with `with`."

  @doc """
  Run three steps. If all succeed, return `{:ok, final}`. The first
  failure short-circuits and is returned via the `else` clause.

      iex> Pipeline.run(1)
      {:ok, 16}
      iex> Pipeline.run(:fail_a)
      {:error, :step_a_failed}
  """
  def run(_input), do: raise("TODO: with chain step_a/1 then step_b/1 then step_c/1, else passes errors through")

  @doc false
  def step_a(:fail_a), do: {:error, :step_a_failed}
  def step_a(x) when is_integer(x), do: {:ok, x + 1}
  def step_a(_), do: {:error, :step_a_failed}

  @doc false
  def step_b(:fail_b), do: {:error, :step_b_failed}
  def step_b(x) when is_integer(x), do: {:ok, x * 2}
  def step_b(_), do: {:error, :step_b_failed}

  @doc false
  def step_c(:fail_c), do: {:error, :step_c_failed}
  def step_c(x) when is_integer(x), do: {:ok, x * x}
  def step_c(_), do: {:error, :step_c_failed}
end
```

`lessons/11-error-handling/exercises/test/pipeline_test.exs`:

```elixir
defmodule PipelineTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pipeline.run/1 returns the final value when all steps succeed" do
    # step_a: 1+1=2; step_b: 2*2=4; step_c: 4*4=16
    assert Pipeline.run(1) == {:ok, 16}
  end

  @tag :pending
  test "Pipeline.run/1 short-circuits at step a" do
    assert Pipeline.run(:fail_a) == {:error, :step_a_failed}
  end

  @tag :pending
  test "Pipeline.run/1 short-circuits at step c with sentinel input :fail_c after a/b" do
    # input :fail_c is not an integer, so step_a returns the catch-all
    # error :step_a_failed — confirm the failure is reported with the
    # original error reason, not silently lost.
    assert Pipeline.run(:fail_c) == {:error, :step_a_failed}
  end
end
```

`lessons/11-error-handling/solutions/lib/pipeline.ex`:

```elixir
defmodule Pipeline do
  @moduledoc "Chain three fallible steps with `with`."

  @doc """
  Run three steps. If all succeed, return `{:ok, final}`. The first
  failure short-circuits and is returned via the `else` clause.

      iex> Pipeline.run(1)
      {:ok, 16}
      iex> Pipeline.run(:fail_a)
      {:error, :step_a_failed}
  """
  def run(input) do
    with {:ok, a} <- step_a(input),
         {:ok, b} <- step_b(a),
         {:ok, c} <- step_c(b) do
      {:ok, c}
    else
      {:error, _} = err -> err
    end
  end

  @doc false
  def step_a(:fail_a), do: {:error, :step_a_failed}
  def step_a(x) when is_integer(x), do: {:ok, x + 1}
  def step_a(_), do: {:error, :step_a_failed}

  @doc false
  def step_b(:fail_b), do: {:error, :step_b_failed}
  def step_b(x) when is_integer(x), do: {:ok, x * 2}
  def step_b(_), do: {:error, :step_b_failed}

  @doc false
  def step_c(:fail_c), do: {:error, :step_c_failed}
  def step_c(x) when is_integer(x), do: {:ok, x * x}
  def step_c(_), do: {:error, :step_c_failed}
end
```

`cp` test file.

### Step 8: Verify and commit

```bash
cd lessons/11-error-handling/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `10 tests, 0 failures`.

```bash
git add lessons/11-error-handling
git commit -m "Add lesson 11-error-handling: {:ok, _}/{:error, _}, raise, with

Three drills: SafeDiv.divide/2 (two clauses, divisor pattern matches
0 first), Parse.integer/1 (Integer.parse + case for trailing-garbage
rejection), Pipeline.run/1 (with chain across three helper steps with
explicit else clause). README distinguishes 'return tagged tuple'
from 'raise for never-supposed-to-happen' and notes try/rescue's
narrow use cases. Slides cap at four concept blocks.

Solutions green: 10 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Lesson 12 — `mix-projects` (Phase 1 capstone)

**Files:**
- Scaffold + replace prose.
- Drills: `lib/wc_ex/counts.ex`, `lib/wc_ex.ex`, `lib/wc_ex/cli.ex` + matching tests.
- Fixture: `test/fixtures/lorem.txt` in both exercises and solutions.
- `mix.exs` modification: add `escript: [main_module: WcEx.CLI]`.
- `.gitignore`: add `wc_ex` line.

### Step 1: Scaffold

```bash
tools/new-lesson 12-mix-projects
```

### Step 2: Modify `mix.exs` in both `exercises/` and `solutions/`

Add `escript: [main_module: WcEx.CLI]` to the `def project` keyword list. Final `mix.exs` (both):

```elixir
# Mix project skeleton for a lesson. `excoveralls` is included in every
# lesson's dependencies for consistency — the testing-deep-dive lesson
# (lesson 34) and onward use coverage reports; earlier lessons ignore it
# and the dep adds negligible compile time.

defmodule Lesson12MixProjects.MixProject do
  use Mix.Project

  def project do
    [
      app: :lesson_12_mix_projects,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
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

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end
end
```

### Step 3: Add `.gitignore` for the built escript binary

`lessons/12-mix-projects/.gitignore`:

```
# Built escript binary (from `mix escript.build`)
wc_ex
```

(Place at lesson root, not inside exercises/ or solutions/. The build can land at either path; one ignore covers both.)

### Step 4: Replace README

Length 700–1000 words. Sections:

1. Hook: "By the end of this lesson, you'll have built `wc_ex` — a tiny CLI tool that counts lines/words/characters in a file, just like Unix `wc`. You'll use everything from Phase 1 — streams, strings, Enum, structs — and you'll build it with the same Mix tooling every Elixir library uses."
2. `## Key ideas`:
   - **Recall from lessons 06, 08, 09, 10.** This lesson stitches them together.
   - **`mix new <name>`** scaffolds a fresh Mix project. The lesson explains the generated tree.
   - **`mix.exs` structure.** `project`, `application`, `deps`. The `escript:` field is new in this lesson — it tells Mix this project produces a runnable script.
   - **`mix escript.build`** produces a self-contained Erlang script (with a `#!` line) that you can invoke as `./wc_ex some.txt`. Works wherever Erlang is installed.
   - **The CLI entry point.** A module with a `main/1` function that takes argv as a list of strings. Mix wires that up from the `escript:` field.
3. `## Try it in IEx` — show running `WcEx.count_file/1` interactively first, before going to the escript.
4. `## How to work this lesson`:
   - Read this README.
   - Skim slides.
   - Write drills 1, 2, 3 in order. Tests get green.
   - Final step: `cd lessons/12-mix-projects/solutions && mix escript.build && ./wc_ex test/fixtures/lorem.txt`. You should see something like `10\t68\t440\ttest/fixtures/lorem.txt`.
5. `## Common mistakes`:
   - Forgetting `escript: [main_module: WcEx.CLI]` in `mix.exs`. Without it, `mix escript.build` doesn't know where to start.
   - Returning a non-zero exit from `main/1` accidentally. Use `System.halt(1)` if you actually want a non-zero status.
   - Hard-coding the path in `count_file/1` instead of taking it as an argument. Take the path; defer file-not-found handling to `main/1`.
6. `## Going further`:
   - Make `wc_ex` accept `-l`/`-w`/`-c` flags like real `wc`. Hint: `OptionParser`.
   - Make `wc_ex` work with multiple file arguments. What changes in `main/1`? In `count_file/1`?
7. `## Links`:
   - [HexDocs — Mix.escript](https://hexdocs.pm/mix/Mix.Tasks.Escript.Build.html)
   - [HexDocs — File](https://hexdocs.pm/elixir/File.html)
   - [The official Unix `wc` man page](https://www.man7.org/linux/man-pages/man1/wc.1.html)

### Step 5: Replace HINTS

`lessons/12-mix-projects/HINTS.md` — ~400 words. Three sections.

`## Drill 1: WcEx.Counts struct + add/2`:
- Hint 1: "`defstruct lines: 0, words: 0, chars: 0`. `add/2` takes a `%Counts{}` and a line, returns the updated `%Counts{}`."
- Hint 2: "Words = `line |> String.split() |> length()`. Chars = `String.length(line)`."
- Hint 3: full code.

`## Drill 2: WcEx.count_file/1`:
- Hint 1: "`File.stream!(path)` gives you a line stream. `Enum.reduce(stream, %Counts{}, &Counts.add/2)`."
- Hint 2: "But `File.stream!` lines include trailing `\\n` — your `add/2` needs to handle that (or strip newlines)."
- Hint 3: full code.

`## Drill 3: WcEx.CLI.main/1`:
- Hint 1: "argv is a list. The first element is the path. Call `count_file/1`. Format the result. `IO.puts`."
- Hint 2: "`[path | _] = argv; %Counts{lines: l, words: w, chars: c} = WcEx.count_file(path); IO.puts(\"#{l}\\t#{w}\\t#{c}\\t#{path}\")`."
- Hint 3: full code.

### Step 6: Replace slides

4 concept blocks: Mix project anatomy (`mix new`, `mix.exs`, `lib/`, `test/`), Mix.exs `escript:` field, `escript.build` and what it produces, the CLI worked example. ≤ 20 slides.

Closer: "🎉 Phase 1 done. Phase 2 — concurrency and OTP — next. Run: `make slides-dev LESSON=13-processes`."

### Step 7: Create fixture file

`lessons/12-mix-projects/exercises/test/fixtures/lorem.txt`:

```
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.
Nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.
Dolore eu fugiat nulla pariatur excepteur sint occaecat cupidatat.
Non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
Ut perspiciatis unde omnis iste natus error sit voluptatem.
Accusantium doloremque laudantium totam rem aperiam.
Eaque ipsa quae ab illo inventore veritatis et quasi architecto.
```

(10 lines, ~68 words, ~440 characters total.)

Mirror to solutions:

```bash
mkdir -p lessons/12-mix-projects/solutions/test/fixtures
cp lessons/12-mix-projects/exercises/test/fixtures/lorem.txt \
   lessons/12-mix-projects/solutions/test/fixtures/lorem.txt
```

### Step 8: Drill 1 — `WcEx.Counts`

`lessons/12-mix-projects/exercises/lib/wc_ex/counts.ex`:

```elixir
defmodule WcEx.Counts do
  @moduledoc "Accumulator struct for line/word/char counts."

  defstruct lines: 0, words: 0, chars: 0

  @doc """
  Update the running counts with one line of text.

      iex> WcEx.Counts.add(%WcEx.Counts{}, "hello world\\n")
      %WcEx.Counts{lines: 1, words: 2, chars: 11}
  """
  def add(_counts, _line), do: raise("TODO: increment lines by 1, add word count from String.split, add String.length(line)")
end
```

`lessons/12-mix-projects/exercises/test/wc_ex/counts_test.exs`:

```elixir
defmodule WcEx.CountsTest do
  use ExUnit.Case, async: true

  alias WcEx.Counts

  @tag :pending
  test "Counts.add/2 increments lines, words, and chars" do
    counts = Counts.add(%Counts{}, "hello world\n")
    assert counts.lines == 1
    assert counts.words == 2
    assert counts.chars == String.length("hello world\n")
  end

  @tag :pending
  test "Counts.add/2 accumulates across calls" do
    counts = %Counts{} |> Counts.add("a b c\n") |> Counts.add("d e\n")
    assert counts.lines == 2
    assert counts.words == 5
  end

  @tag :pending
  test "Counts.add/2 handles an empty line" do
    counts = Counts.add(%Counts{}, "\n")
    assert counts.lines == 1
    assert counts.words == 0
    assert counts.chars == 1
  end
end
```

`lessons/12-mix-projects/solutions/lib/wc_ex/counts.ex`:

```elixir
defmodule WcEx.Counts do
  @moduledoc "Accumulator struct for line/word/char counts."

  defstruct lines: 0, words: 0, chars: 0

  @doc """
  Update the running counts with one line of text.

      iex> WcEx.Counts.add(%WcEx.Counts{}, "hello world\\n")
      %WcEx.Counts{lines: 1, words: 2, chars: 11}
  """
  def add(%__MODULE__{lines: l, words: w, chars: c}, line) do
    %__MODULE__{
      lines: l + 1,
      words: w + (line |> String.split() |> length()),
      chars: c + String.length(line)
    }
  end
end
```

`cp` test file (preserve the nested `test/wc_ex/` path):

```bash
mkdir -p lessons/12-mix-projects/solutions/test/wc_ex
cp lessons/12-mix-projects/exercises/test/wc_ex/counts_test.exs \
   lessons/12-mix-projects/solutions/test/wc_ex/counts_test.exs
```

### Step 9: Drill 2 — `WcEx.count_file/1`

`lessons/12-mix-projects/exercises/lib/wc_ex.ex`:

```elixir
defmodule WcEx do
  @moduledoc "Tiny word-counter — Phase 1 capstone."

  alias WcEx.Counts

  @doc """
  Stream a file line-by-line and return a %Counts{}.

      iex> path = Path.join(__DIR__, "..\/test\/fixtures\/lorem.txt")
      iex> %WcEx.Counts{lines: lines} = WcEx.count_file(path)
      iex> lines > 0
      true
  """
  def count_file(_path), do: raise("TODO: File.stream! |> Enum.reduce(%Counts{}, &Counts.add/2)")
end
```

`lessons/12-mix-projects/exercises/test/wc_ex_test.exs`:

```elixir
defmodule WcExTest do
  use ExUnit.Case, async: true

  alias WcEx.Counts

  @fixture Path.join(__DIR__, "fixtures/lorem.txt")

  @tag :pending
  test "WcEx.count_file/1 returns a Counts struct" do
    assert %Counts{} = WcEx.count_file(@fixture)
  end

  @tag :pending
  test "WcEx.count_file/1 counts the right number of lines" do
    %Counts{lines: lines} = WcEx.count_file(@fixture)
    # The fixture has exactly 10 lines (no trailing newline beyond the last \n).
    assert lines == 10
  end

  @tag :pending
  test "WcEx.count_file/1 counts a positive number of words" do
    %Counts{words: words} = WcEx.count_file(@fixture)
    assert words > 50
  end
end
```

`lessons/12-mix-projects/solutions/lib/wc_ex.ex`:

```elixir
defmodule WcEx do
  @moduledoc "Tiny word-counter — Phase 1 capstone."

  alias WcEx.Counts

  @doc """
  Stream a file line-by-line and return a %Counts{}.

      iex> path = Path.join(__DIR__, "..\/test\/fixtures\/lorem.txt")
      iex> %WcEx.Counts{lines: lines} = WcEx.count_file(path)
      iex> lines > 0
      true
  """
  def count_file(path) do
    path
    |> File.stream!()
    |> Enum.reduce(%Counts{}, &Counts.add(&2, &1))
  end
end
```

`cp` test file.

### Step 10: Drill 3 — `WcEx.CLI`

`lessons/12-mix-projects/exercises/lib/wc_ex/cli.ex`:

```elixir
defmodule WcEx.CLI do
  @moduledoc "Escript entry point — wired up via mix.exs :escript option."

  alias WcEx.Counts

  @doc """
  Entry point. Receives argv as a list of strings. The first arg is the path.
  Prints `<lines>\\t<words>\\t<chars>\\t<path>` to stdout.
  """
  def main(_argv), do: raise("TODO: destructure [path | _] = argv, count_file, format, IO.puts")
end
```

`lessons/12-mix-projects/exercises/test/wc_ex/cli_test.exs`:

```elixir
defmodule WcEx.CLITest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  @fixture Path.join(__DIR__, "../fixtures/lorem.txt")

  @tag :pending
  test "WcEx.CLI.main/1 prints lines, words, chars, path" do
    output = capture_io(fn -> WcEx.CLI.main([@fixture]) end)
    assert output =~ "10\t"
    assert output =~ @fixture
  end
end
```

`lessons/12-mix-projects/solutions/lib/wc_ex/cli.ex`:

```elixir
defmodule WcEx.CLI do
  @moduledoc "Escript entry point — wired up via mix.exs :escript option."

  alias WcEx.Counts

  @doc """
  Entry point. Receives argv as a list of strings. The first arg is the path.
  Prints `<lines>\\t<words>\\t<chars>\\t<path>` to stdout.
  """
  def main([path | _]) do
    %Counts{lines: l, words: w, chars: c} = WcEx.count_file(path)
    IO.puts("#{l}\t#{w}\t#{c}\t#{path}")
  end

  def main([]) do
    IO.puts(:stderr, "usage: wc_ex FILE")
    System.halt(1)
  end
end
```

`cp` test file (note nested path):

```bash
mkdir -p lessons/12-mix-projects/solutions/test/wc_ex
cp lessons/12-mix-projects/exercises/test/wc_ex/cli_test.exs \
   lessons/12-mix-projects/solutions/test/wc_ex/cli_test.exs
```

### Step 11: Verify the escript builds and runs

```bash
cd lessons/12-mix-projects/solutions
mix deps.get
mix test --include pending
mix escript.build
./wc_ex test/fixtures/lorem.txt
cd -
```

Expected:
- `mix test`: ~10 tests pass.
- `mix escript.build`: produces a binary at `lessons/12-mix-projects/solutions/wc_ex`.
- `./wc_ex test/fixtures/lorem.txt`: prints a tab-separated line of counts.

### Step 12: Verify the full pipeline + commit

```bash
tools/check-solutions
tools/lint-all
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist
grep -c 'lessons/12-mix-projects/slides/' dist/index.html
rm -rf dist
```

All pass; build_index lights up lesson 12.

```bash
git add lessons/12-mix-projects
git commit -m "Add lesson 12-mix-projects: Phase 1 capstone — build wc_ex CLI

Three drills compose into a tiny working CLI: WcEx.Counts (defstruct
+ add/2 reducer), WcEx.count_file/1 (File.stream! + Enum.reduce),
WcEx.CLI.main/1 (escript entry point). mix.exs gets
escript: [main_module: WcEx.CLI] so 'mix escript.build' produces a
runnable ./wc_ex binary that mimics Unix wc's default tab-separated
output. The built binary is gitignored at the lesson level.

Fixture test/fixtures/lorem.txt (10 lines of Lorem Ipsum) is used by
both WcEx.count_file/1 tests and WcEx.CLI.main/1 tests via
Path.join(__DIR__, ...).

The lesson closes Phase 1 — README walks through 'recall from
lessons 06/08/09/10' explicitly. Slides have four concept blocks
(mix anatomy, escript: field, escript.build, CLI worked example)
under the 20-slide cap.

Solutions green: ~10 tests, 0 failures. Built escript runs against
the fixture and prints sensible output.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 9: Final smoke + PR

### Step 1: Run the full pipeline

```bash
make ci-smoke
make solutions-test
make lint
make slides-build
```

Expected: all four succeed. `tools/check-solutions` reports each lesson's pass count, total Phase 0 + Phase 1 ≈ 47 + 28 = 75 tests passing.

### Step 2: Confirm all 13 lessons are "published"

```bash
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules \
         04-control-flow 05-recursion 06-enum-and-the-pipe 07-collections \
         08-strings-and-binaries 09-streams 10-structs-and-protocols \
         11-error-handling 12-mix-projects; do
  grep -q "lessons/$n/slides/" dist/index.html && echo "$n: PUBLISHED" || echo "$n: MISSING"
done
```

Expected: all thirteen print `PUBLISHED`.

### Step 3: Smoke test the capstone CLI

```bash
cd lessons/12-mix-projects/solutions
mix escript.build
./wc_ex test/fixtures/lorem.txt
cd -
```

Expected: a tab-separated line of counts.

### Step 4: Clean up dist

```bash
rm -rf dist
```

### Step 5: Push branch

```bash
git push -u origin plan-c-phase-1
```

### Step 6: Open PR

```bash
gh pr create --base main --head plan-c-phase-1 \
    --title "Plan C: Phase 1 lessons (05 recursion through 12 mix-projects)" \
    --body "$(cat <<'EOF'
## Summary
- Implements [Plan C](docs/superpowers/plans/2026-05-26-plan-c-phase-1-lessons.md) — the eight Phase 1 lessons of the course.
- Lesson 05 (recursion): four drills covering head/tail and the accumulator pattern.
- Lessons 06-11: micro-drills in `Enum`/pipe, collections, strings/binaries, streams, structs+protocols, error handling.
- Lesson 12 is the Phase 1 capstone: a `wc_ex` CLI built with `mix escript.build`.
- After this PR merges, the landing page at https://elixir.ristkari.dev/ lights up the Phase 1 row.

## Drills shipped (per lesson)
- **05-recursion** (4 drills, 12 tests): Sum, Counter, Mapper, Reverser.
- **06-enum-and-the-pipe** (4 drills bundled in 2 modules, 9 tests): Lists (doubled/evens/sum), Pipeline.
- **07-collections** (3 drills, 10 tests): Freq, Config, MapMerge.
- **08-strings-and-binaries** (4 drills in 3 modules, 11 tests): Letters (vowel_count/title_case), Header, KV.
- **09-streams** (3 drills, 8 tests): Fibs, Naturals, LogStats. Adds fixture sample.log.
- **10-structs-and-protocols** (3 drills in 2 modules, 7 tests): Point (struct + distance + String.Chars), Box (with @enforce_keys).
- **11-error-handling** (3 drills, 10 tests): SafeDiv, Parse, Pipeline (with-chain).
- **12-mix-projects** (3 drills, ~10 tests, plus the working escript): WcEx.Counts, WcEx, WcEx.CLI. mix.exs adds `escript: [main_module: WcEx.CLI]`.

## Notable plan deviations (called out in commits if any)
- (None expected; the plan is precise. If implementation produces deviations they're noted in lesson commit bodies.)

## Test plan
- [ ] CI workflow turns green (lint, harness, exercises, solutions, slides-build, dist verification).
- [ ] After merge, Deploy rebuilds the slide site and https://elixir.ristkari.dev/ shows lessons 05-12 as published cards.
- [ ] `cd lessons/12-mix-projects/solutions && mix escript.build && ./wc_ex test/fixtures/lorem.txt` prints a sensible counts line.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 7: Watch CI

```bash
gh pr checks --watch
```

Expected: CI passes.

### Step 8: Merge (after review)

If approved, squash-merge as Plan B was:

```bash
gh pr merge --squash --delete-branch
```

This triggers the Deploy workflow, rebuilding https://elixir.ristkari.dev/ with the Phase 1 row lit.

---

## Self-review checklist (already applied)

**Spec coverage:**
- Per-lesson concept breakdown — each lesson task lists the spec's modules, drill count, and analogies.
- Phase 1 conventions ("Recall from lesson NN", fixture directories, lesson-12 escript additions) — all enforced.
- Definition of done — Task 9 enforces (full smoke + escript demo).
- Risks — not encoded in plan, stay in spec.
- Non-goals (no property testing, no Mix umbrella, no deep TCO) — respected.

**Placeholders:** None. Each drill has exact code; README/HINTS/slides are detailed outlines (the implementer fills prose within the structure, which is the documented authoring pattern from Phase 0).

**Type consistency:** Module names match across exercises/solutions/HINTS/slides for every drill. `WcEx.Counts`/`WcEx`/`WcEx.CLI` namespace is consistent in Task 8. The `wc_ex` binary name is consistent across `mix.exs` escript field, `.gitignore`, and the final smoke command.
