# Elixir Training

An Elixir programming course delivered as code + per-lesson reveal.js
slide decks. The arc starts at programming-101 and finishes with the
learner deploying a small Phoenix web app — backed by Postgres via Ecto,
real-time LiveView, and OTP supervision — to production.

Hosted slide site: <https://elixir.ristkari.dev/>

## Prerequisites

- `asdf` with the `erlang` and `elixir` plugins. The pinned versions
  live in `.tool-versions`:
  ```bash
  asdf install
  ```
- Docker (for Postgres from lesson 26 onward and for the release
  lesson + slides-docker target).
- Python 3 (used by the local slide server).
- Make.

## Quick start

```bash
make help                          # list every available command
make new-lesson NAME=99-demo       # scaffold a sandbox lesson
make slides-dev LESSON=99-demo     # serve its deck on http://localhost:8000
make test                          # run all lesson exercises (skips @tag :pending)
make solutions-test                # run all lesson solutions (must all pass)
make lint                          # mix format --check + credo where declared
make slides-build                  # build dist/ static slide site
make slides-docker                 # build the deploy image + run on http://localhost:8080
make ci-smoke                      # harness self-tests (tooling smoke check)
```

## Repository layout

```
lessons/NN-name/
├── README.md       self-study notes: objectives, key ideas, links
├── HINTS.md        progressively-revealed hints (beginner safety rail)
├── slides/         reveal.js deck (index.html + slides.md)
├── exercises/      starter Mix project + failing tests (the spec)
└── solutions/      reference Mix project + the same tests, passing

shared/reveal/                vendored reveal.js 5.1.0 (do not hand-edit)
shared/lesson-template/       scaffold copied by `make new-lesson`
tools/                        dev scripts the Makefile invokes
tools/build_index/            Elixir script that builds the static slide site
deploy/                       Dockerfile, nginx, Cloud Run spec, GCP bootstrap
docs/superpowers/specs/       course design specs
docs/superpowers/plans/       implementation plans
.github/workflows/            CI (lint + tests + slides-build) + Cloud Run deploy
```

## Design

See [`docs/superpowers/specs/2026-05-21-elixir-course-design.md`](docs/superpowers/specs/2026-05-21-elixir-course-design.md)
for the full course design.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the lesson-authoring
conventions, slide style, dependency policy by phase, and local
workflow.

## Deployment

The slides site at <https://elixir.ristkari.dev/> is rebuilt and
redeployed by `.github/workflows/deploy.yml` on every push to `main`.
The one-time GCP/Cloudflare bootstrap is documented in
[`deploy/README.md`](deploy/README.md).
