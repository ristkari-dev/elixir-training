# Plan A — Repo Foundations & Authoring Harness

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the repository scaffolding, dev tooling, slide harness, and CI so that future lesson-authoring plans (B–H) have a fully working substrate. When this plan is done, `make new-lesson NAME=99-demo` produces a valid lesson skeleton whose `exercises/` and `solutions/` Mix projects compile, `make slides-dev LESSON=99-demo` serves slides on `http://localhost:8000`, and CI is green on an empty `lessons/` tree.

**Architecture:** A repo-root Makefile drives small POSIX-bash scripts under `tools/` that do the actual work. A `shared/lesson-template/` directory is the canonical lesson skeleton, copied and string-substituted by `tools/new-lesson`. `shared/reveal/` holds a vendored reveal.js 5.1.0. Each lesson's `exercises/` and `solutions/` are independent Mix projects — no umbrella. CI runs on GitHub Actions with `erlef/setup-beam@v1` reading the pinned Elixir/OTP versions from `.tool-versions`.

**Tech Stack:** Elixir 1.18.2, Erlang/OTP 27.2 (pinned via `asdf`), reveal.js 5.1.0 (vendored), Python 3 `http.server` (slide serving), POSIX bash (tooling), GitHub Actions (CI), Docker + docker-compose (Postgres for later lessons, defined but unused in Plan A).

**Pre-flight:** This plan is executed from the repo root `/Users/ristkari/code/private/elixir-training/`. The repo already contains `README.md` (Go-flavored, to be replaced) and `docs/superpowers/specs/2026-05-21-elixir-course-design.md`. Git is initialized.

---

## File map

Files this plan creates or modifies (full inventory):

| Path | Purpose | Task |
|---|---|---|
| `README.md` | replace Go-flavored content with Elixir-flavored | 12 |
| `.gitignore` | ignore Mix build artifacts, deps, OS junk | 1 |
| `.tool-versions` | pin Elixir + Erlang/OTP for asdf | 1 |
| `.formatter.exs` | shared formatter rules referenced by every lesson | 1 |
| `.credo.exs` | shared Credo config (active from lesson 34 onward) | 1 |
| `docker-compose.yml` | Postgres + pgAdmin for DB-needing lessons | 2 |
| `Makefile` | repo-root entry points | 10 |
| `tools/new-lesson` | scaffold a lesson from `shared/lesson-template/` | 6 |
| `tools/slides-dev` | serve one lesson's slides on localhost | 7 |
| `tools/run-all-tests` | walk `lessons/`, run `mix test`, aggregate | 8 |
| `tools/check-solutions` | assert every `solutions/` project passes | 8 |
| `tools/lint-all` | formatter check + Credo across all Mix projects | 9 |
| `tools/test-harness` | bash test runner that exercises the tools above | 5 |
| `shared/reveal/` | vendored reveal.js 5.1.0 distribution | 3 |
| `shared/lesson-template/README.md` | lesson README scaffold with placeholders | 4 |
| `shared/lesson-template/HINTS.md` | lesson HINTS scaffold | 4 |
| `shared/lesson-template/slides/index.html` | reveal.js entry point referencing shared/reveal | 4 |
| `shared/lesson-template/slides/slides.md` | placeholder lesson slide content | 4 |
| `shared/lesson-template/exercises/mix.exs` | Mix project template with placeholders | 4 |
| `shared/lesson-template/exercises/lib/.gitkeep` | preserve empty lib dir | 4 |
| `shared/lesson-template/exercises/test/test_helper.exs` | ExUnit start | 4 |
| `shared/lesson-template/exercises/.formatter.exs` | imports `../../../.formatter.exs` | 4 |
| `shared/lesson-template/solutions/mix.exs` | mirror of exercises template | 4 |
| `shared/lesson-template/solutions/lib/.gitkeep` | preserve empty lib dir | 4 |
| `shared/lesson-template/solutions/test/test_helper.exs` | ExUnit start | 4 |
| `shared/lesson-template/solutions/.formatter.exs` | imports `../../../.formatter.exs` | 4 |
| `.github/workflows/ci.yml` | run harness smoke tests + lint on push/PR | 11 |

Naming conventions locked in by this plan:

- Lesson directory: `lessons/NN-slug-with-dashes/` where `NN` is two digits and `slug` is kebab-case.
- Mix project app name: `:lesson_NN_slug_with_underscores` (atom, snake_case).
- Mix project module name: `LessonNN_SlugWithCamelCase` for the default `lib/lesson_NN_slug.ex` — but the template ships **without** that default module file. Lessons add their own modules (e.g., `Sum`, `MyEnum`) directly under `lib/`.
- Phase 3+ lessons (the threaded `Tracker` app) do *not* use `tools/new-lesson`; they are bootstrapped from the previous lesson's `solutions/`. That tool is out of scope for Plan A.

---

## Task 1: Repo-root config files (`.gitignore`, `.tool-versions`, `.formatter.exs`, `.credo.exs`)

**Files:**
- Create: `.gitignore`
- Create: `.tool-versions`
- Create: `.formatter.exs`
- Create: `.credo.exs`

- [ ] **Step 1: Create `.gitignore`**

```
# Mix
/lessons/**/_build/
/lessons/**/deps/
/lessons/**/cover/
/lessons/**/doc/
/lessons/**/.fetch
/lessons/**/erl_crash.dump
/lessons/**/*.ez
/lessons/**/*.beam
/lessons/**/.elixir_ls/

# Phoenix
/lessons/**/priv/static/assets/
/lessons/**/priv/static/cache_manifest.json
/lessons/**/.phx.gen.priv/
/lessons/**/node_modules/

# Postgres data (docker-compose volume)
/.postgres-data/

# OS
.DS_Store
Thumbs.db

# Editors
.vscode/
.idea/
*.swp
*.swo
```

- [ ] **Step 2: Create `.tool-versions`**

```
elixir 1.18.2-otp-27
erlang 27.2
```

(Engineer note: if `asdf` complains the version is unavailable when scaffolding, bump to the latest patch release of Elixir 1.18 and OTP 27. Do not switch major versions without updating the spec.)

- [ ] **Step 3: Create `.formatter.exs`**

```elixir
# Shared formatter config for every lesson's Mix project.
# Lesson formatter files do `import_deps: [:phoenix, :phoenix_live_view]` etc.
# as needed and `import_config "../../../.formatter.exs"` to inherit these.

[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 98,
  locals_without_parens: []
]
```

- [ ] **Step 4: Create `.credo.exs`**

```elixir
# Shared Credo config. Activated by lessons from lesson 34 onward.
%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "test/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      strict: false,
      checks: %{
        enabled: [
          {Credo.Check.Readability.ModuleDoc, false},
          {Credo.Check.Design.TagTODO, false}
        ]
      }
    }
  ]
}
```

- [ ] **Step 5: Verify the formatter file is syntactically valid Elixir**

Run:
```bash
elixir -e 'IO.inspect(Code.eval_file(".formatter.exs"))'
```

Expected: prints a tuple `{[inputs: [...], line_length: 98, locals_without_parens: []], []}` and exits zero. If `elixir` is not installed on this machine, install asdf + the versions pinned in `.tool-versions` first.

- [ ] **Step 6: Verify the credo config file is syntactically valid Elixir**

Run:
```bash
elixir -e 'IO.inspect(Code.eval_file(".credo.exs"))'
```

Expected: prints the config map and exits zero.

- [ ] **Step 7: Commit**

```bash
git add .gitignore .tool-versions .formatter.exs .credo.exs
git commit -m "Add repo-root config: gitignore, tool-versions, formatter, credo"
```

---

## Task 2: Postgres via docker-compose

**Files:**
- Create: `docker-compose.yml`

- [ ] **Step 1: Create `docker-compose.yml`**

```yaml
# Postgres for any lesson that needs a DB.
# Lessons that depend on this start at lesson 26 (phx.gen.auth).
# Usage: docker compose up -d postgres

services:
  postgres:
    image: postgres:16-alpine
    container_name: elixir_training_postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
    ports:
      - "5432:5432"
    volumes:
      - ./.postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
```

- [ ] **Step 2: Validate the compose file syntax**

Run:
```bash
docker compose -f docker-compose.yml config >/dev/null && echo OK
```

Expected: prints `OK`. If `docker` is unavailable on this machine, skip — CI will catch syntax errors.

- [ ] **Step 3: Commit**

```bash
git add docker-compose.yml
git commit -m "Add docker-compose Postgres service for DB-needing lessons"
```

---

## Task 3: Vendor reveal.js 5.1.0 under `shared/reveal/`

**Files:**
- Create: `shared/reveal/` (multiple files from the reveal.js distribution)
- Create: `shared/reveal/README.md` (provenance and update instructions)

- [ ] **Step 1: Download the reveal.js 5.1.0 tarball**

Run:
```bash
curl -L -o /tmp/revealjs-5.1.0.tar.gz https://github.com/hakimel/reveal.js/archive/refs/tags/5.1.0.tar.gz
```

Expected: a `~5MB` tarball at `/tmp/revealjs-5.1.0.tar.gz`. Verify with `tar -tzf /tmp/revealjs-5.1.0.tar.gz | head` — should list `reveal.js-5.1.0/...` entries.

- [ ] **Step 2: Extract the runtime files we vendor**

We only ship the runtime distribution, not the build tooling or demo content.

```bash
mkdir -p shared/reveal
tar -xzf /tmp/revealjs-5.1.0.tar.gz -C /tmp
cp -r /tmp/reveal.js-5.1.0/dist shared/reveal/dist
cp -r /tmp/reveal.js-5.1.0/plugin shared/reveal/plugin
cp /tmp/reveal.js-5.1.0/LICENSE shared/reveal/LICENSE
rm -rf /tmp/reveal.js-5.1.0 /tmp/revealjs-5.1.0.tar.gz
```

- [ ] **Step 3: Add provenance README**

Create `shared/reveal/README.md`:

```markdown
# Vendored reveal.js

reveal.js 5.1.0 — https://github.com/hakimel/reveal.js/releases/tag/5.1.0

This directory is **vendored** and should not be hand-edited. To update,
re-download the tarball at the new version and replace `dist/` and
`plugin/` with the new ones. Update this README's version line.

License: MIT (see `LICENSE`).
```

- [ ] **Step 4: Sanity-check the vendored files exist**

Run:
```bash
test -f shared/reveal/dist/reveal.js && \
  test -f shared/reveal/dist/reveal.css && \
  test -d shared/reveal/plugin/markdown && \
  echo OK
```

Expected: prints `OK`.

- [ ] **Step 5: Commit**

```bash
git add shared/reveal
git commit -m "Vendor reveal.js 5.1.0 under shared/reveal"
```

---

## Task 4: `shared/lesson-template/` skeleton

**Files:**
- Create: `shared/lesson-template/README.md`
- Create: `shared/lesson-template/HINTS.md`
- Create: `shared/lesson-template/slides/index.html`
- Create: `shared/lesson-template/slides/slides.md`
- Create: `shared/lesson-template/exercises/mix.exs`
- Create: `shared/lesson-template/exercises/.formatter.exs`
- Create: `shared/lesson-template/exercises/test/test_helper.exs`
- Create: `shared/lesson-template/exercises/lib/.gitkeep`
- Create: `shared/lesson-template/solutions/mix.exs`
- Create: `shared/lesson-template/solutions/.formatter.exs`
- Create: `shared/lesson-template/solutions/test/test_helper.exs`
- Create: `shared/lesson-template/solutions/lib/.gitkeep`

Placeholder tokens used by `tools/new-lesson` (Task 6):

- `{{LESSON_NUMBER}}` — two-digit number, e.g. `05`
- `{{LESSON_SLUG_DASH}}` — kebab-case slug, e.g. `recursion`
- `{{LESSON_SLUG_UNDER}}` — snake_case slug, e.g. `recursion`
- `{{LESSON_TITLE}}` — human-readable title, e.g. `Recursion`
- `{{MIX_APP_NAME}}` — `lesson_NN_slug` atom, e.g. `lesson_05_recursion`

- [ ] **Step 1: Create lesson README template**

`shared/lesson-template/README.md`:

```markdown
# Lesson {{LESSON_NUMBER}}: {{LESSON_TITLE}}

## What you should be able to do

After this lesson you should be able to:

- (objective 1 — fill in)
- (objective 2 — fill in)
- (objective 3 — fill in)

## Key ideas

(short paragraph or two — fill in)

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON={{LESSON_NUMBER}}-{{LESSON_SLUG_DASH}}` to view).
3. Open `exercises/` and run `mix test --include pending`. Make the tests pass.
4. Stuck? Read `HINTS.md` one hint at a time.
5. Compare against `solutions/` only after you have a working answer.

## Links

- (canonical docs, blog posts, HexDocs links)
```

- [ ] **Step 2: Create HINTS template**

`shared/lesson-template/HINTS.md`:

```markdown
# Hints for Lesson {{LESSON_NUMBER}}: {{LESSON_TITLE}}

Read these one at a time. Try the exercise after each hint before reading the next.

## Hint 1

(gentle nudge — fill in)

## Hint 2

(slightly more specific — fill in)

## Hint 3

(close-to-the-answer — fill in)
```

- [ ] **Step 3: Create slides index.html**

`shared/lesson-template/slides/index.html`:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <title>Lesson {{LESSON_NUMBER}}: {{LESSON_TITLE}}</title>
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

- [ ] **Step 4: Create placeholder slides.md**

`shared/lesson-template/slides/slides.md`:

```markdown
# Lesson {{LESSON_NUMBER}}: {{LESSON_TITLE}}

(intro — replace this slide)

---

## Why this matters

(motivation slide — replace)

---

## Key idea 1

(explanation — replace)

---

## Wrap-up

- (recap point 1)
- (recap point 2)
```

- [ ] **Step 5: Create `exercises/mix.exs` template**

`shared/lesson-template/exercises/mix.exs`:

```elixir
defmodule {{MIX_APP_NAME_CAMEL}}.MixProject do
  use Mix.Project

  def project do
    [
      app: :{{MIX_APP_NAME}},
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
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

(`{{MIX_APP_NAME_CAMEL}}` is computed by `tools/new-lesson` from `{{MIX_APP_NAME}}` — e.g. `lesson_05_recursion` → `Lesson05Recursion`.)

- [ ] **Step 6: Create `exercises/.formatter.exs`**

`shared/lesson-template/exercises/.formatter.exs`:

```elixir
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
```

(Each lesson has its own minimal formatter file. The repo-root `.formatter.exs` is the source of truth for style; lesson files mirror its rules. Engineers can extend per-lesson if a lesson needs e.g. `import_deps: [:phoenix]`.)

- [ ] **Step 7: Create `exercises/test/test_helper.exs`**

`shared/lesson-template/exercises/test/test_helper.exs`:

```elixir
ExUnit.start(exclude: [pending: true])
```

(Sets the default behavior: `mix test` skips `@tag :pending` tests. Learners override with `mix test --include pending` to see what's expected of them.)

- [ ] **Step 8: Create `exercises/lib/.gitkeep`**

```bash
touch shared/lesson-template/exercises/lib/.gitkeep
```

- [ ] **Step 9: Mirror the same four files under `solutions/`**

`shared/lesson-template/solutions/mix.exs` — identical to exercises/mix.exs (same `{{MIX_APP_NAME}}`).

`shared/lesson-template/solutions/.formatter.exs` — identical content.

`shared/lesson-template/solutions/test/test_helper.exs`:

```elixir
ExUnit.start()
```

(Solutions don't carry `@tag :pending` tests — all tests should pass.)

```bash
touch shared/lesson-template/solutions/lib/.gitkeep
```

- [ ] **Step 10: Commit**

```bash
git add shared/lesson-template
git commit -m "Add shared/lesson-template scaffold with placeholders"
```

---

## Task 5: `tools/test-harness` — bash test runner

The test harness is the substrate for TDD'ing the rest of the tools. It runs each tool in a temp space, asserts on output, and reports pass/fail. We write the harness first so subsequent tool tasks can follow a real red-green cycle.

**Files:**
- Create: `tools/test-harness`

- [ ] **Step 1: Create `tools/test-harness`**

```bash
#!/usr/bin/env bash
# tools/test-harness — runs all harness self-tests.
# Each test is a bash function prefixed `test_`. Functions are auto-discovered.
# A test fails by returning non-zero. Use `fail "message"` to fail explicitly.
#
# Usage:
#   tools/test-harness            # run all tests
#   tools/test-harness test_name  # run one test

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

PASS=0
FAIL=0
FAILED_TESTS=()

fail() {
  echo "  FAIL: $*" >&2
  return 1
}

assert_file() {
  [[ -f "$1" ]] || fail "expected file: $1"
}

assert_dir() {
  [[ -d "$1" ]] || fail "expected dir: $1"
}

assert_grep() {
  local pattern="$1"
  local file="$2"
  grep -q "$pattern" "$file" || fail "expected to find '$pattern' in $file"
}

run_test() {
  local name="$1"
  printf '%s ... ' "$name"
  if (set -e; "$name") 2>/tmp/test-harness.err; then
    echo "ok"
    PASS=$((PASS + 1))
  else
    echo "FAILED"
    if [[ -s /tmp/test-harness.err ]]; then
      sed 's/^/    /' /tmp/test-harness.err
    fi
    FAIL=$((FAIL + 1))
    FAILED_TESTS+=("$name")
  fi
}

# Auto-discover tests defined as `test_*` functions in this file
discover_tests() {
  grep -oE '^test_[a-zA-Z0-9_]+' "$0" | sort -u
}

main() {
  if [[ $# -gt 0 ]]; then
    for name in "$@"; do run_test "$name"; done
  else
    while read -r name; do run_test "$name"; done < <(discover_tests)
  fi
  echo
  echo "Passed: $PASS, Failed: $FAIL"
  if (( FAIL > 0 )); then
    echo "Failed tests: ${FAILED_TESTS[*]}"
    exit 1
  fi
}

# ---------- Tests below this line ----------

test_harness_is_runnable() {
  # Sanity: the harness itself loads.
  true
}

main "$@"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x tools/test-harness
```

- [ ] **Step 3: Run it to verify the self-test passes**

```bash
tools/test-harness
```

Expected output:
```
test_harness_is_runnable ... ok

Passed: 1, Failed: 0
```

- [ ] **Step 4: Commit**

```bash
git add tools/test-harness
git commit -m "Add tools/test-harness bash test runner"
```

---

## Task 6: `tools/new-lesson` script

**Files:**
- Create: `tools/new-lesson`
- Modify: `tools/test-harness` (add tests at the bottom)

- [ ] **Step 1: Write failing tests in `tools/test-harness`**

Append (immediately before the `main "$@"` call) the following tests:

```bash
test_new_lesson_creates_directory() {
  local name="99-harness-smoke"
  rm -rf "lessons/$name"
  tools/new-lesson "$name" >/dev/null
  assert_dir "lessons/$name"
  assert_file "lessons/$name/README.md"
  assert_file "lessons/$name/HINTS.md"
  assert_file "lessons/$name/slides/index.html"
  assert_file "lessons/$name/slides/slides.md"
  assert_file "lessons/$name/exercises/mix.exs"
  assert_file "lessons/$name/solutions/mix.exs"
  rm -rf "lessons/$name"
}

test_new_lesson_substitutes_placeholders() {
  local name="99-harness-smoke"
  rm -rf "lessons/$name"
  tools/new-lesson "$name" >/dev/null
  assert_grep "Lesson 99: Harness Smoke" "lessons/$name/README.md"
  assert_grep "app: :lesson_99_harness_smoke" "lessons/$name/exercises/mix.exs"
  assert_grep "Lesson99HarnessSmoke.MixProject" "lessons/$name/exercises/mix.exs"
  ! grep -q "{{" "lessons/$name/README.md" || fail "unsubstituted placeholder in README"
  ! grep -q "{{" "lessons/$name/exercises/mix.exs" || fail "unsubstituted placeholder in exercises/mix.exs"
  ! grep -q "{{" "lessons/$name/slides/index.html" || fail "unsubstituted placeholder in slides/index.html"
  rm -rf "lessons/$name"
}

test_new_lesson_rejects_bad_names() {
  if tools/new-lesson "BadName" 2>/dev/null; then
    fail "expected non-zero exit for non-conforming name"
  fi
  if tools/new-lesson "1-only-one-digit" 2>/dev/null; then
    fail "expected non-zero exit for single-digit lesson number"
  fi
}

test_new_lesson_refuses_to_overwrite() {
  local name="99-harness-smoke"
  rm -rf "lessons/$name"
  tools/new-lesson "$name" >/dev/null
  if tools/new-lesson "$name" 2>/dev/null; then
    fail "expected non-zero exit when lesson directory already exists"
  fi
  rm -rf "lessons/$name"
}
```

- [ ] **Step 2: Run the harness — tests should fail**

```bash
tools/test-harness
```

Expected: four new tests fail (script does not yet exist). Output contains `Passed: 1, Failed: 4`.

- [ ] **Step 3: Create `tools/new-lesson`**

```bash
#!/usr/bin/env bash
# tools/new-lesson — scaffold a new lesson from shared/lesson-template/
#
# Usage:
#   tools/new-lesson NN-slug-with-dashes
#
# Example:
#   tools/new-lesson 05-recursion

set -euo pipefail

usage() {
  cat >&2 <<EOF
Usage: tools/new-lesson NN-slug-with-dashes

NN must be two digits. slug must be lowercase kebab-case (letters, digits, dashes).

Example: tools/new-lesson 05-recursion
EOF
  exit 1
}

[[ $# -eq 1 ]] || usage

NAME="$1"

# Validate format: NN-slug-with-dashes (NN = two digits)
if [[ ! "$NAME" =~ ^[0-9]{2}-[a-z][a-z0-9-]*$ ]]; then
  echo "ERROR: lesson name must match NN-slug-with-dashes (two digits, kebab-case slug)" >&2
  usage
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE_DIR="$REPO_ROOT/shared/lesson-template"
DEST_DIR="$REPO_ROOT/lessons/$NAME"

if [[ -e "$DEST_DIR" ]]; then
  echo "ERROR: $DEST_DIR already exists" >&2
  exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "ERROR: template directory missing: $TEMPLATE_DIR" >&2
  exit 1
fi

# Derive placeholder values
LESSON_NUMBER="${NAME%%-*}"                   # "05"
LESSON_SLUG_DASH="${NAME#*-}"                 # "recursion" or "pattern-matching"
LESSON_SLUG_UNDER="${LESSON_SLUG_DASH//-/_}"  # "pattern_matching"
MIX_APP_NAME="lesson_${LESSON_NUMBER}_${LESSON_SLUG_UNDER}"

# Title-case the slug: "pattern-matching" -> "Pattern Matching"
LESSON_TITLE=$(echo "$LESSON_SLUG_DASH" | awk -F'-' '{
  for (i = 1; i <= NF; i++) {
    $i = toupper(substr($i, 1, 1)) substr($i, 2)
  }
  print
}' OFS=' ')

# CamelCase the mix app name: "lesson_05_pattern_matching" -> "Lesson05PatternMatching"
MIX_APP_NAME_CAMEL=$(echo "$MIX_APP_NAME" | awk -F'_' '{
  out = ""
  for (i = 1; i <= NF; i++) {
    out = out toupper(substr($i, 1, 1)) substr($i, 2)
  }
  print out
}')

mkdir -p "$DEST_DIR"
cp -R "$TEMPLATE_DIR/." "$DEST_DIR/"

# Substitute placeholders in every text file under the new lesson
find "$DEST_DIR" -type f \( -name "*.md" -o -name "*.html" -o -name "*.exs" -o -name ".formatter.exs" \) -print0 \
  | while IFS= read -r -d '' f; do
    # Use a temp file to stay portable across BSD/GNU sed
    sed \
      -e "s/{{LESSON_NUMBER}}/$LESSON_NUMBER/g" \
      -e "s/{{LESSON_SLUG_DASH}}/$LESSON_SLUG_DASH/g" \
      -e "s/{{LESSON_SLUG_UNDER}}/$LESSON_SLUG_UNDER/g" \
      -e "s/{{LESSON_TITLE}}/$LESSON_TITLE/g" \
      -e "s/{{MIX_APP_NAME}}/$MIX_APP_NAME/g" \
      -e "s/{{MIX_APP_NAME_CAMEL}}/$MIX_APP_NAME_CAMEL/g" \
      "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
  done

echo "Created lessons/$NAME"
```

- [ ] **Step 4: Make it executable**

```bash
chmod +x tools/new-lesson
```

- [ ] **Step 5: Run the harness — tests should pass**

```bash
tools/test-harness
```

Expected: all five tests pass. Output ends with `Passed: 5, Failed: 0`.

- [ ] **Step 6: Smoke test — scaffold one lesson and compile it**

```bash
tools/new-lesson 99-smoke && \
  cd lessons/99-smoke/exercises && mix deps.get && mix compile && cd "$OLDPWD" && \
  cd lessons/99-smoke/solutions && mix deps.get && mix compile && cd "$OLDPWD" && \
  rm -rf lessons/99-smoke
```

Expected: both `mix compile` runs succeed with no warnings.

- [ ] **Step 7: Commit**

```bash
git add tools/new-lesson tools/test-harness
git commit -m "Add tools/new-lesson scaffold script with harness tests"
```

---

## Task 7: `tools/slides-dev` script

**Files:**
- Create: `tools/slides-dev`
- Modify: `tools/test-harness` (add a test)

- [ ] **Step 1: Add a failing test to `tools/test-harness`** (just before `main "$@"`)

```bash
test_slides_dev_rejects_missing_lesson() {
  if tools/slides-dev "99-does-not-exist" 2>/dev/null; then
    fail "expected non-zero exit when lesson dir missing"
  fi
}

test_slides_dev_rejects_no_arg() {
  if tools/slides-dev 2>/dev/null; then
    fail "expected non-zero exit when no lesson name given"
  fi
}
```

- [ ] **Step 2: Run harness — new tests fail**

```bash
tools/test-harness
```

Expected: two new tests fail.

- [ ] **Step 3: Create `tools/slides-dev`**

```bash
#!/usr/bin/env bash
# tools/slides-dev — serve a lesson's slide deck on http://localhost:8000
#
# Usage:
#   tools/slides-dev NN-slug
#
# Stops with Ctrl-C.

set -euo pipefail

usage() {
  echo "Usage: tools/slides-dev NN-slug" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage

NAME="$1"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LESSON_DIR="$REPO_ROOT/lessons/$NAME"

if [[ ! -d "$LESSON_DIR" ]]; then
  echo "ERROR: lesson directory not found: lessons/$NAME" >&2
  exit 1
fi

if [[ ! -f "$LESSON_DIR/slides/index.html" ]]; then
  echo "ERROR: lesson is missing slides/index.html: lessons/$NAME" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required to serve slides. Install Python 3 and retry." >&2
  exit 1
fi

echo "Serving slides for lessons/$NAME on http://localhost:8000/lessons/$NAME/slides/"
echo "Stop with Ctrl-C."
cd "$REPO_ROOT"
exec python3 -m http.server 8000
```

- [ ] **Step 4: Make it executable**

```bash
chmod +x tools/slides-dev
```

- [ ] **Step 5: Run the harness — all tests pass**

```bash
tools/test-harness
```

Expected: all tests pass.

- [ ] **Step 6: Manual smoke test (optional but recommended)**

```bash
tools/new-lesson 99-smoke
tools/slides-dev 99-smoke &
SERVER_PID=$!
sleep 1
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8000/lessons/99-smoke/slides/index.html
kill $SERVER_PID
rm -rf lessons/99-smoke
```

Expected: prints `200`.

- [ ] **Step 7: Commit**

```bash
git add tools/slides-dev tools/test-harness
git commit -m "Add tools/slides-dev to serve a lesson's slides locally"
```

---

## Task 8: `tools/run-all-tests` and `tools/check-solutions`

These two share most of their logic — they walk `lessons/*/` and run `mix test` in either `exercises/` (excluding `@tag :pending`) or `solutions/` (all tests). `tools/check-solutions` exits non-zero if any solution fails.

**Files:**
- Create: `tools/run-all-tests`
- Create: `tools/check-solutions`
- Modify: `tools/test-harness` (add tests)

- [ ] **Step 1: Add failing tests to `tools/test-harness`**

```bash
test_run_all_tests_passes_with_empty_lessons() {
  # With no lessons present (or only the smoke lesson with no tests),
  # run-all-tests must succeed cleanly.
  local name="99-harness-smoke"
  rm -rf "lessons/$name"
  tools/new-lesson "$name" >/dev/null
  tools/run-all-tests >/tmp/run-all.out 2>&1 || {
    cat /tmp/run-all.out >&2
    rm -rf "lessons/$name"
    fail "tools/run-all-tests failed on empty lesson"
  }
  rm -rf "lessons/$name"
}

test_check_solutions_passes_with_empty_solutions() {
  local name="99-harness-smoke"
  rm -rf "lessons/$name"
  tools/new-lesson "$name" >/dev/null
  tools/check-solutions >/tmp/check-sol.out 2>&1 || {
    cat /tmp/check-sol.out >&2
    rm -rf "lessons/$name"
    fail "tools/check-solutions failed on empty solutions"
  }
  rm -rf "lessons/$name"
}

test_check_solutions_fails_on_broken_solution() {
  local name="99-harness-broken"
  rm -rf "lessons/$name"
  tools/new-lesson "$name" >/dev/null
  # Inject a broken test into the solution
  cat > "lessons/$name/solutions/test/broken_test.exs" <<'EOF'
defmodule BrokenTest do
  use ExUnit.Case
  test "intentionally fails" do
    assert 1 == 2
  end
end
EOF
  if tools/check-solutions >/tmp/check-sol-broken.out 2>&1; then
    rm -rf "lessons/$name"
    fail "tools/check-solutions should have failed on a broken solution"
  fi
  rm -rf "lessons/$name"
}
```

- [ ] **Step 2: Run harness — new tests fail**

```bash
tools/test-harness
```

Expected: three new tests fail.

- [ ] **Step 3: Create `tools/run-all-tests`**

```bash
#!/usr/bin/env bash
# tools/run-all-tests — run `mix test` in every lessons/NN-slug/exercises/.
# Exits non-zero if any lesson's tests error out (compile failures, etc.).
# Note: this DOES NOT include @tag :pending tests, which are deliberately
# failing in `exercises/`. Use `mix test --include pending` inside a single
# lesson to see those.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0
for dir in lessons/*/exercises; do
  [[ -d "$dir" ]] || continue
  [[ -f "$dir/mix.exs" ]] || continue
  echo "=== $dir ==="
  if ! ( cd "$dir" && mix deps.get && mix test ); then
    echo "FAILED: $dir" >&2
    FAIL=1
  fi
done

if (( FAIL == 1 )); then
  echo "One or more lesson exercise suites failed."
  exit 1
fi

echo "All exercise suites passed (excluding @tag :pending)."
```

- [ ] **Step 4: Create `tools/check-solutions`**

```bash
#!/usr/bin/env bash
# tools/check-solutions — run `mix test` in every lessons/NN-slug/solutions/.
# Solutions MUST pass with zero failures (no @tag :pending exclusion).
# This is the CI safety net that catches solution rot.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0
for dir in lessons/*/solutions; do
  [[ -d "$dir" ]] || continue
  [[ -f "$dir/mix.exs" ]] || continue
  echo "=== $dir ==="
  if ! ( cd "$dir" && mix deps.get && mix test --include pending ); then
    echo "FAILED: $dir" >&2
    FAIL=1
  fi
done

if (( FAIL == 1 )); then
  echo "One or more solutions failed. Solutions must be green."
  exit 1
fi

echo "All solutions pass."
```

- [ ] **Step 5: Make both scripts executable**

```bash
chmod +x tools/run-all-tests tools/check-solutions
```

- [ ] **Step 6: Run the harness — all tests pass**

```bash
tools/test-harness
```

Expected: all tests pass.

- [ ] **Step 7: Commit**

```bash
git add tools/run-all-tests tools/check-solutions tools/test-harness
git commit -m "Add tools/run-all-tests and tools/check-solutions with harness tests"
```

---

## Task 9: `tools/lint-all` script

**Files:**
- Create: `tools/lint-all`
- Modify: `tools/test-harness` (add a test)

- [ ] **Step 1: Add a failing test to `tools/test-harness`**

```bash
test_lint_all_passes_on_template_output() {
  local name="99-harness-smoke"
  rm -rf "lessons/$name"
  tools/new-lesson "$name" >/dev/null
  tools/lint-all >/tmp/lint.out 2>&1 || {
    cat /tmp/lint.out >&2
    rm -rf "lessons/$name"
    fail "tools/lint-all failed on freshly scaffolded lesson"
  }
  rm -rf "lessons/$name"
}
```

- [ ] **Step 2: Run harness — test fails**

```bash
tools/test-harness
```

Expected: one new test fails.

- [ ] **Step 3: Create `tools/lint-all`**

```bash
#!/usr/bin/env bash
# tools/lint-all — formatter check (mix format --check-formatted) across every
# Mix project under lessons/, plus Credo on projects that have it as a dep.
#
# Credo is opt-in per lesson — a lesson activates it by adding {:credo, ...}
# to its mix.exs deps. This script runs `mix credo` only if the dep resolves.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

FAIL=0
for dir in lessons/*/{exercises,solutions}; do
  [[ -d "$dir" ]] || continue
  [[ -f "$dir/mix.exs" ]] || continue
  echo "=== $dir ==="

  if ! ( cd "$dir" && mix deps.get && mix format --check-formatted ); then
    echo "FAILED format check: $dir" >&2
    FAIL=1
  fi

  # Run Credo only if the dep is declared
  if grep -q ":credo," "$dir/mix.exs"; then
    if ! ( cd "$dir" && mix credo --strict ); then
      echo "FAILED credo: $dir" >&2
      FAIL=1
    fi
  fi
done

if (( FAIL == 1 )); then
  echo "Lint failures present."
  exit 1
fi

echo "Lint clean."
```

- [ ] **Step 4: Make it executable**

```bash
chmod +x tools/lint-all
```

- [ ] **Step 5: Run the harness — all tests pass**

```bash
tools/test-harness
```

Expected: all tests pass.

- [ ] **Step 6: Commit**

```bash
git add tools/lint-all tools/test-harness
git commit -m "Add tools/lint-all to run formatter + credo across lessons"
```

---

## Task 10: Repo-root `Makefile`

**Files:**
- Create: `Makefile`

- [ ] **Step 1: Create `Makefile`**

```makefile
# Repo-root Makefile.
# All targets shell out to scripts under tools/ — keep logic out of Make.

.PHONY: help new-lesson slides-dev test test-lesson solutions-test lint ci-smoke

# Default target: print help
.DEFAULT_GOAL := help

help: ## Print this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

new-lesson: ## Scaffold a new lesson: make new-lesson NAME=NN-slug
	@if [ -z "$(NAME)" ]; then echo "Usage: make new-lesson NAME=NN-slug"; exit 1; fi
	@tools/new-lesson $(NAME)

slides-dev: ## Serve a lesson's slides: make slides-dev LESSON=NN-slug
	@if [ -z "$(LESSON)" ]; then echo "Usage: make slides-dev LESSON=NN-slug"; exit 1; fi
	@tools/slides-dev $(LESSON)

test: ## Run mix test in every lesson's exercises/ (skips @tag :pending)
	@tools/run-all-tests

test-lesson: ## Run mix test for one lesson: make test-lesson LESSON=NN-slug
	@if [ -z "$(LESSON)" ]; then echo "Usage: make test-lesson LESSON=NN-slug"; exit 1; fi
	@cd lessons/$(LESSON)/exercises && mix deps.get && mix test

solutions-test: ## Run mix test in every lesson's solutions/ (must all pass)
	@tools/check-solutions

lint: ## Run mix format --check-formatted (+ credo where declared) across lessons
	@tools/lint-all

ci-smoke: ## End-to-end harness smoke: scaffold a lesson, compile it, lint, tear down
	@tools/test-harness
```

- [ ] **Step 2: Verify `make help` lists every target**

Run:
```bash
make help
```

Expected output (order may vary):
```
  help                 Print this help
  new-lesson           Scaffold a new lesson: make new-lesson NAME=NN-slug
  slides-dev           Serve a lesson's slides: make slides-dev LESSON=NN-slug
  test                 Run mix test in every lesson's exercises/ (skips @tag :pending)
  test-lesson          Run mix test for one lesson: make test-lesson LESSON=NN-slug
  solutions-test       Run mix test in every lesson's solutions/ (must all pass)
  lint                 Run mix format --check-formatted (+ credo where declared) across lessons
  ci-smoke             End-to-end harness smoke: scaffold a lesson, compile it, lint, tear down
```

- [ ] **Step 3: Verify `make ci-smoke` exits zero**

```bash
make ci-smoke
```

Expected: harness output ends with `Passed: N, Failed: 0` and exit code 0.

- [ ] **Step 4: Commit**

```bash
git add Makefile
git commit -m "Add repo-root Makefile delegating to tools/* scripts"
```

---

## Task 11: GitHub Actions CI

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create the CI workflow**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  harness-smoke:
    name: Harness smoke
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: erlef/setup-beam@v1
        with:
          version-file: .tool-versions
          version-type: strict

      - name: Cache Mix deps for harness smoke lesson
        uses: actions/cache@v4
        with:
          path: |
            ~/.hex
            ~/.mix
          key: ${{ runner.os }}-mix-${{ hashFiles('.tool-versions') }}
          restore-keys: ${{ runner.os }}-mix-

      - name: Run harness self-tests
        run: tools/test-harness

  solutions-and-lint:
    name: Solutions + lint
    runs-on: ubuntu-latest
    needs: harness-smoke
    steps:
      - uses: actions/checkout@v4

      - uses: erlef/setup-beam@v1
        with:
          version-file: .tool-versions
          version-type: strict

      - name: Cache Mix deps
        uses: actions/cache@v4
        with:
          path: |
            ~/.hex
            ~/.mix
            lessons/**/deps
            lessons/**/_build
          key: ${{ runner.os }}-mix-${{ hashFiles('.tool-versions', 'lessons/**/mix.lock') }}
          restore-keys: ${{ runner.os }}-mix-

      - name: Run all solutions (must pass)
        run: make solutions-test

      - name: Lint
        run: make lint
```

- [ ] **Step 2: Validate YAML syntax**

```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" && echo OK
```

Expected: prints `OK`.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "Add GitHub Actions CI: harness smoke + solutions + lint"
```

---

## Task 12: Replace top-level `README.md`

**Files:**
- Modify: `README.md` (replace Go-flavored content with Elixir-flavored)

- [ ] **Step 1: Overwrite `README.md`**

```markdown
# Elixir Training

A self-study-friendly Elixir programming course delivered as code +
per-lesson reveal.js slide decks. The arc starts at programming-101 and
finishes with the learner deploying a small Phoenix web app to production.

## Prerequisites

- `asdf` with the `erlang` and `elixir` plugins. The pinned versions live in
  `.tool-versions` — run `asdf install` from the repo root.
- Docker (for Postgres from lesson 26 onward and for the release lesson).
- Python 3 (used by the slide server).
- Make.

## Quick start

```bash
asdf install                       # install pinned Elixir + OTP
make help                          # list every available command
make new-lesson NAME=99-demo       # scaffold a sandbox lesson
make slides-dev LESSON=99-demo     # serve its deck on http://localhost:8000
make test                          # run all lesson exercises (skips @tag :pending)
make solutions-test                # run all lesson solutions (must all pass)
make lint                          # mix format --check + credo where declared
```

## Repository layout

```
lessons/NN-name/
├── README.md       self-study notes: objectives, key ideas, links
├── HINTS.md        progressively-revealed hints (beginner safety rail)
├── slides/         reveal.js deck (index.html + slides.md)
├── exercises/      starter Mix project + failing tests (the spec)
└── solutions/      reference Mix project + the same tests, passing

shared/reveal/            vendored reveal.js 5.1.0 (do not hand-edit)
shared/lesson-template/   scaffold copied by `make new-lesson`
tools/                    dev scripts the Makefile invokes
docs/superpowers/specs/   course design specs
docs/superpowers/plans/   implementation plans
```

## Design

See [`docs/superpowers/specs/2026-05-21-elixir-course-design.md`](docs/superpowers/specs/2026-05-21-elixir-course-design.md)
for the full course design.
```

- [ ] **Step 2: Verify it renders sensibly**

```bash
head -30 README.md
```

Expected: the Elixir-flavored README, not the old Go content. Sanity-check there's no "Go Training" string left.

```bash
! grep -q "Go Training" README.md && ! grep -q "golangci-lint" README.md && echo OK
```

Expected: prints `OK`.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "Replace Go-flavored README with Elixir course README"
```

---

## Final smoke run

After Task 12, run the full smoke end-to-end:

```bash
make ci-smoke && \
  make new-lesson NAME=99-final-smoke && \
  make test-lesson LESSON=99-final-smoke && \
  make solutions-test && \
  make lint && \
  rm -rf lessons/99-final-smoke && \
  echo "ALL GREEN"
```

Expected: prints `ALL GREEN` at the end.

---

## Self-review checklist (already applied while writing this plan)

- **Spec coverage:** All Section 4 (Tooling) and Section 5 (Repository layout) items in the spec map to tasks: `.tool-versions` (T1), `.formatter.exs` (T1), `.credo.exs` (T1), `docker-compose.yml` (T2), Makefile targets (T10), `tools/new-lesson` (T6), `tools/slides-dev` (T7), `tools/run-all-tests` (T8), `tools/check-solutions` (T8), `tools/lint-all` (T9), `shared/reveal/` (T3), `shared/lesson-template/` (T4), `.github/workflows/ci.yml` (T11), updated `README.md` (T12). Out of scope for Plan A (handled in later plans): actual lesson content, Phase 3+ threaded-app scaffold, slide style guide.
- **Placeholders:** None. Every step has actual content or an exact command.
- **Type consistency:** Placeholder tokens (`{{LESSON_NUMBER}}` etc.) are defined once in Task 4 and reused identically in Task 6's `tools/new-lesson` substitution map.
