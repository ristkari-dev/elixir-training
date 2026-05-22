# Plan B — Phase 0 Lessons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the five Phase 0 lessons (00-setup through 04-control-flow) so a complete beginner can install Elixir, write code in IEx and Mix, and absorb values & types, pattern matching, functions & modules, and control flow.

**Architecture:** Lessons 01–04 use the existing `shared/lesson-template/` scaffolded by `tools/new-lesson`, with hand-authored README/HINTS/slides + 3–5 micro-drill Mix exercises (one module per file, one `_test.exs` per module). Lesson 00 is the deliberate deviation — no `exercises/`/`solutions/` Mix project; it's an onboarding lesson with hand-crafted README/HINTS/slides only. After all lessons land, the build_index landing page lights up lessons 00–04 as "published" and Cloud Run redeploys.

**Tech Stack:** Elixir 1.18 + Erlang/OTP 27, ExUnit (with `@tag :pending` skipped by default in exercises), reveal.js 5.1.0 for slides, the repo's existing Makefile + tools (`new-lesson`, `run-all-tests`, `check-solutions`, `lint-all`, `build_index`).

**Pre-flight:** Run from repo root `/Users/ristkari/code/private/elixir-training/`. Current branch `main` is up-to-date. Work happens on a new branch `plan-b-phase-0` (created in Task 0). All commits are GPG-signed by the repo's git config.

**Spec:** [`docs/superpowers/specs/2026-05-22-phase-0-design.md`](../specs/2026-05-22-phase-0-design.md).

---

## File map

Per-lesson, the file inventory is uniform for lessons 01–04:

```
lessons/NN-slug/
├── README.md                    hand-authored (replaces template)
├── HINTS.md                     hand-authored (replaces template)
├── slides/
│   ├── index.html               unchanged from template
│   └── slides.md                hand-authored (replaces template)
├── exercises/
│   ├── mix.exs                  template (NN/slug substituted by scaffolder)
│   ├── .formatter.exs           template (unchanged)
│   ├── lib/
│   │   ├── <module1>.ex         drill 1 stub (raise "TODO: ...")
│   │   ├── <module2>.ex         drill 2 stub
│   │   └── …                    one per drill
│   └── test/
│       ├── test_helper.exs      template (unchanged)
│       ├── <module1>_test.exs   drill 1 failing tests (@tag :pending)
│       ├── <module2>_test.exs   drill 2 failing tests
│       └── …
└── solutions/
    ├── mix.exs                  template
    ├── .formatter.exs           template
    ├── lib/
    │   ├── <module1>.ex         drill 1 reference impl
    │   └── …
    └── test/
        ├── test_helper.exs      template
        ├── <module1>_test.exs   identical to exercises/test/<module1>_test.exs
        └── …
```

Lesson 00 (`lessons/00-setup/`) has only `README.md`, `HINTS.md`, and `slides/`. No `exercises/` or `solutions/`.

The `tools/new-lesson` scaffolder is used for lessons 01–04. Lesson 00 is created by hand because the scaffolder always emits `exercises/` and `solutions/` directories.

### Conventions locked in by this plan

- **One module per file.** `exercises/lib/math.ex` contains exactly `defmodule Math do … end`. Tests live in `exercises/test/math_test.exs`.
- **Test files are byte-identical between `exercises/` and `solutions/`.** After authoring the exercise test file, `cp` it to the matching solutions path.
- **All exercise tests carry `@tag :pending`.** The exercises' `test_helper.exs` (from the template) sets `ExUnit.start(exclude: [pending: true])`, so the default `mix test` is green. Learners opt in with `mix test --include pending`.
- **Solution test files keep the `@tag :pending` markers.** Solutions' `test_helper.exs` is `ExUnit.start()` — no exclusion — so the tags are ignored and every test runs.
- **`@moduledoc` is required on every drill module.** A one-line `@moduledoc` per module — enough to identify the drill's purpose. Avoids the Credo `Readability.ModuleDoc` rule when Credo activates in lesson 34.

---

## Task 0: Branch + spec reference

**Files:** none changed yet; this task creates the working branch.

- [ ] **Step 1: Confirm clean working tree on main**

```bash
git status
git log --oneline -1
```

Expected: `nothing to commit, working tree clean`, last commit is `2cb0c3c Upgrade workflow actions to native Node 24 versions` (or newer if main has advanced).

- [ ] **Step 2: Create and switch to the working branch**

```bash
git checkout -b plan-b-phase-0
git status
```

Expected: `On branch plan-b-phase-0`, working tree clean.

- [ ] **Step 3: Verify the spec is present**

```bash
test -f docs/superpowers/specs/2026-05-22-phase-0-design.md && echo OK
```

Expected: prints `OK`.

No commit in this task — the branch start point matches `main`.

---

## Task 1: Lesson 00 — `setup`

**Files:**
- Create: `lessons/00-setup/README.md`
- Create: `lessons/00-setup/HINTS.md`
- Create: `lessons/00-setup/slides/index.html`
- Create: `lessons/00-setup/slides/slides.md`

No `exercises/` or `solutions/` directory. The `tools/new-lesson` scaffolder is **not** used for this lesson.

### Step 1: Create the lesson directories

```bash
mkdir -p lessons/00-setup/slides
```

Expected: directories exist; nothing in them yet.

### Step 2: Author `lessons/00-setup/README.md`

Length target: **1500–2000 words**.

Section order and contents (each section is a level-2 heading `##`):

1. **`# Lesson 00: Setup`** (level-1 heading at the top).
2. **Intro paragraph (no heading)** — one paragraph stating what the lesson does in plain language: "By the end of this lesson, you'll have Elixir running on your machine, you'll have typed your first lines of Elixir into iex, and you'll have created and run your first Mix project."
3. **`## What programming is, and what Elixir is`** — three paragraphs:
   - What programming is: writing instructions for a computer.
   - What Elixir is: a friendly, fault-tolerant language that runs on the BEAM virtual machine. Real things people build with it (Phoenix-powered web apps, real-time chat, Discord's millions of concurrent connections).
   - Why this course exists: we'll go from here to a deployed Phoenix app.
4. **`## What you'll need`** — bulleted list:
   - A computer running macOS or Linux. (Windows learners: see the WSL2 pointer below.)
   - Roughly 5 GB of free disk space (asdf + OTP + Elixir + Xcode CLT or build essentials).
   - An internet connection.
   - A couple of hours of focused time.
5. **`## A note before we start`** — one short paragraph: "This lesson is deliberately long. Read it from top to bottom, follow the steps for your operating system, and don't skip ahead. If you get stuck, see the Troubleshooting section at the end."
6. **`## macOS path`** — step-by-step, each step a `###` subsection:
   - `### 1. Install Homebrew` — link to <https://brew.sh>, the one-liner curl install. Annotated.
   - `### 2. Install asdf via Homebrew` — `brew install asdf`. Then the line to add asdf to the shell (`. $(brew --prefix asdf)/libexec/asdf.sh` in `~/.zshrc`). Mention: "Close the terminal window and open a new one."
   - `### 3. Install the Erlang and Elixir asdf plugins` — `asdf plugin add erlang`, `asdf plugin add elixir`.
   - `### 4. Install Xcode Command Line Tools` — `xcode-select --install` (needed for the Erlang build). Note: this can take 20+ minutes; grab coffee.
   - `### 5. Install Erlang and Elixir using the versions pinned in this repo` — `cd` into the repo if they have it, otherwise create a temporary directory with a `.tool-versions` file containing the same `elixir 1.18.2-otp-27` / `erlang 27.2` lines. Then `asdf install`.
   - `### 6. Verify the install` — `elixir --version`, expected output (paraphrased "Elixir 1.18.2 (compiled with Erlang/OTP 27)").
7. **`## Linux path`** — same shape:
   - `### 1. Install build dependencies` — `apt`, `dnf`, or `pacman` line for each distro (Ubuntu/Debian, Fedora/RHEL, Arch). Required packages: `build-essential`, `libssl-dev`, `automake`, `autoconf`, `libncurses5-dev`. Same idea per distro.
   - `### 2. Install asdf via git` — `git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.15.0`. Then the `. ~/.asdf/asdf.sh` line in `~/.bashrc` or `~/.zshrc`.
   - `### 3. Install the Erlang and Elixir asdf plugins` — same as macOS step 3.
   - `### 4. Install Erlang and Elixir` — same `asdf install` step.
   - `### 5. Verify the install` — same `elixir --version` step.
8. **`## Windows learners — use WSL2`** — short section with a link to <https://learn.microsoft.com/windows/wsl/install>. State: "Install WSL2 with Ubuntu, open the Ubuntu terminal, and follow the Linux path above."
9. **`## Your first Elixir program (in iex)`** — narrative walkthrough:
   - Open a terminal, type `iex`. Show expected prompt.
   - Type `1 + 1`. Show output `2`.
   - Type `IO.puts("Hello, Elixir!")`. Show the printed line and the returned `:ok`.
   - Press `Ctrl-C` twice to exit (or `Ctrl-G`, then `q`). Mention both.
   - Use the REPL-transcript formatting from the spec (no `iex(1)>`).
10. **`## Your first Elixir file (with Mix)`** — narrative walkthrough:
    - `cd ~/code` (or wherever they want a sandbox).
    - `mix new hello`. Show the generated tree.
    - `cd hello`.
    - Show the default `lib/hello.ex` (`def hello, do: :world`).
    - Run `mix test`. Show the green output.
    - Mention: this is the shape every lesson uses.
11. **`## Install a code editor — VS Code with ElixirLS`** — one paragraph + 4 bullets:
    - Download VS Code from <https://code.visualstudio.com>.
    - Install the **ElixirLS** extension (search "elixir" in extensions sidebar, install the one with the most installs by JakeBecker).
    - Open the `hello/` directory in VS Code.
    - Mention: alternative editors (vim/neovim with `elixir-tools.nvim`, Zed, Emacs with elixir-mode) all work; pick whichever you're comfortable with.
12. **`## Troubleshooting`** — six common failure modes, each as `### Problem` then `### Fix`:
    - `### `asdf: command not found`` — fix: shell startup file not sourced; close terminal, open new one; verify the source line is in `~/.zshrc` (macOS) or `~/.bashrc` (Linux).
    - `### Erlang build fails with `wxWidgets not found`` — fix: install the wxWidgets package (`brew install wxwidgets` on macOS; `apt install libwxgtk3.0-gtk3-dev` on Debian/Ubuntu). Note: it's OK to skip wxWidgets — Erlang will build without Observer GUI support.
    - `### Erlang build fails with `OpenSSL not found`` — fix: Linux `apt install libssl-dev` / `dnf install openssl-devel`; macOS `brew install openssl@3` and set `KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3)"`.
    - `### Apple Silicon: `bad CPU type in executable`` — fix: run `softwareupdate --install-rosetta --agree-to-license`. Mention this only affects very old asdf plugin scripts; bumping asdf usually fixes it.
    - `### `command not found: elixir` after install` — fix: `asdf reshim`. If still missing, check `asdf current elixir` shows the expected version.
    - `### Slow Erlang build (more than 30 minutes)` — fix: that's normal on first install. The build compiles all of OTP from source. Subsequent installs are cached.
13. **`## What we did, and what's next`** — short closer:
    - Recap: installed Elixir, ran code in iex, created a Mix project, picked an editor.
    - Take a break before lesson 01 — this was a lot.
    - Pointer to lesson 01: `make slides-dev LESSON=01-values-and-types`.

### Step 3: Author `lessons/00-setup/HINTS.md`

Length target: ~400 words.

Structure: three top-level sections (`## When asdf install fails (macOS)`, `## When asdf install fails (Linux)`, `## When IEx won't start`). Each has 3–5 specific symptom→fix pairs (build error from missing OpenSSL, network timeout, "asdf: command not found" already covered in README), formatted as flowcharts (numbered "if X, then Y; if still broken, try Z").

The hints duplicate some content from the README's Troubleshooting section deliberately — the README is sequential reading; HINTS is "I'm stuck, let me look up symptoms."

### Step 4: Author `lessons/00-setup/slides/index.html`

Content: copy from `shared/lesson-template/slides/index.html` and substitute placeholders by hand. Specifically:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <title>Lesson 00: Setup</title>
    <link rel="stylesheet" href="../../../shared/reveal/dist/reset.css" />
    <link rel="stylesheet" href="../../../shared/reveal/dist/reveal.css" />
    <link rel="stylesheet" href="../../../shared/reveal/dist/theme/black.css" />
    <link rel="stylesheet" href="../../../shared/reveal/plugin/highlight/monokai.css" />
  </head>
  <body>
    <div class="reveal">
      <div class="slides">
        <section data-markdown="slides.md" data-separator="^---$" data-separator-vertical="^--$"></section>
      </div>
    </div>
    <script src="../../../shared/reveal/dist/reveal.js"></script>
    <script src="../../../shared/reveal/plugin/notes/notes.js"></script>
    <script src="../../../shared/reveal/plugin/markdown/markdown.js"></script>
    <script src="../../../shared/reveal/plugin/highlight/highlight.js"></script>
    <script>
      Reveal.initialize({
        hash: true,
        plugins: [RevealMarkdown, RevealHighlight, RevealNotes]
      });
    </script>
  </body>
</html>
```

### Step 5: Author `lessons/00-setup/slides/slides.md`

Length target: 12–15 slides. Use `---` between slides, `--` for vertical sub-slides.

Slide-by-slide outline (each `---` = horizontal slide; lines starting `--` are inside-the-stack vertical):

1. **Title.** `# Lesson 00: Setup` / `## Getting Elixir running on your machine`.
2. **What we'll do today.** Three bullets: install Elixir; first program in IEx; first Mix project.
3. **What Elixir is.** Short paragraph: "Elixir is a friendly, fault-tolerant programming language. It runs on the BEAM virtual machine — the same VM that powers WhatsApp, Discord, and a chunk of Pinterest." One image of the BEAM logo or omit if none vendored.
4. **The install plan.** Bullets: asdf (version manager), Erlang/OTP (the VM), Elixir (the language), an editor.
5. **macOS — Homebrew.** Show the install command. `brew install asdf`. Note the shell-config step.
6. **macOS — asdf plugins + install.** Show `asdf plugin add erlang`, `asdf plugin add elixir`, `asdf install`. Note 20+ minutes for first build.
7. **Linux — distro packages + asdf.** Show the `apt`/`dnf`/`pacman` line and the `git clone` for asdf.
8. **Linux — Erlang + Elixir.** Show the same `asdf plugin add` + `asdf install` flow.
9. **Verify.** Show `elixir --version` and the expected output.
10. **First program in iex.** Vertical stack:
    - Parent slide: "Let's run Elixir."
    - `-- ` (vertical) "Open iex." Show `iex` command.
    - `-- ` "Math works." Show `iex> 1 + 1` and output `2`.
    - `-- ` "Print something." Show `iex> IO.puts("Hello, Elixir!")` and output.
    - `-- ` "Exit." Show `Ctrl-C twice`.
11. **First Mix project.** Vertical stack:
    - Parent: "Now let's write a file."
    - `--` "Create the project." Show `mix new hello`.
    - `--` "Look inside." Show the tree.
    - `--` "Run the tests." Show `mix test` and the green output.
12. **Editor: VS Code + ElixirLS.** One bullet for download, one for the extension, one for "alternative editors work too — vim/neovim/Zed/Emacs."
13. **You've written Elixir!** Celebration slide. One sentence: "From here on we build on this." Pointer: "Take a break, then move to lesson 01."

Each concept block uses the heavy-explanatory pattern (motivation → step → expected output → common mistake → recap) only where space permits — the install lesson is more procedural than conceptual, so some blocks have just a single sub-slide.

### Step 6: Smoke-check the slide deck renders

```bash
make slides-dev LESSON=00-setup &
SERVER_PID=$!
sleep 1
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/lessons/00-setup/slides/index.html
kill $SERVER_PID
```

Expected: prints `200`.

### Step 7: Verify the lesson appears as "published" in build_index

```bash
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist
grep -c 'lessons/00-setup/slides/' dist/index.html
rm -rf dist
```

Expected: prints `1`.

### Step 8: Verify CI tools handle the absent exercises/

```bash
tools/run-all-tests
tools/check-solutions
tools/lint-all
```

Expected: each prints "No exercise suites found" / "No solution suites found" / "No Mix projects found" (because no Phase 0 lessons have Mix projects yet — Lesson 01 will be the first), exits 0. The `nullglob` behaviour means the absent `lessons/00-setup/exercises/` doesn't cause an error.

### Step 9: Commit

```bash
git add lessons/00-setup
git commit -m "Add lesson 00-setup: install Elixir, first program, first Mix project

Hand-crafted onboarding lesson for absolute beginners. Covers what
programming is, what Elixir is, asdf-based install paths for macOS and
Linux, a WSL2 pointer for Windows, first IEx session, first Mix
project, VS Code + ElixirLS setup, and six common install
troubleshooting cases.

Deliberately omits exercises/ and solutions/ Mix project — the
'exercise' for this lesson is running code on the learner's machine.
The new-lesson scaffolder is not used; the lesson directory was
created by hand. Confirmed with run-all-tests/check-solutions/lint-all
that the absent dirs do not break CI (nullglob behaviour from Plan A).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

Expected: commit lands on `plan-b-phase-0` with that exact subject and body.

---

## Task 2: Lesson 01 — `values-and-types`

**Files:**
- Create: `lessons/01-values-and-types/` (scaffolded)
- Replace: `lessons/01-values-and-types/README.md`
- Replace: `lessons/01-values-and-types/HINTS.md`
- Replace: `lessons/01-values-and-types/slides/slides.md`
- Create: `lessons/01-values-and-types/exercises/lib/math.ex`
- Create: `lessons/01-values-and-types/exercises/test/math_test.exs`
- Create: `lessons/01-values-and-types/exercises/lib/greet.ex`
- Create: `lessons/01-values-and-types/exercises/test/greet_test.exs`
- Create: `lessons/01-values-and-types/exercises/lib/status.ex`
- Create: `lessons/01-values-and-types/exercises/test/status_test.exs`
- Create: `lessons/01-values-and-types/solutions/lib/math.ex`
- Create: `lessons/01-values-and-types/solutions/test/math_test.exs` (identical to exercises)
- Create: `lessons/01-values-and-types/solutions/lib/greet.ex`
- Create: `lessons/01-values-and-types/solutions/test/greet_test.exs` (identical)
- Create: `lessons/01-values-and-types/solutions/lib/status.ex`
- Create: `lessons/01-values-and-types/solutions/test/status_test.exs` (identical)

### Step 1: Scaffold the lesson

```bash
tools/new-lesson 01-values-and-types
```

Expected: prints `Created lessons/01-values-and-types`. The lesson exists with the template README/HINTS/slides + Mix project skeletons.

### Step 2: Replace the README

`lessons/01-values-and-types/README.md` content outline (length target: 600–900 words):

Sections (each `##`):

1. Top: `# Lesson 01: Values and types`. One-paragraph hook: "By the end of this lesson, you'll be able to name the basic types Elixir works with — integers, floats, atoms, strings — and tell the difference between binding (`x = 1`) and assignment (which Elixir doesn't have)."
2. **Key ideas** — bulleted with one analogy each:
   - **Numbers.** Integers (`1`, `-7`) and floats (`3.14`). Math works as expected. Division `/` always returns a float; `div/2` and `rem/2` exist for integer division.
   - **Booleans.** `true` and `false`. Show how they're really atoms underneath (`:true == true`).
   - **Atoms.** "A named constant — a bookmark with no contents, just the name." `:ok`, `:error`, `:apple`. Same atom anywhere in the program is the same value.
   - **Strings.** "Text in quotes." `"hello"` is a binary; charlists `~c"hello"` exist too but you'll rarely write them. Concatenate with `<>`.
   - **Binding `x = 1`.** "Give the name `x` to the value `1`." This is *not* assignment — we'll see the matching side in lesson 02.
3. **Try it in IEx** — short narrative walkthrough showing five lines of REPL with the formatting convention. Examples: `1 + 1`, `5 / 2` (= `2.5`), `:ok == :ok` (= `true`), `"hi " <> "there"` (= `"hi there"`), `x = 42`.
4. **How to work this lesson:**
   - Read this README.
   - Skim `slides/slides.md` (or `make slides-dev LESSON=01-values-and-types`).
   - Explore in `iex` until the concepts feel familiar.
   - `cd exercises && mix test --include pending` — three failing tests, make them pass.
   - Stuck? Read `HINTS.md` one hint at a time.
   - Compare against `solutions/` only after you have a working answer.
5. **Common mistakes:**
   - Confusing `=` with comparison. `=` binds (or matches, lesson 02); `==` compares.
   - Mixing string concatenation `<>` with the `+` operator (which is numeric only).
   - Thinking `:ok` and `"ok"` are the same thing. They're not — atom vs string.
6. **Going further:**
   - Try `String.upcase/1`, `String.length/1`. Use the IEx `h String.upcase` help.
   - Find an atom-only datum in your own life and explain why a string would be wrong for it.
7. **Links:**
   - [Elixir Getting Started — Basic types](https://hexdocs.pm/elixir/basic-types.html)
   - [HexDocs — String](https://hexdocs.pm/elixir/String.html)
   - [HexDocs — Integer](https://hexdocs.pm/elixir/Integer.html)

### Step 3: Replace the HINTS

`lessons/01-values-and-types/HINTS.md` content outline (length target: ~250 words):

One `## Drill N` section per drill (3 sections), each with three sub-hints (`### Hint 1`, `### Hint 2`, `### Hint 3`) progressively more specific.

Drill 1 (`Math.add/2`):
- Hint 1: "What operator adds two numbers?"
- Hint 2: "The function body just needs `a + b`. Replace the `raise` with that."
- Hint 3: "`def add(a, b), do: a + b`."

Drill 2 (`Greet.hello/1`):
- Hint 1: "Use string concatenation with `<>`."
- Hint 2: "You're building `\"Hello, \" <> name <> \"!\"`."
- Hint 3: "`def hello(name), do: \"Hello, \" <> name <> \"!\"`."

Drill 3 (`Status.ok?/1`):
- Hint 1: "Compare with `==` and the atom `:ok`."
- Hint 2: "The function body is `x == :ok`."
- Hint 3: "`def ok?(x), do: x == :ok`."

### Step 4: Replace the slides

`lessons/01-values-and-types/slides/slides.md` outline (≤ 20 slides, ≤ 4 concept blocks):

Concept blocks:
1. **Numbers** (4 vertical sub-slides): motivation ("computers count, but there are two flavours: integers and floats") → basics (`iex> 1 + 1` / `iex> 1.0 + 1.0`) → worked (`iex> 7 / 2` returns float; `iex> div(7, 2)` returns 3) → common mistake (`5 / 2 == 2.5` not `2`) → recap.
2. **Atoms** (4 sub-slides): motivation ("sometimes you want a name without contents — like the value `:ok`") → basics (`iex> :ok`) → worked (`iex> {:ok, 42}` is a typed result) → common mistake (`:ok` vs `"ok"`) → recap.
3. **Strings** (4 sub-slides): motivation ("text") → basics (`iex> "hello"`) → worked (`iex> "hi " <> "there"`) → common mistake (`"1" + "2"` doesn't work; you need parse or `<>` for text) → recap.
4. **Binding** (4 sub-slides): motivation ("we need to name values") → basics (`iex> x = 42`) → worked (`iex> y = x + 1`) → common mistake (`=` is not assignment — preview lesson 02) → recap.

Closer slide: "Next: lesson 02 — pattern matching. The thing that makes `=` actually interesting."

### Step 5: Drill 1 — `Math.add/2`

Write `lessons/01-values-and-types/exercises/lib/math.ex`:

```elixir
defmodule Math do
  @moduledoc "Tiny arithmetic helpers used in lesson 01."

  @doc """
  Return the sum of two integers.

      iex> Math.add(2, 3)
      5
  """
  def add(_a, _b), do: raise("TODO: implement Math.add/2 — it should return a + b")
end
```

Write `lessons/01-values-and-types/exercises/test/math_test.exs`:

```elixir
defmodule MathTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Math.add/2 sums two positive integers" do
    assert Math.add(2, 3) == 5
  end

  @tag :pending
  test "Math.add/2 handles a negative addend" do
    assert Math.add(-1, 1) == 0
  end

  @tag :pending
  test "Math.add/2 returns 0 for 0 + 0" do
    assert Math.add(0, 0) == 0
  end
end
```

Verify the test fails as expected:

```bash
cd lessons/01-values-and-types/exercises
mix deps.get
mix test --include pending
cd -
```

Expected: three failing tests, each printing `(RuntimeError) TODO: implement Math.add/2 …`.

Write `lessons/01-values-and-types/solutions/lib/math.ex`:

```elixir
defmodule Math do
  @moduledoc "Tiny arithmetic helpers used in lesson 01."

  @doc """
  Return the sum of two integers.

      iex> Math.add(2, 3)
      5
  """
  def add(a, b), do: a + b
end
```

Copy the test file from exercises:

```bash
cp lessons/01-values-and-types/exercises/test/math_test.exs \
   lessons/01-values-and-types/solutions/test/math_test.exs
```

Verify the solution test passes:

```bash
cd lessons/01-values-and-types/solutions
mix deps.get
mix test --include pending
cd -
```

Expected: `3 tests, 0 failures`.

### Step 6: Drill 2 — `Greet.hello/1`

Write `lessons/01-values-and-types/exercises/lib/greet.ex`:

```elixir
defmodule Greet do
  @moduledoc "Greeting helpers used in lesson 01."

  @doc """
  Return a greeting for the given name.

      iex> Greet.hello("Aki")
      "Hello, Aki!"
  """
  def hello(_name), do: raise("TODO: implement Greet.hello/1 — concatenate \"Hello, \", name, and \"!\"")
end
```

Write `lessons/01-values-and-types/exercises/test/greet_test.exs`:

```elixir
defmodule GreetTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Greet.hello/1 greets a single name" do
    assert Greet.hello("Aki") == "Hello, Aki!"
  end

  @tag :pending
  test "Greet.hello/1 greets the empty string" do
    assert Greet.hello("") == "Hello, !"
  end
end
```

Verify the exercise tests fail:

```bash
cd lessons/01-values-and-types/exercises && mix test --include pending; cd -
```

Expected: 2 failing tests from `GreetTest` plus the 3 still-failing `MathTest` ones (Drill 1 is in `solutions/` already but `exercises/` still raises). Actually — Drill 1's exercises module still raises, so `MathTest` in exercises shows 3 failures. Total: 5 failing tests in exercises. Acceptable: we don't fix the exercise drills (that's the learner's job). The point is to confirm `GreetTest` does fail at the `raise` site.

Write `lessons/01-values-and-types/solutions/lib/greet.ex`:

```elixir
defmodule Greet do
  @moduledoc "Greeting helpers used in lesson 01."

  @doc """
  Return a greeting for the given name.

      iex> Greet.hello("Aki")
      "Hello, Aki!"
  """
  def hello(name), do: "Hello, " <> name <> "!"
end
```

Copy the test file:

```bash
cp lessons/01-values-and-types/exercises/test/greet_test.exs \
   lessons/01-values-and-types/solutions/test/greet_test.exs
```

Verify solutions still pass:

```bash
cd lessons/01-values-and-types/solutions && mix test --include pending; cd -
```

Expected: `5 tests, 0 failures` (Math: 3, Greet: 2).

### Step 7: Drill 3 — `Status.ok?/1`

Write `lessons/01-values-and-types/exercises/lib/status.ex`:

```elixir
defmodule Status do
  @moduledoc "Status-tag helpers used in lesson 01."

  @doc """
  Return true if `x` is the atom `:ok`, otherwise false.

      iex> Status.ok?(:ok)
      true
      iex> Status.ok?(:error)
      false
  """
  def ok?(_x), do: raise("TODO: implement Status.ok?/1 — compare x against the atom :ok with ==")
end
```

Write `lessons/01-values-and-types/exercises/test/status_test.exs`:

```elixir
defmodule StatusTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Status.ok?/1 is true for :ok" do
    assert Status.ok?(:ok) == true
  end

  @tag :pending
  test "Status.ok?/1 is false for :error" do
    assert Status.ok?(:error) == false
  end

  @tag :pending
  test "Status.ok?/1 is false for a non-atom" do
    assert Status.ok?("ok") == false
  end
end
```

Write `lessons/01-values-and-types/solutions/lib/status.ex`:

```elixir
defmodule Status do
  @moduledoc "Status-tag helpers used in lesson 01."

  @doc """
  Return true if `x` is the atom `:ok`, otherwise false.

      iex> Status.ok?(:ok)
      true
      iex> Status.ok?(:error)
      false
  """
  def ok?(x), do: x == :ok
end
```

Copy the test file:

```bash
cp lessons/01-values-and-types/exercises/test/status_test.exs \
   lessons/01-values-and-types/solutions/test/status_test.exs
```

Verify all solutions pass:

```bash
cd lessons/01-values-and-types/solutions && mix test --include pending; cd -
```

Expected: `8 tests, 0 failures` (Math 3 + Greet 2 + Status 3).

### Step 8: Lesson-level verification

```bash
tools/check-solutions
```

Expected: prints `=== lessons/01-values-and-types/solutions ===` followed by `8 tests, 0 failures` and `All solutions pass.`

```bash
tools/lint-all
```

Expected: `=== lessons/01-values-and-types/exercises ===` and `=== lessons/01-values-and-types/solutions ===` with formatter check passing; `Lint clean.`

```bash
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist
grep -c 'lessons/01-values-and-types/slides/' dist/index.html
rm -rf dist
```

Expected: prints `1`.

### Step 9: Commit

```bash
git add lessons/01-values-and-types
git commit -m "Add lesson 01-values-and-types: integers, atoms, strings, binding

Three micro-drills: Math.add/2, Greet.hello/1, Status.ok?/1. README
walks through numbers, atoms, strings, and binding (\`x = 1\` reframed
as 'give the name x to the value 1' to set up lesson 02). Slides
follow the heavy-explanatory pattern with four concept blocks (12
sub-slides total, under the cap). HINTS provide three progressive
nudges per drill.

Solutions green: 8 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Lesson 02 — `pattern-matching`

**Files:**
- Create: `lessons/02-pattern-matching/` (scaffolded)
- Replace: `lessons/02-pattern-matching/README.md`, `HINTS.md`, `slides/slides.md`
- Create: drill module + test pairs for `pairs.ex`, `status.ex`, `coords.ex`

### Step 1: Scaffold

```bash
tools/new-lesson 02-pattern-matching
```

### Step 2: Replace the README

Length target: 600–900 words. Sections:

1. `# Lesson 02: Pattern matching`. Hook: "By the end of this lesson, you'll understand why `=` is called *match* and not *assign* — and you'll have started destructuring tuples like a native."
2. **Key ideas:**
   - **`=` is the match operator.** "Imagine the value as a parcel and the left side as a shape on the table. If the parcel fits the shape, the program continues — and any named slots in the shape get filled with the matching parts. If it doesn't fit, the program raises `MatchError`."
   - **Destructuring tuples.** `{a, b} = {1, 2}` binds `a = 1` and `b = 2`. Same for lists: `[h | t] = [1, 2, 3]` gives `h = 1`, `t = [2, 3]`.
   - **The `_` wildcard.** "I don't care about this slot." `{_, second} = {1, 2}` binds only `second`.
   - **Literal matching.** `{:ok, value} = {:ok, 42}` binds `value = 42`. `{:ok, value} = {:error, "nope"}` raises.
   - **Rebinding.** Elixir lets you re-`=` a variable: `x = 1; x = 2` is fine. Erlang doesn't.
3. **Try it in IEx** — REPL transcript showing 5 lines: tuple destructuring, list head-tail, `_` wildcard, literal match success, literal match failure.
4. **How to work this lesson** — same shape as lesson 01.
5. **Common mistakes:**
   - Forgetting that `=` raises on mismatch. `{:ok, v} = {:error, "nope"}` is not a silent failure.
   - Reading `[h | t]` left-to-right as a list literal. It's destructuring: `h` is the head, `t` is the rest.
   - Treating `_` as a real variable. It isn't — you can't read it back.
6. **Going further:**
   - Try matching nested tuples: `{:ok, {x, y}} = {:ok, {1, 2}}`.
   - What does `[a, b, c | rest] = [1, 2, 3, 4, 5]` bind?
7. **Links:**
   - [Elixir Getting Started — Pattern matching](https://hexdocs.pm/elixir/pattern-matching.html)

### Step 3: Replace the HINTS

One `## Drill N` per drill (4 drills). Three sub-hints each. Drill stubs progress: literal destructure (Drill 1) → wildcard (Drill 2) → tagged tuple (Drill 3) → literal pattern (Drill 4).

### Step 4: Replace the slides

≤ 20 slides, 4 concept blocks: `=` as match (4 sub-slides), destructuring (4), wildcards (3), literal matching + rebinding (4). Closer: "Next: lesson 03 — functions and modules, where multiple clauses use these same patterns."

### Step 5: Drill 1 — `Pairs.first/1`

`lessons/02-pattern-matching/exercises/lib/pairs.ex`:

```elixir
defmodule Pairs do
  @moduledoc "Tuple-destructuring drills for lesson 02."

  @doc """
  Return the first element of a two-tuple.

      iex> Pairs.first({1, 2})
      1
  """
  def first(_tuple), do: raise("TODO: implement Pairs.first/1 — use {a, _} = tuple")

  @doc """
  Return the second element of a two-tuple.

      iex> Pairs.second({1, 2})
      2
  """
  def second(_tuple), do: raise("TODO: implement Pairs.second/1 — use {_, b} = tuple")
end
```

`lessons/02-pattern-matching/exercises/test/pairs_test.exs`:

```elixir
defmodule PairsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pairs.first/1 returns the first element" do
    assert Pairs.first({"a", "b"}) == "a"
  end

  @tag :pending
  test "Pairs.first/1 works with integers" do
    assert Pairs.first({1, 2}) == 1
  end

  @tag :pending
  test "Pairs.second/1 returns the second element" do
    assert Pairs.second({"a", "b"}) == "b"
  end

  @tag :pending
  test "Pairs.second/1 works with integers" do
    assert Pairs.second({1, 2}) == 2
  end
end
```

`lessons/02-pattern-matching/solutions/lib/pairs.ex`:

```elixir
defmodule Pairs do
  @moduledoc "Tuple-destructuring drills for lesson 02."

  @doc """
  Return the first element of a two-tuple.

      iex> Pairs.first({1, 2})
      1
  """
  def first({a, _}), do: a

  @doc """
  Return the second element of a two-tuple.

      iex> Pairs.second({1, 2})
      2
  """
  def second({_, b}), do: b
end
```

Copy the test file:

```bash
cp lessons/02-pattern-matching/exercises/test/pairs_test.exs \
   lessons/02-pattern-matching/solutions/test/pairs_test.exs
```

Note: both `Pairs.first/1` and `Pairs.second/1` are bundled in one module/file because they're symmetric and trivially short. This is the only drill where two operations share a module; later drills are one-module-per-drill as the convention says.

### Step 6: Drill 2 — `Status.unwrap/1`

`exercises/lib/status.ex`:

```elixir
defmodule Status do
  @moduledoc "Status-tag pattern drills for lesson 02."

  @doc """
  Return the value from an `{:ok, value}` tuple, or nil for `{:error, _}`.

      iex> Status.unwrap({:ok, 42})
      42
      iex> Status.unwrap({:error, "nope"})
      nil
  """
  def unwrap(_result), do: raise("TODO: implement Status.unwrap/1 — match {:ok, v} and {:error, _}")
end
```

`exercises/test/status_test.exs`:

```elixir
defmodule StatusTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Status.unwrap/1 returns the value from :ok" do
    assert Status.unwrap({:ok, 42}) == 42
  end

  @tag :pending
  test "Status.unwrap/1 returns nil from :error" do
    assert Status.unwrap({:error, "nope"}) == nil
  end

  @tag :pending
  test "Status.unwrap/1 returns the value when it's a string" do
    assert Status.unwrap({:ok, "hi"}) == "hi"
  end
end
```

`solutions/lib/status.ex`:

```elixir
defmodule Status do
  @moduledoc "Status-tag pattern drills for lesson 02."

  @doc """
  Return the value from an `{:ok, value}` tuple, or nil for `{:error, _}`.

      iex> Status.unwrap({:ok, 42})
      42
      iex> Status.unwrap({:error, "nope"})
      nil
  """
  def unwrap({:ok, value}), do: value
  def unwrap({:error, _}), do: nil
end
```

Copy the test file:

```bash
cp lessons/02-pattern-matching/exercises/test/status_test.exs \
   lessons/02-pattern-matching/solutions/test/status_test.exs
```

### Step 7: Drill 3 — `Coords.origin?/1`

`exercises/lib/coords.ex`:

```elixir
defmodule Coords do
  @moduledoc "Coordinate-tuple drills for lesson 02."

  @doc """
  Return true if the coordinate is the origin {0, 0}.

      iex> Coords.origin?({0, 0})
      true
      iex> Coords.origin?({1, 2})
      false
  """
  def origin?(_point), do: raise("TODO: implement Coords.origin?/1 — pattern match {0, 0} in one clause and use a catch-all clause for everything else")
end
```

`exercises/test/coords_test.exs`:

```elixir
defmodule CoordsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Coords.origin?/1 is true for {0, 0}" do
    assert Coords.origin?({0, 0}) == true
  end

  @tag :pending
  test "Coords.origin?/1 is false for {1, 2}" do
    assert Coords.origin?({1, 2}) == false
  end

  @tag :pending
  test "Coords.origin?/1 is false for {0, 1}" do
    assert Coords.origin?({0, 1}) == false
  end
end
```

`solutions/lib/coords.ex`:

```elixir
defmodule Coords do
  @moduledoc "Coordinate-tuple drills for lesson 02."

  @doc """
  Return true if the coordinate is the origin {0, 0}.

      iex> Coords.origin?({0, 0})
      true
      iex> Coords.origin?({1, 2})
      false
  """
  def origin?({0, 0}), do: true
  def origin?(_), do: false
end
```

Copy the test file:

```bash
cp lessons/02-pattern-matching/exercises/test/coords_test.exs \
   lessons/02-pattern-matching/solutions/test/coords_test.exs
```

### Step 8: Verify

```bash
cd lessons/02-pattern-matching/solutions && mix deps.get && mix test --include pending; cd -
```

Expected: `10 tests, 0 failures` (Pairs 4 + Status 3 + Coords 3).

```bash
tools/check-solutions
tools/lint-all
```

Expected: both pass; check-solutions runs both lesson 01 and 02 solutions.

### Step 9: Commit

```bash
git add lessons/02-pattern-matching
git commit -m "Add lesson 02-pattern-matching: = as match, destructuring

Three drills covering tuple destructuring (Pairs.first/1 and
Pairs.second/1 together as a symmetric pair), tagged-tuple
destructuring with multiple function clauses (Status.unwrap/1), and
literal-pattern matching with a catch-all clause (Coords.origin?/1).

README, slides, and HINTS frame = as the match operator with the
'parcel against a shape on the table' analogy. Slides have four
concept blocks under the 20-slide cap.

Solutions green: 10 tests, 0 failures across lessons 01 and 02.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Lesson 03 — `functions-and-modules`

**Files:** scaffolded directory + 5 drill module/test pairs.

Drills: `MyMath.double/1`, `MyMath.area_of_rectangle/2`, `Greeter.hello/1` (multi-clause), `Numbers.classify/1` (guards), `Apply.twice/2` (anonymous function).

### Step 1: Scaffold

```bash
tools/new-lesson 03-functions-and-modules
```

### Step 2: Replace the README

Length target: 800–1000 words (slightly longer than 01/02 because there's more conceptual scaffolding).

Sections:
1. Hook: "By the end of this lesson, you'll write your own modules with named functions, anonymous `fn` expressions, and multiple clauses guarded by type."
2. **Key ideas:**
   - **Modules.** "A folder of related functions." `defmodule MyMath do … end`.
   - **Named functions.** "A recipe with named ingredients (arguments) that produces a result." `def double(x), do: x * 2`. Arity (`double/1` = "the `double` function that takes 1 argument").
   - **Anonymous functions.** `fn x -> x + 1 end`. Called with the dot: `square = fn x -> x * x end; square.(5)` returns `25`. The `&` shorthand: `&(&1 * 2)`.
   - **Multiple clauses.** "Try this clause first; if its pattern doesn't match, try the next one." Same pattern matching from lesson 02, now used in function heads.
   - **Guards.** "An extra `when` check after the pattern." `def classify(n) when n < 0, do: :negative`.
3. **Try it in IEx** — REPL transcript: define `double = fn x -> x * 2 end`, call it; define a quick `defmodule` in iex; call its function.
4. **How to work this lesson** — same.
5. **Common mistakes:**
   - Forgetting the dot when calling an anonymous function. `f(5)` doesn't work; `f.(5)` does.
   - Mixing up clause order. The first matching clause wins; put the most specific clauses first.
   - Confusing `def` (defines in a module) with `fn` (anonymous function expression).
6. **Going further:**
   - Write a `Greeter.hello/2` that takes a name and a greeting, with a default greeting via two clauses.
   - Use the `&` shorthand: `Enum.map([1, 2, 3], &(&1 * 10))`.
7. **Links:**
   - [Elixir Getting Started — Modules and functions](https://hexdocs.pm/elixir/modules-and-functions.html)
   - [HexDocs — Anonymous functions](https://hexdocs.pm/elixir/anonymous-functions.html)

### Step 3: Replace HINTS — one section per drill, three sub-hints each.

### Step 4: Replace slides — 4 concept blocks under cap.

Concept blocks: Modules + named functions (5 sub-slides), Anonymous functions + `&` (4), Multiple clauses (4), Guards (4). Closer: "Next: lesson 04 — control flow, which is mostly pattern matching by another name."

### Step 5: Drill 1 — `MyMath.double/1`

`exercises/lib/my_math.ex`:

```elixir
defmodule MyMath do
  @moduledoc "Tiny math helpers used in lesson 03."

  @doc """
  Return twice the argument.

      iex> MyMath.double(7)
      14
  """
  def double(_x), do: raise("TODO: implement MyMath.double/1 — return x * 2")

  @doc """
  Return the area of a rectangle with width w and height h.

      iex> MyMath.area_of_rectangle(3, 4)
      12
  """
  def area_of_rectangle(_w, _h), do: raise("TODO: implement MyMath.area_of_rectangle/2 — return w * h")
end
```

`exercises/test/my_math_test.exs`:

```elixir
defmodule MyMathTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "MyMath.double/1 doubles a positive integer" do
    assert MyMath.double(7) == 14
  end

  @tag :pending
  test "MyMath.double/1 doubles zero" do
    assert MyMath.double(0) == 0
  end

  @tag :pending
  test "MyMath.area_of_rectangle/2 returns w * h" do
    assert MyMath.area_of_rectangle(3, 4) == 12
  end

  @tag :pending
  test "MyMath.area_of_rectangle/2 returns 0 for a degenerate rectangle" do
    assert MyMath.area_of_rectangle(0, 5) == 0
  end
end
```

`solutions/lib/my_math.ex`:

```elixir
defmodule MyMath do
  @moduledoc "Tiny math helpers used in lesson 03."

  @doc """
  Return twice the argument.

      iex> MyMath.double(7)
      14
  """
  def double(x), do: x * 2

  @doc """
  Return the area of a rectangle with width w and height h.

      iex> MyMath.area_of_rectangle(3, 4)
      12
  """
  def area_of_rectangle(w, h), do: w * h
end
```

Copy test file:

```bash
cp lessons/03-functions-and-modules/exercises/test/my_math_test.exs \
   lessons/03-functions-and-modules/solutions/test/my_math_test.exs
```

(Drills 1 and 2 — `double/1` and `area_of_rectangle/2` — share a module/file because they're both arithmetic helpers and the spec lists them as 1 and 2; one file is cleaner than two near-identical tiny modules.)

### Step 6: Drill 3 — `Greeter.hello/1` (multi-clause)

`exercises/lib/greeter.ex`:

```elixir
defmodule Greeter do
  @moduledoc "Multi-clause greeting drill for lesson 03."

  @doc """
  Return a greeting. If the name is "world", greet "world" specially.

      iex> Greeter.hello("world")
      "Hello, world!"
      iex> Greeter.hello("Aki")
      "Hello, Aki!"
  """
  def hello(_name), do: raise("TODO: implement Greeter.hello/1 with two function clauses — one matching the literal \"world\", another matching any name")
end
```

`exercises/test/greeter_test.exs`:

```elixir
defmodule GreeterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Greeter.hello/1 matches the literal \"world\"" do
    assert Greeter.hello("world") == "Hello, world!"
  end

  @tag :pending
  test "Greeter.hello/1 falls through to a generic greeting" do
    assert Greeter.hello("Aki") == "Hello, Aki!"
  end
end
```

`solutions/lib/greeter.ex`:

```elixir
defmodule Greeter do
  @moduledoc "Multi-clause greeting drill for lesson 03."

  @doc """
  Return a greeting. If the name is "world", greet "world" specially.

      iex> Greeter.hello("world")
      "Hello, world!"
      iex> Greeter.hello("Aki")
      "Hello, Aki!"
  """
  def hello("world"), do: "Hello, world!"
  def hello(name), do: "Hello, " <> name <> "!"
end
```

Copy test file as before.

### Step 7: Drill 4 — `Numbers.classify/1` (guards)

`exercises/lib/numbers.ex`:

```elixir
defmodule Numbers do
  @moduledoc "Guarded classification drill for lesson 03."

  @doc """
  Classify a number as :negative, :zero, or :positive.

      iex> Numbers.classify(-3)
      :negative
      iex> Numbers.classify(0)
      :zero
      iex> Numbers.classify(7)
      :positive
  """
  def classify(_n), do: raise("TODO: implement Numbers.classify/1 with three clauses using `when` guards")
end
```

`exercises/test/numbers_test.exs`:

```elixir
defmodule NumbersTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Numbers.classify/1 returns :negative for negative integers" do
    assert Numbers.classify(-3) == :negative
  end

  @tag :pending
  test "Numbers.classify/1 returns :zero for 0" do
    assert Numbers.classify(0) == :zero
  end

  @tag :pending
  test "Numbers.classify/1 returns :positive for positive integers" do
    assert Numbers.classify(7) == :positive
  end

  @tag :pending
  test "Numbers.classify/1 handles negative floats" do
    assert Numbers.classify(-0.5) == :negative
  end
end
```

`solutions/lib/numbers.ex`:

```elixir
defmodule Numbers do
  @moduledoc "Guarded classification drill for lesson 03."

  @doc """
  Classify a number as :negative, :zero, or :positive.

      iex> Numbers.classify(-3)
      :negative
      iex> Numbers.classify(0)
      :zero
      iex> Numbers.classify(7)
      :positive
  """
  def classify(n) when n < 0, do: :negative
  def classify(0), do: :zero
  def classify(n) when n > 0, do: :positive
end
```

Copy test file.

### Step 8: Drill 5 — `Apply.twice/2` (anonymous function)

`exercises/lib/apply_helper.ex`:

```elixir
defmodule ApplyHelper do
  @moduledoc "Higher-order drill for lesson 03 — applies a function twice."

  @doc """
  Call `f` on `x`, then call `f` on the result.

      iex> ApplyHelper.twice(fn x -> x + 1 end, 0)
      2
      iex> ApplyHelper.twice(&(&1 * 2), 3)
      12
  """
  def twice(_f, _x), do: raise("TODO: implement ApplyHelper.twice/2 — call f on x, then call f on the result. Anonymous functions are invoked with the dot: f.(x)")
end
```

(Module renamed from `Apply` to `ApplyHelper` to avoid colliding with Erlang's `apply` BIF on some toolchains — pragmatic safety.)

`exercises/test/apply_helper_test.exs`:

```elixir
defmodule ApplyHelperTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "ApplyHelper.twice/2 calls f twice with the increment function" do
    assert ApplyHelper.twice(fn x -> x + 1 end, 0) == 2
  end

  @tag :pending
  test "ApplyHelper.twice/2 works with the & shorthand" do
    assert ApplyHelper.twice(&(&1 * 2), 3) == 12
  end

  @tag :pending
  test "ApplyHelper.twice/2 with identity returns the input" do
    assert ApplyHelper.twice(fn x -> x end, 42) == 42
  end
end
```

`solutions/lib/apply_helper.ex`:

```elixir
defmodule ApplyHelper do
  @moduledoc "Higher-order drill for lesson 03 — applies a function twice."

  @doc """
  Call `f` on `x`, then call `f` on the result.

      iex> ApplyHelper.twice(fn x -> x + 1 end, 0)
      2
      iex> ApplyHelper.twice(&(&1 * 2), 3)
      12
  """
  def twice(f, x), do: f.(f.(x))
end
```

Copy test file.

### Step 9: Verify + commit

```bash
cd lessons/03-functions-and-modules/solutions && mix deps.get && mix test --include pending; cd -
```

Expected: `13 tests, 0 failures` (MyMath 4 + Greeter 2 + Numbers 4 + ApplyHelper 3).

```bash
tools/check-solutions
tools/lint-all
```

Expected: both pass.

```bash
git add lessons/03-functions-and-modules
git commit -m "Add lesson 03-functions-and-modules: def, fn, clauses, guards

Five drills: MyMath.double/1 and area_of_rectangle/2 (basic def),
Greeter.hello/1 (multi-clause with literal-string pattern),
Numbers.classify/1 (three clauses with when guards), and
ApplyHelper.twice/2 (higher-order anonymous-function passing).

README frames modules as 'folders of related functions' and multiple
clauses as 'try this first; fall through if the pattern doesn't
match'. Slides have four concept blocks (modules+def, fn+&, multiple
clauses, guards) under the 20-slide cap.

Note: the Apply module from the spec is implemented as ApplyHelper
to avoid colliding with Erlang's apply/3 BIF on some toolchains.

Solutions green: 13 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Lesson 04 — `control-flow`

**Files:** scaffolded directory + 5 drill module/test pairs.

Drills: `Sign.of/1`, `Traffic.action/1`, `Account.status/1`, `Steps.run/1`, `Pick.first_match/2`.

### Step 1: Scaffold

```bash
tools/new-lesson 04-control-flow
```

### Step 2: README

Length target: 700–900 words.

Hook: "By the end of this lesson, you'll use `case`, `cond`, and `with` to write branching code — and you'll see that they're all forms of pattern matching."

Key ideas:
- **`case`** = inline multiple clauses. Same shape as a function head's clauses.
- **`cond`** = "first truthy condition wins." Use when you can't easily pattern-match (e.g., chained `if/elif`).
- **`with`** = chains of `{:ok, _}` steps that short-circuit on the first `{:error, _}`.
- **`if`/`unless`** = mentioned, de-emphasised — they're sugar over `case` and rarely the right tool in idiomatic Elixir.

REPL transcript, common mistakes (`cond` with no truthy clause raises; missing the last catch-all in `case` is a runtime trap), going further, links.

### Step 3: HINTS — 5 sections, 3 sub-hints each.

### Step 4: Slides — 4 concept blocks under cap: `case` (5 sub), `cond` (4), `with` (4), wrap-up (3 — "all three are just pattern matching"). Closer: "Phase 0 done. Lesson 05 — recursion — next."

### Step 5: Drill 1 — `Sign.of/1`

`exercises/lib/sign.ex`:

```elixir
defmodule Sign do
  @moduledoc "Sign-classification drill for lesson 04 — using cond."

  @doc """
  Classify a number's sign using cond.

      iex> Sign.of(-3)
      :negative
      iex> Sign.of(0)
      :zero
      iex> Sign.of(7)
      :positive
  """
  def of(_n), do: raise("TODO: implement Sign.of/1 using a `cond` expression with three branches")
end
```

`exercises/test/sign_test.exs`:

```elixir
defmodule SignTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Sign.of/1 returns :negative for negative numbers" do
    assert Sign.of(-3) == :negative
  end

  @tag :pending
  test "Sign.of/1 returns :zero for 0" do
    assert Sign.of(0) == :zero
  end

  @tag :pending
  test "Sign.of/1 returns :positive for positive numbers" do
    assert Sign.of(7) == :positive
  end
end
```

`solutions/lib/sign.ex`:

```elixir
defmodule Sign do
  @moduledoc "Sign-classification drill for lesson 04 — using cond."

  @doc """
  Classify a number's sign using cond.

      iex> Sign.of(-3)
      :negative
      iex> Sign.of(0)
      :zero
      iex> Sign.of(7)
      :positive
  """
  def of(n) do
    cond do
      n < 0 -> :negative
      n == 0 -> :zero
      true -> :positive
    end
  end
end
```

Copy test file.

### Step 6: Drill 2 — `Traffic.action/1`

`exercises/lib/traffic.ex`:

```elixir
defmodule Traffic do
  @moduledoc "Traffic-light case drill for lesson 04."

  @doc """
  Return the action for a traffic-light atom.

      iex> Traffic.action(:red)
      "stop"
      iex> Traffic.action(:green)
      "go"
  """
  def action(_light), do: raise("TODO: implement Traffic.action/1 using a `case` expression matching :red, :yellow, :green")
end
```

`exercises/test/traffic_test.exs`:

```elixir
defmodule TrafficTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Traffic.action/1 returns 'stop' for :red" do
    assert Traffic.action(:red) == "stop"
  end

  @tag :pending
  test "Traffic.action/1 returns 'slow' for :yellow" do
    assert Traffic.action(:yellow) == "slow"
  end

  @tag :pending
  test "Traffic.action/1 returns 'go' for :green" do
    assert Traffic.action(:green) == "go"
  end
end
```

`solutions/lib/traffic.ex`:

```elixir
defmodule Traffic do
  @moduledoc "Traffic-light case drill for lesson 04."

  @doc """
  Return the action for a traffic-light atom.

      iex> Traffic.action(:red)
      "stop"
      iex> Traffic.action(:green)
      "go"
  """
  def action(light) do
    case light do
      :red -> "stop"
      :yellow -> "slow"
      :green -> "go"
    end
  end
end
```

### Step 7: Drill 3 — `Account.status/1`

`exercises/lib/account.ex`:

```elixir
defmodule Account do
  @moduledoc "Tagged-tuple case drill with guards for lesson 04."

  @doc """
  Map an account result to a status atom.

      iex> Account.status({:ok, 100})
      :open
      iex> Account.status({:ok, 0})
      :empty
      iex> Account.status({:error, :closed})
      :closed
  """
  def status(_result), do: raise("TODO: implement Account.status/1 using `case` matching {:ok, balance} when balance > 0, {:ok, 0}, and {:error, _}")
end
```

`exercises/test/account_test.exs`:

```elixir
defmodule AccountTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Account.status/1 returns :open for {:ok, positive balance}" do
    assert Account.status({:ok, 100}) == :open
  end

  @tag :pending
  test "Account.status/1 returns :empty for {:ok, 0}" do
    assert Account.status({:ok, 0}) == :empty
  end

  @tag :pending
  test "Account.status/1 returns :closed for any {:error, _}" do
    assert Account.status({:error, :closed}) == :closed
    assert Account.status({:error, "frozen"}) == :closed
  end
end
```

`solutions/lib/account.ex`:

```elixir
defmodule Account do
  @moduledoc "Tagged-tuple case drill with guards for lesson 04."

  @doc """
  Map an account result to a status atom.

      iex> Account.status({:ok, 100})
      :open
      iex> Account.status({:ok, 0})
      :empty
      iex> Account.status({:error, :closed})
      :closed
  """
  def status(result) do
    case result do
      {:ok, balance} when balance > 0 -> :open
      {:ok, 0} -> :empty
      {:error, _} -> :closed
    end
  end
end
```

### Step 8: Drill 4 — `Steps.run/1`

`exercises/lib/steps.ex`:

```elixir
defmodule Steps do
  @moduledoc "with-chain drill for lesson 04."

  @doc """
  Run three steps in sequence with `with`. Each step takes the input
  and returns either {:ok, transformed} or {:error, reason}. If all
  three succeed, return {:ok, final_value}. The first failure
  short-circuits and is returned as-is.

      iex> Steps.run(1)
      {:ok, 16}
      iex> Steps.run(:fail_at_2)
      {:error, :step2_failed}
  """
  def run(_input), do: raise("TODO: implement Steps.run/1 using `with` chaining step1/1, step2/1, step3/1")

  @doc false
  def step1(:fail_at_1), do: {:error, :step1_failed}
  def step1(x), do: {:ok, x + 1}

  @doc false
  def step2(:fail_at_2), do: {:error, :step2_failed}
  def step2(x), do: {:ok, x * 2}

  @doc false
  def step3(:fail_at_3), do: {:error, :step3_failed}
  def step3(x), do: {:ok, x * x}
end
```

`exercises/test/steps_test.exs`:

```elixir
defmodule StepsTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Steps.run/1 returns the final value when all steps succeed" do
    # step1: 1 + 1 = 2
    # step2: 2 * 2 = 4
    # step3: 4 * 4 = 16
    assert Steps.run(1) == {:ok, 16}
  end

  @tag :pending
  test "Steps.run/1 short-circuits at step 2" do
    assert Steps.run(:fail_at_2) == {:error, :step2_failed}
  end

  @tag :pending
  test "Steps.run/1 short-circuits at step 1" do
    assert Steps.run(:fail_at_1) == {:error, :step1_failed}
  end
end
```

`solutions/lib/steps.ex`:

```elixir
defmodule Steps do
  @moduledoc "with-chain drill for lesson 04."

  @doc """
  Run three steps in sequence with `with`. Each step takes the input
  and returns either {:ok, transformed} or {:error, reason}. If all
  three succeed, return {:ok, final_value}. The first failure
  short-circuits and is returned as-is.

      iex> Steps.run(1)
      {:ok, 16}
      iex> Steps.run(:fail_at_2)
      {:error, :step2_failed}
  """
  def run(input) do
    with {:ok, a} <- step1(input),
         {:ok, b} <- step2(a),
         {:ok, c} <- step3(b) do
      {:ok, c}
    end
  end

  @doc false
  def step1(:fail_at_1), do: {:error, :step1_failed}
  def step1(x), do: {:ok, x + 1}

  @doc false
  def step2(:fail_at_2), do: {:error, :step2_failed}
  def step2(x), do: {:ok, x * 2}

  @doc false
  def step3(:fail_at_3), do: {:error, :step3_failed}
  def step3(x), do: {:ok, x * x}
end
```

(Helpers `step1/1`/`step2/1`/`step3/1` are included in both files so the test can call them, and so the failing-input atoms (`:fail_at_2` etc.) actually trigger the wired-in failure cases.)

### Step 9: Drill 5 — `Pick.first_match/2`

`exercises/lib/pick.ex`:

```elixir
defmodule Pick do
  @moduledoc "First-match drill for lesson 04 — combining anonymous functions with case."

  @doc """
  Return the first element of `list` for which `pred.(element)` is true.
  If no element matches, return nil.

      iex> Pick.first_match([1, 2, 3, 4], &(&1 > 2))
      3
      iex> Pick.first_match([1, 2, 3], &(&1 > 99))
      nil
  """
  def first_match(_list, _pred), do: raise("TODO: implement Pick.first_match/2 — iterate the list and return the first element where pred.(elem) is true; if none, return nil")
end
```

`exercises/test/pick_test.exs`:

```elixir
defmodule PickTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Pick.first_match/2 returns the first matching element" do
    assert Pick.first_match([1, 2, 3, 4], &(&1 > 2)) == 3
  end

  @tag :pending
  test "Pick.first_match/2 returns nil when no element matches" do
    assert Pick.first_match([1, 2, 3], &(&1 > 99)) == nil
  end

  @tag :pending
  test "Pick.first_match/2 returns nil for an empty list" do
    assert Pick.first_match([], fn _ -> true end) == nil
  end

  @tag :pending
  test "Pick.first_match/2 works with anonymous fn form too" do
    assert Pick.first_match([1, 2, 3], fn x -> x == 2 end) == 2
  end
end
```

`solutions/lib/pick.ex`:

```elixir
defmodule Pick do
  @moduledoc "First-match drill for lesson 04 — combining anonymous functions with case."

  @doc """
  Return the first element of `list` for which `pred.(element)` is true.
  If no element matches, return nil.

      iex> Pick.first_match([1, 2, 3, 4], &(&1 > 2))
      3
      iex> Pick.first_match([1, 2, 3], &(&1 > 99))
      nil
  """
  def first_match([], _pred), do: nil

  def first_match([head | tail], pred) do
    case pred.(head) do
      true -> head
      false -> first_match(tail, pred)
    end
  end
end
```

(This drill is the bridge to lesson 05 — it already uses head-tail recursion. The lesson 05 README will call it out: "remember `Pick.first_match/2` from lesson 04? That was your first recursion.")

Copy all five test files into `solutions/test/`.

### Step 10: Verify + commit

```bash
cd lessons/04-control-flow/solutions && mix deps.get && mix test --include pending; cd -
```

Expected: `16 tests, 0 failures` (Sign 3 + Traffic 3 + Account 4 + Steps 3 + Pick 4 — wait, that's 17; recount: Sign 3, Traffic 3, Account 4 (3 cases × the last test asserts twice but counts as 1 test), Steps 3, Pick 4 = 17 actually. Let me re-tally: Sign 3, Traffic 3, Account 3 (3 test functions), Steps 3, Pick 4 = 16. OK 16 it is — confirm at run time.)

```bash
tools/check-solutions
tools/lint-all
```

Both pass.

```bash
git add lessons/04-control-flow
git commit -m "Add lesson 04-control-flow: case, cond, with — pattern matching by another name

Five drills: Sign.of/1 (cond), Traffic.action/1 (case on atoms),
Account.status/1 (case with guards on tagged tuples), Steps.run/1
(with chain that short-circuits on first :error), and
Pick.first_match/2 (head-tail recursion bridging into lesson 05).

README reframes if/else as a special case of case; case as inline
function clauses; cond as 'first truthy wins'; with as 'chain of
ok-or-fail steps'. Slides cap at four concept blocks. The final
recap slide closes Phase 0 and points to lesson 05.

Solutions green: 16 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Final smoke + PR

### Step 1: Run the full pipeline

```bash
make ci-smoke
make solutions-test
make lint
make slides-build
```

Expected: all four succeed. `make slides-build` writes `dist/` with `dist/index.html` containing `Elixir Training`.

### Step 2: Confirm all 5 Phase 0 lessons are "published" in dist

```bash
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules 04-control-flow; do
  grep -q "lessons/$n/slides/" dist/index.html && echo "$n: published" || echo "$n: MISSING"
done
```

Expected: all five print `published`.

### Step 3: Confirm test counts

```bash
tools/check-solutions 2>&1 | grep -E '^\d+ tests' || \
  for n in 01-values-and-types 02-pattern-matching 03-functions-and-modules 04-control-flow; do
    echo "=== $n ==="
    cd "lessons/$n/solutions" && mix test --include pending | tail -3; cd -
  done
```

Expected lesson-by-lesson: 01 = 8, 02 = 10, 03 = 13, 04 = 16 (or thereabouts; recount during run if needed). Total: ~47 tests across Phase 0.

### Step 4: Clean up dist before commit (it's gitignored, but sanity check)

```bash
rm -rf dist
git status
```

Expected: no untracked files (dist is gitignored). Working tree clean.

### Step 5: Push the branch

```bash
git push -u origin plan-b-phase-0
```

### Step 6: Open a PR

```bash
gh pr create --base main --head plan-b-phase-0 \
    --title "Plan B: Phase 0 lessons (00 setup through 04 control flow)" \
    --body "$(cat <<'EOF'
## Summary
- Implements [Plan B](docs/superpowers/plans/2026-05-22-plan-b-phase-0-lessons.md) — the five Phase 0 lessons of the course.
- Lesson 00 (setup) is the hand-crafted onboarding lesson: terminal/install/IEx/first Mix project, no exercises Mix project.
- Lessons 01–04 each use the standard template with 3–5 micro-drills.
- After this PR merges, the landing page at https://elixir.ristkari.dev/ lights up the Phase 0 row.

## Test plan
- [ ] CI workflow turns green (lint, exercises, solutions, slides-build, dist verification).
- [ ] ``make slides-build && open dist/index.html`` shows lessons 00–04 as published.
- [ ] A complete-beginner walkthrough on macOS following only lesson 00's README ends with ``mix test`` green.

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

If the user approves the PR, squash-merge it (matches the Plan A pattern):

```bash
gh pr merge --squash --delete-branch
```

This triggers the Deploy workflow, which redeploys https://elixir.ristkari.dev/ with the Phase 0 row lit up.

---

## Self-review checklist (already applied while writing)

**Spec coverage:**
- Per-lesson shape (Section 1 of spec) → enforced in every lesson task's file map and step ordering.
- Lesson 00 deviation (Section 2) → Task 1, with explicit no-exercises/no-solutions structure and the CI tools verification step.
- Lessons 01–04 concept breakdown (Section 3) → one task per lesson with the exact drill modules + tests + solutions named in the spec.
- Authoring conventions (Section 4): REPL transcript formatting → enforced in README "Try it in IEx" sections and slide concept blocks; beginner asides → not directly required in this plan but available for the writer to use; exercise file layout → one drill = one `.ex` file (with the documented exceptions of `Pairs` and `MyMath` where two symmetric ops share a file).
- Definition of done → Task 6 enforces.
- Risks → not fixed in plan; the risk list stays in the spec.
- Non-goals (no Windows-native, no playground, no video) → respected — lesson 00 has only the WSL2 pointer.

**Placeholders:**
- No "TBD" / "implement later" / "fill in" markers.
- README/HINTS/slides are detailed outlines for prose (section order, content per section, length targets) — this is acceptable for content authoring tasks; the implementer fills in the words within the structure.
- Code (drill stubs, tests, solutions) is exact.

**Type consistency:**
- Module names across exercises/solutions match byte-for-byte (`Math`, `Greet`, `Status`, `Pairs`, `Coords`, `MyMath`, `Greeter`, `Numbers`, `ApplyHelper`, `Sign`, `Traffic`, `Account`, `Steps`, `Pick`).
- Function signatures match between exercise stubs, test calls, and solution implementations.
- Test file names match their module file names (`math.ex` → `math_test.exs`, `apply_helper.ex` → `apply_helper_test.exs`).
- The `ApplyHelper` rename (from spec's `Apply`) is called out in Task 4's commit message so the divergence from spec is explicit.
