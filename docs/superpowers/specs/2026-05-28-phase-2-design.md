# Phase 2 Design — Concurrency & OTP

**Status:** Approved (brainstorm complete, ready for implementation planning)
**Date:** 2026-05-28
**Author:** Aki Ristkari (`aki@ristkari.dev`)
**Course design:** [`2026-05-21-elixir-course-design.md`](2026-05-21-elixir-course-design.md)
**Phase 1 spec:** [`2026-05-26-phase-1-design.md`](2026-05-26-phase-1-design.md)

## Purpose

Phase 2 takes a learner who has finished Phase 1 (recursion, Enum,
collections, strings, streams, structs, error handling, Mix) into the
distinctive heart of Elixir: the BEAM's concurrency model and OTP. By
the end of Phase 2, the learner has:

- Spawned processes and passed messages by hand.
- Used `Task` and `Agent` for lightweight concurrency.
- Written GenServers (call/cast, then handle_info/timeouts/testing).
- Built supervision trees and watched processes restart.
- Shipped a small supervised OTP application (the capstone: `MiniCache`).
- Used ETS for fast concurrent storage.
- Touched distributed Elixir across two nodes.

Phase 2 lessons:

| # | Slug | Focus |
|---|---|---|
| 13 | `processes` | `spawn`, `send`/`receive`, mailbox, isolation, links, "let it crash" |
| 14 | `tasks-and-agents` | `Task.async`/`await`/`async_stream`, `Agent` |
| 15 | `genserver-1` | GenServer behaviour: `init`, `handle_call`, `handle_cast` |
| 16 | `genserver-2` | `handle_info`, `Process.send_after`, timeouts, testing GenServers |
| 17 | `supervisors` | supervision trees, restart strategies, watching restarts |
| 18 | `otp-applications` | Phase 2 capstone — the `MiniCache` supervised application |
| 19 | `ets` | `:ets` tables, types, atomic ops; ETS vs GenServer-as-store |
| 20 | `distribution` | `Node`, `:rpc`, cookies; single-node drills + 2-node demo |

## Audience and posture

- **Starting point:** completed Phase 1. Comfortable with modules,
  functions, pattern matching, Enum/Stream, structs, `{:ok, _}`/`with`,
  and Mix projects. Has never spawned a process or written a GenServer.
- **Tone:** carries over from Phases 0/1 — conversational + everyday
  analogies, patient mentor. Lesson 13 especially leans on analogy
  because message-passing is the steepest conceptual climb in the
  course.
- **Graduation:** lesson 18 is the capstone (`MiniCache`, a supervised
  in-memory cache). Lessons 19 (ETS) and 20 (distribution) extend the
  cache idea and the node story respectively.

## Inherited conventions (all Phase 0/1 conventions apply)

- Standard lesson template: `README.md` (600–900 words; 700–1000 for
  the capstone), `HINTS.md` (200–500 words), `slides/index.html`,
  `slides/slides.md` (≤ 4 concept blocks, ≤ 20 slides), `exercises/`,
  `solutions/`.
- 2–3 micro-drills per lesson.
- REPL transcript convention: plain `iex>` (never numbered).
- Beginner asides marked `> 💡 **First time seeing this?** …` (≥ 2 per
  lesson).
- All exercise tests carry `@tag :pending`. Solution test files are
  byte-identical to exercise test files except `test_helper.exs`.
- `@moduledoc` required on every drill module.
- Lines ≤ 98 chars so `mix format` doesn't wrap them.
- One module per file; one `*_test.exs` per module (drills that bundle
  symmetric ops, e.g. push/pop, may share a module).
- "Recall from lesson NN" pointer at the top of `Key ideas` for any
  lesson that builds on a prior one — Phase 2 uses these heavily
  (13→15, 15→16, 15/16→17, 17→18, 18→19).
- Closer slide on every lesson points to the next with `make slides-dev
  LESSON=…`.
- Heavy-explanatory slide pattern (motivation → basics → worked →
  mistake → recap), vertical `--` sub-slides for "code goes down."

## Phase 2 conventions (new)

Concurrency tests need machinery the pure-data lessons didn't:

### Testing concurrent code

- **`start_supervised!/1`** in test setup for GenServer drills (lessons
  16+). ExUnit tears the process down between tests, so each test gets
  a fresh server. The lessons teach this as *the* way to test a
  GenServer.
- **`assert_receive {:msg, _}, timeout`** for message-passing drills
  (lesson 13). Tests send a message with `self()` as the reply target,
  then `assert_receive` the reply. Avoids `Process.sleep`-based
  flakiness.
- **Restart assertions** (lesson 17): a small polling helper, written
  out explicitly in the test file, that grabs a process's pid, kills it
  with `Process.exit(pid, :kill)`, then waits (bounded loop, ≤ 1s) for
  `Process.whereis(name)` to return a *different* pid.
- Where a tick interval must elapse (lesson 16 `Ticker`), the test
  sleeps slightly longer than the interval and asserts a lower bound on
  the counter, never an exact value.

### `async: false` for named-process drills

Drills that register a process under a fixed name (`name: __MODULE__`)
use `use ExUnit.Case, async: false` — two async tests would collide on
the global name. The lessons note *why* in a comment. (Most Phase 0/1
tests were `async: true`; this is a real difference learners should
understand.)

### The capstone is a `--sup` Mix project

Lesson 18's `MiniCache` uses `mix new mini_cache --sup`, which generates
an `application/0` callback and a supervisor module. The lesson's
`exercises/` and `solutions/` mix.exs carry a `mod:` entry:

```elixir
def application do
  [extra_applications: [:logger], mod: {MiniCache.Application, []}]
end
```

The implementer hand-edits the scaffolded mix.exs to add this — same
kind of one-line deviation as lesson 12's `escript:`.

### No new Hex deps

Phase 2 is entirely stdlib + OTP. `Task`, `Agent`, `GenServer`,
`Supervisor`, `Registry`, `:ets`, `Node`, `:rpc`, `:global` are all
built into the BEAM. The template's `:excoveralls` stays the only dep.
`libcluster` is *mentioned* in lesson 20 but never added.

## Lessons 13–20 — concept breakdown

### Lesson 13 — `processes`

**Concepts:** `spawn/1`, `send/2`, `receive`/`receive ... after`,
mailbox FIFO, process isolation, `Process.link/1`, `Process.monitor/1`,
"let it crash" as philosophy.

**Analogies:** a process is a tiny worker with their own desk (state)
and a mailbox. They only see what's in their mailbox, not other
workers' desks.

**Drills (3):**

1. `Echo` — `spawn` a process that receives `{from, msg}` and replies
   `{:echo, msg}`. Demonstrates the send/receive cycle. Tested with
   `assert_receive`.
2. `ProcessCounter` — a hand-rolled stateful process (explicit
   `loop(state)` function) handling `:inc`, `:get`, `:reset` messages.
   Sets up "GenServer is just this, tidied up."
3. `Linked.crash/0` — spawn_link a child that `raise`s; the parent
   traps exits with `Process.flag(:trap_exit, true)` and asserts the
   `{:EXIT, _pid, _reason}` signal arrives.

### Lesson 14 — `tasks-and-agents`

**Concepts:** `Task.async/1` + `Task.await/1`, `Task.async_stream/3`
for bounded concurrency, `Agent.start_link/1`, `Agent.get/2`,
`Agent.update/2`. When to reach for `Task` vs `Agent` vs GenServer.

**Drills (3):**

1. `Parallel.fetch_all/1` — given a list of zero-arity "work"
   functions (e.g. `fn -> Process.sleep(50); n end`), run them with
   `Task.async_stream` and collect results in order.
2. `KVAgent` — wrap an `Agent` to provide `put/2`, `get/1` over a Map.
3. `Async.race/2` — start two `Task.async` calls, return whichever
   completes first.

### Lesson 15 — `genserver-1`

**Concepts:** GenServer behaviour. `init/1`, `handle_call/3`,
`handle_cast/2`, `start_link/1`, `GenServer.call/2`, `GenServer.cast/2`.

**Recall from lesson 13:** the hand-rolled `ProcessCounter` loop?
GenServer is that loop, generalised and battle-tested.

**Drills (3):**

1. `Counter` — `start_link/1`, `inc/1` (cast), `get/1` (call),
   `reset/1` (cast).
2. `StackServer` — push (cast), pop (call), peek (call).
3. `BankAccount` — deposit (cast), withdraw (call returning
   `{:ok, balance}` | `{:error, :insufficient_funds}`), balance (call).

### Lesson 16 — `genserver-2`

**Concepts:** `handle_info/2` for non-GenServer messages,
`Process.send_after/3` for self-scheduled messages, GenServer timeouts
(the `{:noreply, state, timeout}` return), `terminate/2`, testing
GenServers with `start_supervised!/1`.

**Recall from lesson 15:** you wrote `handle_call`/`handle_cast`. Now
we handle messages that don't come through `call`/`cast`.

**Drills (2)** — deliberately narrower than 15:

1. `Ticker` — GenServer that increments a counter every 100ms via
   `Process.send_after` + `handle_info`. Test uses `start_supervised!`,
   sleeps slightly over one interval, asserts the counter advanced
   (lower-bound assertion, not exact).
2. `IdleTimer` — GenServer that uses the timeout return value to fire a
   self-message after N ms of inactivity, flipping itself to `:idle`.

### Lesson 17 — `supervisors`

**Concepts:** `Supervisor.start_link/2`, child specs, `:one_for_one`
vs `:one_for_all` vs `:rest_for_one`, restart types (`:permanent` /
`:temporary` / `:transient`), naming via `Registry` (introduced
briefly). The "kill it, watch it restart" demo.

**Recall from lessons 15/16:** you built GenServers. A supervisor keeps
them alive — when one crashes, the supervisor starts a fresh one.

**Drills (2):**

1. `SimpleSup` — supervises a single `Counter` GenServer with
   `:one_for_one`. Test: kill the counter with `Process.exit/2`; poll
   `Process.whereis/1` until a new pid appears with fresh state.
2. `AllForOneSup` — three workers under `:one_for_all`. Test: kill one;
   assert all three restart (their pids all change).

### Lesson 18 — `otp-applications` (Phase 2 capstone)

**Capstone:** `MiniCache` — a supervised in-memory key-value cache.

**Concepts:** `mix new --sup`, the `application/0` callback in mix.exs,
`Application.start/2`, the supervision tree at startup, named processes.
Mix release preview (one paragraph — full treatment is lesson 37).

**Recall from lessons 15/16/17:** GenServer for state, Supervisor to
keep it alive. An OTP application bundles them so they start
automatically.

**Capstone broken into 3 drills:**

1. `MiniCache.Server` — the GenServer; state is a `%{}` map; handles
   `put/3`, `get/2`, `delete/2`, `size/1`.
2. `MiniCache.Application` + the supervisor child spec, plus the
   `mod: {MiniCache.Application, []}` entry hand-added to mix.exs. The
   Server is registered under a fixed name.
3. `MiniCache` public API (`put/2`, `get/1`, `delete/1`, `size/0`)
   delegating to the Server. Integration test: start the app, put/get
   values, kill the Server with `Process.exit`, confirm a fresh Server
   starts **empty** (cache state lives in the GenServer; lesson 19
   upgrades this to ETS that survives restarts).

The README closes with: "Run `iex -S mix`, call
`MiniCache.put(\"hello\", :world)`, then `MiniCache.get(\"hello\")`.
You just shipped an OTP application."

### Lesson 19 — `ets`

**Concepts:** `:ets.new/2`, table types (`:set`, `:bag`,
`:ordered_set`), `:ets.insert/2`, `:ets.lookup/2`, `:ets.delete/2`,
access levels (`:public`/`:protected`/`:private`),
`:ets.update_counter/3`. When ETS beats a GenServer-as-store
(read-heavy, atomic ops, raw speed, concurrent reads that don't
serialise through one process).

**Recall from lesson 18:** MiniCache funnelled every read through one
GenServer. ETS lets concurrent reads skip that bottleneck.

**Drills (2):**

1. `ETSCache` — same public API as lesson 18's MiniCache (`put/2`,
   `get/1`, `delete/1`) but backed by a `:public` `:ets` table owned by
   a GenServer. Reads bypass the GenServer.
2. `Atomic.bump/2` — `:ets.update_counter/3` for atomic integer
   counters. Test: spawn 100 concurrent processes that each `bump`,
   assert the final count is exactly 100 (proves atomicity).

### Lesson 20 — `distribution`

**Concepts:** `Node.self/0`, `Node.alive?/0`, `Node.list/0`,
`Node.connect/1`, `:rpc.call/4`, `--sname` vs `--name`, cookies,
`:global.register_name/2`. `libcluster` mentioned, not used.

**Drills (2)** — single-node, Mix-testable only:

1. `Localnode.info/0` — returns `{node_name, alive?}` via `Node.self/0`
   and `Node.alive?/0`.
2. `Localnode.echo_via_rpc/1` — uses `:rpc.call(Node.self(), Kernel,
   :inspect, [msg])` to round-trip through the rpc machinery against
   the current node.

**Plus a "follow the steps" 2-node demo** in README + slides:

- Two terminals: `iex --sname alice --cookie mycourse` and
  `iex --sname bob --cookie mycourse`.
- From alice: `Node.connect(:"bob@<host>")`, then `Node.list()`.
- `:rpc.call(:"bob@<host>", IO, :inspect, ["hi from alice"])`.
- Expected output shown. README is explicit that this is manual and
  not CI-verified.

## Authoring conventions recap

- Length targets: README 600–900 words (700–1000 for lesson 18); HINTS
  200–500 words; slides ≤ 20.
- Drill code is exact (modules, function names, doctest examples where
  sensible). READMEs/HINTS/slides are detailed outlines — the
  implementer writes prose within the structure.
- Each lesson's closer slide points to the next lesson.

## Definition of done — Phase 2 v1

1. Eight lesson directories (`lessons/13-processes/` …
   `lessons/20-distribution/`) exist and are committed.
2. `make solutions-test` is green across all eight (~20 new tests on
   top of the 121 from Phases 0+1).
3. `make lint` is clean.
4. `make slides-build` produces a `dist/index.html` with lessons 00–20
   lit up as "published"; Cloud Run deploy continues to work
   end-to-end.
5. `cd lessons/18-otp-applications/solutions && iex -S mix` then
   `MiniCache.put("k", :v); MiniCache.get("k")` returns `:v` — the
   Phase 2 demo moment.
6. A learner who finished Phase 1 can work through lessons 13–20 using
   only README + slides + hints + exercises.

## Risks

- **Lesson 13 is the hardest beginner leap in the course.** Mitigation:
  lean on the "worker with a mailbox" analogy, use `assert_receive`
  (not sleeps), keep the three drills strictly progressive.
- **Concurrency test flakiness.** Mitigation: `start_supervised!`,
  `assert_receive` with explicit timeouts, bounded polling for
  restarts. No raw `Process.sleep` in assertions where avoidable;
  where a tick interval must elapse, assert a lower bound, not an exact
  value.
- **CI parallelism vs named processes.** `tools/run-all-tests` runs each
  lesson's suite in its own `mix test`, so cross-lesson name collisions
  can't happen. Within a lesson, named-process drills use
  `async: false`. Flagged so the author doesn't set `async: true` on a
  named-server test.
- **MiniCache state semantics in the kill test.** Killed-and-restarted
  Server state resets (state lives in the GenServer, not ETS). The
  lesson 18 integration test asserts the empty-after-restart behaviour;
  the README explains why lesson 19's ETS version differs.
- **Distribution demo can't be CI-verified.** Lesson 20's multi-node
  steps run on the learner's machine. CI only exercises the single-node
  drills. The README is explicit that the demo is manual.

## Deferred decisions

- **Whether lesson 17 introduces `DynamicSupervisor`.** Currently static
  child specs only; `DynamicSupervisor` is a "going further" mention.
- **Whether `MiniCache` gets TTL/expiry.** v1 is put/get/delete/size
  only; TTL is a "going further" stretch goal.
- **Registry depth.** Lesson 17 mentions `Registry` for naming but
  doesn't make it a drill. Whether it earns its own treatment is a
  Phase-2-revisit question.

## Explicit non-goals (YAGNI)

- No `DynamicSupervisor` / `PartitionSupervisor` drills (mention only).
- No `GenStage` / `Flow` / `Broadway`.
- No real multi-node clustering in CI; no `libcluster` dependency
  (mention only).
- No `:mnesia` — ETS only in Phase 2.
- No distributed-Erlang security hardening (TLS distribution, etc.).
- No `handle_continue/2` deep-dive — may appear in lesson 16 as a
  one-liner, not a drill.
