# Contributing

## Authoring a new lesson

```bash
make new-lesson NAME=05-recursion
```

This creates `lessons/05-recursion/` with the four-part structure: `README.md`,
`HINTS.md`, `slides/`, `exercises/`, `solutions/`. The scaffolded files
have `TODO`-style placeholders — fill them in.

### The four-part structure

Every lesson has exactly these parts:

1. **`README.md`** — self-study notes that mirror the deck narrative.
   Sections: "What you should be able to do" (objectives), "Key ideas",
   "How to work this lesson", "Links".
2. **`HINTS.md`** — progressively-revealed nudges. Three hints by default
   (gentle → specific → close-to-the-answer). Students read them one at
   a time when stuck.
3. **`slides/`** — the live-lecture deck. `index.html` is the reveal.js
   bootstrap; `slides.md` is the markdown content. Use `Note:` blocks
   for speaker notes.
4. **`exercises/`** — starter Mix project that **compiles** but is
   incomplete. Stub function bodies with `raise "TODO: implement this"`
   or `raise "not implemented"`. The accompanying `test/*_test.exs`
   files contain failing tests that act as the spec.
5. **`solutions/`** — the same Mix project shape as `exercises/`, fully
   implemented. The tests in `solutions/test/` must be the same tests as
   in `exercises/test/` so `mix test --include pending` passes in
   `solutions/`.

### Tests as the spec

Exercise tests carry `@tag :pending` and are skipped by `mix test` by
default (the lesson's `test/test_helper.exs` has
`ExUnit.start(exclude: [pending: true])`). Students run
`mix test --include pending` to see what the exercise is asking for.

Solutions remove the `:pending` exclusion (`ExUnit.start()`) and **must
all pass**. `make solutions-test` enforces this in CI.

### Slide style

- First slide: lesson number, title, one-line learning goal.
- Last slide: pointer to the next lesson.
- Code-heavy slides: limit to ~15 visible lines. Split larger examples
  and use the highlight plugin's `[highlight]` syntax to focus
  attention.
- Diagrams: SVG. Never images of code.
- **Code goes "down."** When a sub-slide has both explanatory prose and
  a code block, split them into a vertical stack with `--`. The prose
  is the parent slide; the code is the child below it. Students press
  Right to move between concepts; Down to drill into code. Reveal.js
  shows a navigation arrow at the bottom-right when there's more below.

### Heavy-explanatory slide pattern (Phase 0 lessons)

Phase 0 (Programming-101) lessons follow a textbook-flavoured pattern:

1. **Motivation** — why the concept exists, what problem it solves.
2. **The basics** — a minimal code example.
3. **A worked example** — substantive use in context.
4. **Common mistake** — what NOT to do, plus the error Elixir surfaces.
5. **Recap** — a bullet list of takeaways.

Expand or contract per lesson as the course progresses past Phase 0.

### Dependency policy by phase

The elixir-training course tightens what each lesson is allowed to
pull in:

- **Phase 0–1 (lessons 00–12)** — Elixir stdlib only. `mix.exs` lists
  `:excoveralls` as the sole dep (for coverage reporting from lesson 34
  onward; harmless to carry from the start).
- **Phase 2 (lessons 13–20)** — still stdlib + `:excoveralls`. OTP
  primitives (GenServer, Supervisor, Task, Agent, ETS, distribution)
  are all in stdlib.
- **Phase 3+ (lessons 21+)** — third-party Hex deps enter as the lesson
  teaches them: `phoenix`, `phoenix_live_view`, `ecto_sql`, `postgrex`,
  `phoenix_html`, `oban`, `swoosh`, `credo`, `dialyxir`, etc.

Pin every dep with `~>` in each lesson's `mix.exs` and commit
`mix.lock` so CI is reproducible.

### Reference

- [Course design](docs/superpowers/specs/2026-05-21-elixir-course-design.md)
- [Plan A — repo foundations](docs/superpowers/plans/2026-05-21-plan-a-repo-foundations.md)

## Local workflow

```bash
make help                              # list every target
make new-lesson NAME=05-recursion      # scaffold a lesson
make slides-dev LESSON=05-recursion    # serve its deck on :8000
make test                              # exercises across all lessons (skips pending)
make test-lesson LESSON=05-recursion   # one lesson, exercises only
make solutions-test                    # solutions across all lessons (must pass)
make lint                              # mix format --check + credo where declared
make slides-build                      # build dist/ static slide site
make slides-docker                     # build the deploy image + run locally on :8080
make ci-smoke                          # harness self-tests (tooling check)
```

## Reveal.js

Reveal.js 5.1.0 is vendored under `shared/reveal/`. Provenance and
tarball SHA-256 are recorded in `shared/reveal/README.md`. To upgrade:

1. Download a new release tarball from
   <https://github.com/hakimel/reveal.js/releases>.
2. Verify its SHA-256 against the upstream release checksum.
3. Replace `shared/reveal/dist/` and `shared/reveal/plugin/` with the
   new ones.
4. Update the version line, source URL, SHA-256, and date in
   `shared/reveal/README.md`.
5. Smoke-test one lesson with `make slides-dev`.

## Commit messages

The course doesn't enforce Conventional Commits but they're encouraged:
`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `build:`, `ci:`, `deploy:`.
Scope is optional — e.g. `feat(slides): clarify pattern-matching deck`.
Commits are GPG-signed in this repo.

## CI and deploys

- Every push to `main` and every PR runs `.github/workflows/ci.yml`:
  harness smoke, lint, exercise tests, solution tests, slides-build,
  and a check that `dist/index.html` contains "Elixir Training".
- Every push to `main` also runs `.github/workflows/deploy.yml`: build
  the deploy image, push to Artifact Registry, deploy to Cloud Run at
  <https://elixir.ristkari.dev/>.
- One-time GCP/Cloudflare bootstrap is documented in
  [`deploy/README.md`](deploy/README.md).
