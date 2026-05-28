# Plan D — Phase 2 Lessons Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Author the eight Phase 2 lessons (13-processes through 20-distribution) so a learner who finished Phase 1 can spawn processes, use Tasks/Agents, write GenServers, build supervision trees, ship a small supervised OTP application (the `MiniCache` capstone), use ETS, and touch distributed Elixir.

**Architecture:** Eight lessons using the existing `shared/lesson-template/` scaffolded by `tools/new-lesson`, with hand-authored README/HINTS/slides + 2–3 micro-drill Mix exercises per lesson. Lesson 18 (`otp-applications`) hand-edits its `mix.exs` to add a `mod:` application callback (the MiniCache capstone). Concurrency drills use the `start_supervised!` / `assert_receive` / bounded-restart-poll testing idioms standardised in the Phase 2 spec.

**Tech Stack:** Elixir 1.18 + Erlang/OTP 27, ExUnit, OTP behaviours (`GenServer`, `Supervisor`, `Application`, `Agent`, `Task`), `:ets`, `Node`/`:rpc`. No new Hex deps beyond the template's `:excoveralls`.

**Pre-flight:** Run from repo root `/Users/ristkari/code/private/elixir-training/`. `main` is up-to-date and includes the merged Plans A/B/C (lessons 00–12). Work happens on a new branch `plan-d-phase-2` (Task 0). Commits are GPG-signed.

**Spec:** [`docs/superpowers/specs/2026-05-28-phase-2-design.md`](../specs/2026-05-28-phase-2-design.md).

---

## Inherited + new conventions (recap)

All Phase 0/1 conventions apply (README 600–900 words / 700–1000 for the capstone; HINTS 200–500; slides ≤ 4 concept blocks, ≤ 20 slides; plain `iex>`; `> 💡` callouts ≥ 2; `@tag :pending`; byte-identical solution tests via `cp`; `@moduledoc`; lines ≤ 98 chars; "Recall from lesson NN" pointers; closer slide). New for Phase 2:

- **GenServer exercise stubs:** ship the full module (moduledoc, `use GenServer`, complete client API one-liners) but stub the *callbacks* with `raise("TODO: …")`. The client API is boilerplate the learner shouldn't fight; the callbacks are the drill. When `init/1` raises, `start_link` returns `{:error, _}` so the test's `{:ok, pid} = …` match fails cleanly.
- **`start_supervised!/1`** in GenServer test setup (lessons 16+).
- **`assert_receive {…}, timeout`** for message-passing drills (lesson 13).
- **Restart-poll helper** (lesson 17): a `wait_for_new_pid/3` / `wait_until_all_changed/2` defined in the test file.
- **`async: false`** for any test module whose drill registers a process under a fixed name (`name: __MODULE__`). Comment why.
- **Tick-interval tests** sleep slightly longer than the interval and assert a lower bound, never an exact count.

---

## Module inventory by lesson

| Lesson | Modules |
|---|---|
| 13 | `Echo`, `ProcessCounter`, `Linked` |
| 14 | `Parallel`, `KVAgent`, `Async` |
| 15 | `Counter`, `StackServer`, `BankAccount` |
| 16 | `Ticker`, `IdleTimer` |
| 17 | `SupCounter` + `SimpleSup`; `Worker` + `AllForOneSup` |
| 18 | `MiniCache.Server`, `MiniCache.Application`, `MiniCache` |
| 19 | `ETSCache`, `Atomic` |
| 20 | `Localnode` |

---

## Task 0: Branch + spec reference

- [ ] **Step 1: Confirm clean tree on main**

```bash
git status
git log --oneline -1
```

Expected: clean tree; last commit is the Phase 1 merge or newer.

- [ ] **Step 2: Create the working branch**

```bash
git checkout -b plan-d-phase-2
git status
```

Expected: `On branch plan-d-phase-2`, clean.

- [ ] **Step 3: Verify spec present**

```bash
test -f docs/superpowers/specs/2026-05-28-phase-2-design.md && echo OK
```

Expected: `OK`. No commit in this task.

---

## Task 1: Lesson 13 — `processes`

**Files:** scaffold `lessons/13-processes/`; replace README/HINTS/slides; drills `echo.ex`, `process_counter.ex`, `linked.ex` + tests in exercises and solutions.

### Step 1: Scaffold

```bash
tools/new-lesson 13-processes
```

### Step 2: README (600–900 words)

Sections:
1. `# Lesson 13: Processes` + hook: "By the end of this lesson, you'll spawn your own processes and pass messages between them — the foundation everything else in OTP is built on. This is the steepest new idea in the course; take it slowly."
2. `## Key ideas`:
   - **A process is a tiny isolated worker.** It has its own private state (its "desk") and a mailbox. It can't see other processes' desks — the only way to interact is to send a message to a mailbox. Processes are cheap: the BEAM runs millions of them.
   - **`spawn/1`** starts a process running a function. Returns a pid (process id).
   - **`send/2` and `receive`.** `send(pid, msg)` drops a message in a mailbox. `receive do … end` blocks until a matching message arrives. The mailbox is FIFO; `receive` scans it for the first matching pattern.
   - **Keeping state with recursion.** A process that wants to "remember" something loops: it `receive`s a message, computes a new state, and calls its loop function again with the new state. (Recall lesson 05 recursion.)
   - **Links and "let it crash."** `spawn_link/1` ties two processes together — if one dies, the other gets an exit signal (and dies too, unless it traps exits with `Process.flag(:trap_exit, true)`). This is the seed of supervision (lesson 17): rather than defensively rescuing everything, you let a process crash and have something else restart it.
3. `## Try it in IEx` — transcript: `pid = spawn(fn -> receive do msg -> IO.inspect(msg) end end)`, `send(pid, :hello)`.
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Expecting `send` to return a reply. It doesn't — it's fire-and-forget. To get a reply, include `self()` in the message and `receive` the answer.
   - A `receive` with no matching clause blocks forever. Use `after` for a timeout.
   - Thinking processes share memory. They don't — everything is copied into the message.
6. `## Going further`:
   - Read about `Process.monitor/1` — how does it differ from `Process.link/1`?
   - What does `receive ... after 0 -> …` do? When is it useful?
7. `## Links`:
   - [HexDocs — Process](https://hexdocs.pm/elixir/Process.html)
   - [Elixir — Processes guide](https://hexdocs.pm/elixir/processes.html)

≥ 2 `> 💡` callouts (the mailbox/FIFO idea; the "send is fire-and-forget" surprise).

### Step 3: HINTS (~350 words) — three drill sections, three hints each. Hint 3 shows full code matching the solutions below.

### Step 4: slides — ≤ 20 slides, ≤ 4 concept blocks: "Processes & spawn", "send/receive", "State via a receive loop", "Links & let-it-crash". Closer → lesson 14 (`make slides-dev LESSON=14-tasks-and-agents`).

### Step 5: Drill 1 — `Echo`

`lessons/13-processes/exercises/lib/echo.ex`:

```elixir
defmodule Echo do
  @moduledoc "A process that echoes messages back to the sender."

  @doc """
  Spawn an echo process. It waits for `{from, msg}` and sends back
  `{:echo, msg}` to `from`, then waits again.
  """
  def start, do: raise("TODO: spawn a process running a receive loop that echoes {from, msg}")
end
```

`lessons/13-processes/exercises/test/echo_test.exs`:

```elixir
defmodule EchoTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "Echo replies with {:echo, msg}" do
    pid = Echo.start()
    send(pid, {self(), "hello"})
    assert_receive {:echo, "hello"}, 500
  end

  @tag :pending
  test "Echo keeps serving multiple messages" do
    pid = Echo.start()
    send(pid, {self(), "one"})
    assert_receive {:echo, "one"}, 500
    send(pid, {self(), "two"})
    assert_receive {:echo, "two"}, 500
  end
end
```

`lessons/13-processes/solutions/lib/echo.ex`:

```elixir
defmodule Echo do
  @moduledoc "A process that echoes messages back to the sender."

  @doc """
  Spawn an echo process. It waits for `{from, msg}` and sends back
  `{:echo, msg}` to `from`, then waits again.
  """
  def start, do: spawn(fn -> loop() end)

  defp loop do
    receive do
      {from, msg} ->
        send(from, {:echo, msg})
        loop()
    end
  end
end
```

`cp` the test file to solutions.

### Step 6: Drill 2 — `ProcessCounter`

`lessons/13-processes/exercises/lib/process_counter.ex`:

```elixir
defmodule ProcessCounter do
  @moduledoc "A hand-rolled stateful counter process (pre-GenServer)."

  @doc """
  Spawn a counter process starting at `initial`. It responds to:
  `:inc` (increment), `{:get, from}` (send `{:count, n}` to `from`),
  and `:reset` (back to 0).
  """
  def start(_initial \\ 0), do: raise("TODO: spawn a process running loop(initial)")
end
```

`lessons/13-processes/exercises/test/process_counter_test.exs`:

```elixir
defmodule ProcessCounterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "starts at the given initial value" do
    pid = ProcessCounter.start(5)
    send(pid, {:get, self()})
    assert_receive {:count, 5}, 500
  end

  @tag :pending
  test "increments on :inc" do
    pid = ProcessCounter.start(0)
    send(pid, :inc)
    send(pid, :inc)
    send(pid, {:get, self()})
    assert_receive {:count, 2}, 500
  end

  @tag :pending
  test "resets on :reset" do
    pid = ProcessCounter.start(10)
    send(pid, :reset)
    send(pid, {:get, self()})
    assert_receive {:count, 0}, 500
  end
end
```

`lessons/13-processes/solutions/lib/process_counter.ex`:

```elixir
defmodule ProcessCounter do
  @moduledoc "A hand-rolled stateful counter process (pre-GenServer)."

  @doc """
  Spawn a counter process starting at `initial`. It responds to:
  `:inc` (increment), `{:get, from}` (send `{:count, n}` to `from`),
  and `:reset` (back to 0).
  """
  def start(initial \\ 0), do: spawn(fn -> loop(initial) end)

  defp loop(count) do
    receive do
      :inc ->
        loop(count + 1)

      {:get, from} ->
        send(from, {:count, count})
        loop(count)

      :reset ->
        loop(0)
    end
  end
end
```

`cp` the test file.

### Step 7: Drill 3 — `Linked`

`lessons/13-processes/exercises/lib/linked.ex`:

```elixir
defmodule Linked do
  @moduledoc "Demonstrates process links and trapping exits."

  @doc """
  Set the current process to trap exits, then spawn_link a child that
  crashes. Because exits are trapped, the caller receives an
  `{:EXIT, child_pid, reason}` message instead of crashing too.
  Returns the child pid.
  """
  def crash, do: raise("TODO: Process.flag(:trap_exit, true) then spawn_link a crashing fn")
end
```

`lessons/13-processes/exercises/test/linked_test.exs`:

```elixir
defmodule LinkedTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "the caller receives an EXIT signal when the linked child crashes" do
    pid = Linked.crash()
    assert_receive {:EXIT, ^pid, _reason}, 500
  end
end
```

`lessons/13-processes/solutions/lib/linked.ex`:

```elixir
defmodule Linked do
  @moduledoc "Demonstrates process links and trapping exits."

  @doc """
  Set the current process to trap exits, then spawn_link a child that
  crashes. Because exits are trapped, the caller receives an
  `{:EXIT, child_pid, reason}` message instead of crashing too.
  Returns the child pid.
  """
  def crash do
    Process.flag(:trap_exit, true)
    spawn_link(fn -> raise "boom" end)
  end
end
```

`cp` the test file.

### Step 8: Verify and commit

```bash
cd lessons/13-processes/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist
grep -c 'lessons/13-processes/slides/' dist/index.html
rm -rf dist
```

Expected: `6 tests, 0 failures` (Echo 2 + ProcessCounter 3 + Linked 1). build_index `1`.

```bash
git add lessons/13-processes
git commit -m "Add lesson 13-processes: spawn, send/receive, links, let-it-crash

Three drills: Echo (spawn + receive loop, tested with assert_receive),
ProcessCounter (a hand-rolled stateful process that sets up 'GenServer
is just this, tidied up'), and Linked (trap_exit + spawn_link, asserts
the {:EXIT, pid, reason} signal arrives). README leans on the 'tiny
worker with a private desk and a mailbox' analogy — this is the
steepest conceptual lesson in the course. Slides have four concept
blocks under the 20-slide cap.

Solutions green: 6 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Lesson 14 — `tasks-and-agents`

**Files:** scaffold; replace prose; drills `parallel.ex`, `kv_agent.ex`, `async.ex` + tests.

### Step 1: Scaffold

```bash
tools/new-lesson 14-tasks-and-agents
```

### Step 2: README (600–900 words)

1. Hook: "By the end of this lesson, you'll run work concurrently with `Task` and hold shared state with `Agent` — two friendly wrappers over the raw processes from lesson 13."
2. `## Key ideas`:
   - **Recall from lesson 13:** spawning processes and passing messages by hand is powerful but verbose. `Task` and `Agent` are batteries-included wrappers for the two most common cases.
   - **`Task.async/1` + `Task.await/1`** — run a function in a separate process, get its result back later. Good for "do these N independent things concurrently."
   - **`Task.async_stream/3`** — map a function over an enumerable with bounded concurrency. Returns a stream of `{:ok, result}` tuples.
   - **`Agent`** — a process that holds state you read and update with `Agent.get/2` and `Agent.update/2`. Good for "I want shared mutable state without writing a whole GenServer."
   - **When to use which:** `Task` for fire-and-collect concurrency; `Agent` for simple shared state; GenServer (next lessons) when you need custom message handling.
3. `## Try it in IEx` — transcript: `Task.async(fn -> 1 + 1 end) |> Task.await()`, then an Agent example.
4. `## How to work this lesson` — standard.
5. `## Common mistakes`:
   - Forgetting to `Task.await` — the result is lost and you may leak the process.
   - Using an `Agent` for complex logic. If the update functions get gnarly, reach for a GenServer.
   - Assuming `async_stream` preserves order by default — it does (with `ordered: true` the default), but at a latency cost.
6. `## Going further`:
   - `Task.async_stream/3` takes a `:max_concurrency` option. What's the default? When would you lower it?
   - When does `Agent` become the wrong tool, and you should reach for `GenServer`?
7. `## Links`: [HexDocs — Task](https://hexdocs.pm/elixir/Task.html), [HexDocs — Agent](https://hexdocs.pm/elixir/Agent.html)

### Step 3: HINTS — three sections, three hints each.

### Step 4: slides — 4 concept blocks: "Task.async/await", "Task.async_stream", "Agent", "Which tool when". Closer → lesson 15.

### Step 5: Drill 1 — `Parallel.fetch_all/1`

`lessons/14-tasks-and-agents/exercises/lib/parallel.ex`:

```elixir
defmodule Parallel do
  @moduledoc "Run zero-arity work functions concurrently."

  @doc """
  Given a list of zero-arity functions, run them concurrently with
  Task.async_stream and return their results in the original order.

      iex> Parallel.fetch_all([fn -> 1 end, fn -> 2 end])
      [1, 2]
  """
  def fetch_all(_funs), do: raise("TODO: Task.async_stream(funs, fn f -> f.() end) then collect")
end
```

`lessons/14-tasks-and-agents/exercises/test/parallel_test.exs`:

```elixir
defmodule ParallelTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "runs functions and returns results in order" do
    funs = [fn -> 1 end, fn -> 2 end, fn -> 3 end]
    assert Parallel.fetch_all(funs) == [1, 2, 3]
  end

  @tag :pending
  test "actually runs concurrently (3x50ms work finishes well under 150ms)" do
    funs = for _ <- 1..3, do: fn -> Process.sleep(50); :done end
    {micros, results} = :timer.tc(fn -> Parallel.fetch_all(funs) end)
    assert results == [:done, :done, :done]
    assert micros < 120_000
  end

  @tag :pending
  test "returns [] for an empty list" do
    assert Parallel.fetch_all([]) == []
  end
end
```

`lessons/14-tasks-and-agents/solutions/lib/parallel.ex`:

```elixir
defmodule Parallel do
  @moduledoc "Run zero-arity work functions concurrently."

  @doc """
  Given a list of zero-arity functions, run them concurrently with
  Task.async_stream and return their results in the original order.

      iex> Parallel.fetch_all([fn -> 1 end, fn -> 2 end])
      [1, 2]
  """
  def fetch_all(funs) do
    funs
    |> Task.async_stream(fn f -> f.() end)
    |> Enum.map(fn {:ok, result} -> result end)
  end
end
```

`cp` the test file.

### Step 6: Drill 2 — `KVAgent`

`lessons/14-tasks-and-agents/exercises/lib/kv_agent.ex`:

```elixir
defmodule KVAgent do
  @moduledoc "A key-value store backed by an Agent."

  @doc "Start an empty KV agent, returning {:ok, pid}."
  def start_link, do: raise("TODO: Agent.start_link(fn -> %{} end)")

  @doc "Store value under key."
  def put(_agent, _key, _value), do: raise("TODO: Agent.update")

  @doc "Fetch the value for key, or nil."
  def get(_agent, _key), do: raise("TODO: Agent.get")
end
```

`lessons/14-tasks-and-agents/exercises/test/kv_agent_test.exs`:

```elixir
defmodule KVAgentTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, agent} = KVAgent.start_link()
    %{agent: agent}
  end

  @tag :pending
  test "put then get round-trips a value", %{agent: agent} do
    KVAgent.put(agent, :name, "Aki")
    assert KVAgent.get(agent, :name) == "Aki"
  end

  @tag :pending
  test "get returns nil for a missing key", %{agent: agent} do
    assert KVAgent.get(agent, :missing) == nil
  end
end
```

`lessons/14-tasks-and-agents/solutions/lib/kv_agent.ex`:

```elixir
defmodule KVAgent do
  @moduledoc "A key-value store backed by an Agent."

  @doc "Start an empty KV agent, returning {:ok, pid}."
  def start_link, do: Agent.start_link(fn -> %{} end)

  @doc "Store value under key."
  def put(agent, key, value), do: Agent.update(agent, &Map.put(&1, key, value))

  @doc "Fetch the value for key, or nil."
  def get(agent, key), do: Agent.get(agent, &Map.get(&1, key))
end
```

`cp` the test file.

### Step 7: Drill 3 — `Async.race/2`

`lessons/14-tasks-and-agents/exercises/lib/async.ex`:

```elixir
defmodule Async do
  @moduledoc "Start two tasks; return whichever finishes first."

  @doc """
  Run two zero-arity functions concurrently. Return the result of
  whichever completes first.
  """
  def race(_fun_a, _fun_b), do: raise("TODO: Task.async both, Task.yield_many or await_many + pick first")
end
```

`lessons/14-tasks-and-agents/exercises/test/async_test.exs`:

```elixir
defmodule AsyncTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "returns the faster task's result" do
    slow = fn -> Process.sleep(100); :slow end
    fast = fn -> Process.sleep(10); :fast end
    assert Async.race(slow, fast) == :fast
  end

  @tag :pending
  test "works regardless of argument order" do
    slow = fn -> Process.sleep(100); :slow end
    fast = fn -> Process.sleep(10); :fast end
    assert Async.race(fast, slow) == :fast
  end
end
```

`lessons/14-tasks-and-agents/solutions/lib/async.ex`:

```elixir
defmodule Async do
  @moduledoc "Start two tasks; return whichever finishes first."

  @doc """
  Run two zero-arity functions concurrently. Return the result of
  whichever completes first.
  """
  def race(fun_a, fun_b) do
    task_a = Task.async(fun_a)
    task_b = Task.async(fun_b)

    {first, _rest} =
      [task_a, task_b]
      |> Task.yield_many(timeout: :infinity)
      |> Enum.find(fn {_task, result} -> match?({:ok, _}, result) end)

    {:ok, value} = elem(first |> then(&{&1, nil}), 1) |> then(fn _ -> Task.await(first) end)
    value
  end
end
```

NOTE TO IMPLEMENTER: the `race/2` solution above is awkward. Use this cleaner implementation instead, and verify it passes:

```elixir
def race(fun_a, fun_b) do
  task_a = Task.async(fun_a)
  task_b = Task.async(fun_b)
  [{_task, {:ok, value}} | _] = Task.yield_many([task_a, task_b], timeout: :infinity)
  Task.shutdown(task_a, :brutal_kill)
  Task.shutdown(task_b, :brutal_kill)
  value
end
```

Wait — `Task.yield_many` returns results in the order the tasks were passed, NOT completion order. So `[task_a, task_b]` always yields `task_a` first if both done. That breaks "first to finish." Use `Task.yield_many` with a short poll loop, OR simpler — use a receive-based approach. The CLEAN, CORRECT implementation the implementer MUST use:

```elixir
def race(fun_a, fun_b) do
  task_a = Task.async(fun_a)
  task_b = Task.async(fun_b)
  result = race_loop(task_a, task_b)
  Task.shutdown(task_a, :brutal_kill)
  Task.shutdown(task_b, :brutal_kill)
  result
end

defp race_loop(task_a, task_b) do
  receive do
    {ref, value} when ref == task_a.ref or ref == task_b.ref -> value
  end
end
```

`Task.async` sends `{ref, result}` to the caller when the task completes. The first such message wins. After grabbing it, shut down both tasks (the loser and the already-finished winner's cleanup). This is order-independent and genuinely "first to finish." Implement THIS version in solutions; the exercise stub stays the `raise` one-liner.

`cp` the test file.

### Step 8: Verify and commit

```bash
cd lessons/14-tasks-and-agents/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `7 tests, 0 failures` (Parallel 3 + KVAgent 2 + Async 2).

```bash
git add lessons/14-tasks-and-agents
git commit -m "Add lesson 14-tasks-and-agents: Task and Agent

Three drills: Parallel.fetch_all/1 (Task.async_stream with an ordered,
concurrency-proving test), KVAgent (an Agent-backed key-value store),
and Async.race/2 (two Task.async calls, return the first to finish via
a receive on the task refs). README frames Task/Agent as friendly
wrappers over the raw processes from lesson 13. Slides have four
concept blocks under the cap.

Solutions green: 7 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Lesson 15 — `genserver-1`

**Files:** scaffold; replace prose; drills `counter.ex`, `stack_server.ex`, `bank_account.ex` + tests.

### Step 1: Scaffold

```bash
tools/new-lesson 15-genserver-1
```

### Step 2: README (600–900 words)

1. Hook: "By the end of this lesson, you'll write GenServers — the workhorse of OTP. A GenServer is the `ProcessCounter` loop from lesson 13, generalised and made bulletproof."
2. `## Key ideas`:
   - **Recall from lesson 13:** the hand-rolled `ProcessCounter` had a `receive` loop carrying state. GenServer is that pattern, standardised: you write callbacks, OTP runs the loop.
   - **The two halves of a GenServer.** The *client API* (public functions other code calls) and the *callbacks* (`init`, `handle_call`, `handle_cast`) that run inside the server process. Keep them visually separated.
   - **`call` vs `cast`.** `GenServer.call/2` is synchronous — it waits for a reply. `GenServer.cast/2` is fire-and-forget — no reply. Use `call` when you need the answer (`get`), `cast` when you don't (`inc`).
   - **`init/1`** sets the starting state, returns `{:ok, state}`.
   - **A subtle guarantee:** messages to one GenServer are processed one at a time, in order. A `cast` followed by a `call` to the same server means the cast is fully handled before the call returns — no sleeps needed in tests.
3. `## Try it in IEx` — define a tiny Counter inline, `start_link`, `cast`, `call`.
4. `## How to work this lesson` — note: the client API is provided; you implement the callbacks.
5. `## Common mistakes`:
   - Putting business logic in the client API instead of the callback. The client API should just `call`/`cast`; the logic lives in `handle_*`.
   - Forgetting `@impl true` on callbacks. It's not required but it catches typos (a misspelled `handle_calll` would otherwise silently never run).
   - Returning the wrong tuple shape. `handle_call` returns `{:reply, reply, new_state}`; `handle_cast` returns `{:noreply, new_state}`.
6. `## Going further`:
   - What happens if a `handle_call` takes longer than 5 seconds? (Hint: the default `call` timeout.)
   - Read about `GenServer.start_link/3`'s `:name` option — how do you call a server by name instead of pid?
7. `## Links`: [HexDocs — GenServer](https://hexdocs.pm/elixir/GenServer.html)

### Step 3: HINTS — three sections.

### Step 4: slides — 4 concept blocks: "Client API vs callbacks", "init & state", "handle_call (sync)", "handle_cast (async)". Closer → lesson 16.

### Step 5: Drill 1 — `Counter`

Exercise (`lessons/15-genserver-1/exercises/lib/counter.ex`):

```elixir
defmodule Counter do
  @moduledoc "A GenServer that holds an integer count."
  use GenServer

  # Client API — done for you.
  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def inc(pid), do: GenServer.cast(pid, :inc)
  def get(pid), do: GenServer.call(pid, :get)
  def reset(pid), do: GenServer.cast(pid, :reset)

  # Callbacks — implement these.
  @impl true
  def init(_initial), do: raise("TODO: return {:ok, initial}")

  @impl true
  def handle_cast(_msg, _count), do: raise("TODO: handle :inc and :reset")

  @impl true
  def handle_call(_msg, _from, _count), do: raise("TODO: handle :get")
end
```

Test (`lessons/15-genserver-1/exercises/test/counter_test.exs`):

```elixir
defmodule CounterTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "starts at the given value and returns it" do
    {:ok, pid} = Counter.start_link(5)
    assert Counter.get(pid) == 5
  end

  @tag :pending
  test "increments" do
    {:ok, pid} = Counter.start_link(0)
    Counter.inc(pid)
    Counter.inc(pid)
    assert Counter.get(pid) == 2
  end

  @tag :pending
  test "resets" do
    {:ok, pid} = Counter.start_link(10)
    Counter.reset(pid)
    assert Counter.get(pid) == 0
  end
end
```

Solution (`lessons/15-genserver-1/solutions/lib/counter.ex`):

```elixir
defmodule Counter do
  @moduledoc "A GenServer that holds an integer count."
  use GenServer

  # Client API
  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def inc(pid), do: GenServer.cast(pid, :inc)
  def get(pid), do: GenServer.call(pid, :get)
  def reset(pid), do: GenServer.cast(pid, :reset)

  # Callbacks
  @impl true
  def init(initial), do: {:ok, initial}

  @impl true
  def handle_cast(:inc, count), do: {:noreply, count + 1}
  def handle_cast(:reset, _count), do: {:noreply, 0}

  @impl true
  def handle_call(:get, _from, count), do: {:reply, count, count}
end
```

`cp` test file.

### Step 6: Drill 2 — `StackServer`

Exercise (`lessons/15-genserver-1/exercises/lib/stack_server.ex`):

```elixir
defmodule StackServer do
  @moduledoc "A GenServer holding a stack (list)."
  use GenServer

  def start_link(initial \\ []), do: GenServer.start_link(__MODULE__, initial)
  def push(pid, value), do: GenServer.cast(pid, {:push, value})
  def pop(pid), do: GenServer.call(pid, :pop)
  def peek(pid), do: GenServer.call(pid, :peek)

  @impl true
  def init(_stack), do: raise("TODO: return {:ok, stack}")

  @impl true
  def handle_cast(_msg, _stack), do: raise("TODO: handle {:push, value}")

  @impl true
  def handle_call(_msg, _from, _stack), do: raise("TODO: handle :pop and :peek")
end
```

Test (`lessons/15-genserver-1/exercises/test/stack_server_test.exs`):

```elixir
defmodule StackServerTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "push then pop returns the value" do
    {:ok, pid} = StackServer.start_link()
    StackServer.push(pid, :a)
    StackServer.push(pid, :b)
    assert StackServer.pop(pid) == {:ok, :b}
    assert StackServer.pop(pid) == {:ok, :a}
  end

  @tag :pending
  test "pop on an empty stack returns {:error, :empty}" do
    {:ok, pid} = StackServer.start_link()
    assert StackServer.pop(pid) == {:error, :empty}
  end

  @tag :pending
  test "peek returns the top without removing it" do
    {:ok, pid} = StackServer.start_link()
    StackServer.push(pid, :only)
    assert StackServer.peek(pid) == {:ok, :only}
    assert StackServer.peek(pid) == {:ok, :only}
  end
end
```

Solution (`lessons/15-genserver-1/solutions/lib/stack_server.ex`):

```elixir
defmodule StackServer do
  @moduledoc "A GenServer holding a stack (list)."
  use GenServer

  def start_link(initial \\ []), do: GenServer.start_link(__MODULE__, initial)
  def push(pid, value), do: GenServer.cast(pid, {:push, value})
  def pop(pid), do: GenServer.call(pid, :pop)
  def peek(pid), do: GenServer.call(pid, :peek)

  @impl true
  def init(stack), do: {:ok, stack}

  @impl true
  def handle_cast({:push, value}, stack), do: {:noreply, [value | stack]}

  @impl true
  def handle_call(:pop, _from, []), do: {:reply, {:error, :empty}, []}
  def handle_call(:pop, _from, [top | rest]), do: {:reply, {:ok, top}, rest}
  def handle_call(:peek, _from, []), do: {:reply, {:error, :empty}, []}
  def handle_call(:peek, _from, [top | _] = stack), do: {:reply, {:ok, top}, stack}
end
```

`cp` test file.

### Step 7: Drill 3 — `BankAccount`

Exercise (`lessons/15-genserver-1/exercises/lib/bank_account.ex`):

```elixir
defmodule BankAccount do
  @moduledoc "A GenServer bank account with deposit/withdraw/balance."
  use GenServer

  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def deposit(pid, amount), do: GenServer.cast(pid, {:deposit, amount})
  def withdraw(pid, amount), do: GenServer.call(pid, {:withdraw, amount})
  def balance(pid), do: GenServer.call(pid, :balance)

  @impl true
  def init(_balance), do: raise("TODO: return {:ok, balance}")

  @impl true
  def handle_cast(_msg, _balance), do: raise("TODO: handle {:deposit, amount}")

  @impl true
  def handle_call(_msg, _from, _balance),
    do: raise("TODO: handle {:withdraw, amount} with a guard, and :balance")
end
```

Test (`lessons/15-genserver-1/exercises/test/bank_account_test.exs`):

```elixir
defmodule BankAccountTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "deposit increases the balance" do
    {:ok, pid} = BankAccount.start_link(0)
    BankAccount.deposit(pid, 100)
    assert BankAccount.balance(pid) == 100
  end

  @tag :pending
  test "withdraw within balance succeeds" do
    {:ok, pid} = BankAccount.start_link(100)
    assert BankAccount.withdraw(pid, 30) == {:ok, 70}
    assert BankAccount.balance(pid) == 70
  end

  @tag :pending
  test "withdraw beyond balance fails and leaves the balance unchanged" do
    {:ok, pid} = BankAccount.start_link(50)
    assert BankAccount.withdraw(pid, 100) == {:error, :insufficient_funds}
    assert BankAccount.balance(pid) == 50
  end
end
```

Solution (`lessons/15-genserver-1/solutions/lib/bank_account.ex`):

```elixir
defmodule BankAccount do
  @moduledoc "A GenServer bank account with deposit/withdraw/balance."
  use GenServer

  def start_link(initial \\ 0), do: GenServer.start_link(__MODULE__, initial)
  def deposit(pid, amount), do: GenServer.cast(pid, {:deposit, amount})
  def withdraw(pid, amount), do: GenServer.call(pid, {:withdraw, amount})
  def balance(pid), do: GenServer.call(pid, :balance)

  @impl true
  def init(balance), do: {:ok, balance}

  @impl true
  def handle_cast({:deposit, amount}, balance), do: {:noreply, balance + amount}

  @impl true
  def handle_call({:withdraw, amount}, _from, balance) when amount <= balance do
    {:reply, {:ok, balance - amount}, balance - amount}
  end

  def handle_call({:withdraw, _amount}, _from, balance) do
    {:reply, {:error, :insufficient_funds}, balance}
  end

  def handle_call(:balance, _from, balance), do: {:reply, balance, balance}
end
```

`cp` test file.

### Step 8: Verify and commit

```bash
cd lessons/15-genserver-1/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `9 tests, 0 failures` (Counter 3 + StackServer 3 + BankAccount 3).

```bash
git add lessons/15-genserver-1
git commit -m "Add lesson 15-genserver-1: init, handle_call, handle_cast

Three drills: Counter (cast inc/reset, call get), StackServer
(push/pop/peek with {:ok, _} / {:error, :empty}), BankAccount
(deposit cast, withdraw call with a guard, balance call). Exercise
stubs ship the full client API and stub only the callbacks — the
callbacks are the drill. README frames GenServer as the lesson-13
receive loop, standardised. Slides have four concept blocks under
the cap.

Solutions green: 9 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Lesson 16 — `genserver-2`

**Files:** scaffold; replace prose; drills `ticker.ex`, `idle_timer.ex` + tests.

### Step 1: Scaffold

```bash
tools/new-lesson 16-genserver-2
```

### Step 2: README (600–900 words)

1. Hook: "By the end of this lesson, you'll handle messages that don't come through `call`/`cast` — periodic ticks, timeouts — and you'll test GenServers the idiomatic way with `start_supervised!`."
2. `## Key ideas`:
   - **Recall from lesson 15:** `handle_call` and `handle_cast` handle messages *you* send through the client API. `handle_info/2` handles everything else — raw messages, timer ticks, monitor notifications.
   - **`Process.send_after/3`** schedules a message to yourself after a delay. Combined with `handle_info`, it's how a GenServer does periodic work.
   - **GenServer timeouts.** Returning `{:noreply, state, timeout}` (or `{:reply, reply, state, timeout}`) tells OTP "if no message arrives within `timeout` ms, send me a `:timeout` message." Handle it in `handle_info(:timeout, state)`.
   - **Testing GenServers with `start_supervised!/1`.** ExUnit starts the server under its own supervisor and tears it down between tests — each test gets a fresh server, no manual cleanup.
3. `## Try it in IEx` — schedule a self-message with `Process.send_after(self(), :tick, 100)` then `receive`.
4. `## How to work this lesson` — standard; note both drills test with `start_supervised!`.
5. `## Common mistakes`:
   - Forgetting to reschedule. A `handle_info(:tick, ...)` that doesn't call `Process.send_after` again only ticks once.
   - Using `Process.sleep` in a `handle_*` callback. It blocks the whole server — every other message waits. Schedule a message instead.
   - Testing with raw `Process.sleep` and exact assertions. Timing is fuzzy; assert a lower bound (`>= 2 ticks`) not an exact count.
6. `## Going further`:
   - What's `handle_continue/2` for? When is it better than doing work in `init/1`?
   - How would you make the `Ticker` interval configurable at runtime?
7. `## Links`: [HexDocs — GenServer (handle_info)](https://hexdocs.pm/elixir/GenServer.html#c:handle_info/2)

### Step 3: HINTS — two sections.

### Step 4: slides — 4 concept blocks: "handle_info", "Process.send_after & periodic work", "GenServer timeouts", "Testing with start_supervised!". Closer → lesson 17.

### Step 5: Drill 1 — `Ticker`

Exercise (`lessons/16-genserver-2/exercises/lib/ticker.ex`):

```elixir
defmodule Ticker do
  @moduledoc "A GenServer that increments a counter every interval ms."
  use GenServer

  def start_link(opts \\ []) do
    {interval, gen_opts} = Keyword.pop(opts, :interval, 100)
    GenServer.start_link(__MODULE__, interval, gen_opts)
  end

  def count(pid), do: GenServer.call(pid, :count)

  @impl true
  def init(_interval), do: raise("TODO: schedule the first tick, return {:ok, %{count: 0, interval: interval}}")

  @impl true
  def handle_info(_msg, _state), do: raise("TODO: increment count, reschedule the next tick")

  @impl true
  def handle_call(:count, _from, state), do: {:reply, state.count, state}
end
```

Test (`lessons/16-genserver-2/exercises/test/ticker_test.exs`):

```elixir
defmodule TickerTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "advances the counter over time" do
    pid = start_supervised!({Ticker, interval: 20})
    Process.sleep(70)
    # at least 2 ticks should have fired in 70ms at a 20ms interval
    assert Ticker.count(pid) >= 2
  end

  @tag :pending
  test "starts at zero" do
    pid = start_supervised!({Ticker, interval: 10_000})
    assert Ticker.count(pid) == 0
  end
end
```

Solution (`lessons/16-genserver-2/solutions/lib/ticker.ex`):

```elixir
defmodule Ticker do
  @moduledoc "A GenServer that increments a counter every interval ms."
  use GenServer

  def start_link(opts \\ []) do
    {interval, gen_opts} = Keyword.pop(opts, :interval, 100)
    GenServer.start_link(__MODULE__, interval, gen_opts)
  end

  def count(pid), do: GenServer.call(pid, :count)

  @impl true
  def init(interval) do
    schedule(interval)
    {:ok, %{count: 0, interval: interval}}
  end

  @impl true
  def handle_info(:tick, state) do
    schedule(state.interval)
    {:noreply, %{state | count: state.count + 1}}
  end

  @impl true
  def handle_call(:count, _from, state), do: {:reply, state.count, state}

  defp schedule(interval), do: Process.send_after(self(), :tick, interval)
end
```

`cp` test file.

### Step 6: Drill 2 — `IdleTimer`

Exercise (`lessons/16-genserver-2/exercises/lib/idle_timer.ex`):

```elixir
defmodule IdleTimer do
  @moduledoc "A GenServer that flips to :idle after a period of inactivity."
  use GenServer

  def start_link(opts \\ []) do
    {timeout, gen_opts} = Keyword.pop(opts, :timeout, 50)
    GenServer.start_link(__MODULE__, timeout, gen_opts)
  end

  def touch(pid), do: GenServer.cast(pid, :touch)
  def status(pid), do: GenServer.call(pid, :status)

  @impl true
  def init(_timeout),
    do: raise("TODO: return {:ok, %{status: :active, timeout: timeout}, timeout}")

  @impl true
  def handle_cast(:touch, _state), do: raise("TODO: set status :active, return with timeout")

  @impl true
  def handle_call(:status, _from, _state), do: raise("TODO: reply status, return with timeout")

  @impl true
  def handle_info(:timeout, _state), do: raise("TODO: set status :idle")
end
```

Test (`lessons/16-genserver-2/exercises/test/idle_timer_test.exs`):

```elixir
defmodule IdleTimerTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "starts active" do
    pid = start_supervised!({IdleTimer, timeout: 10_000})
    assert IdleTimer.status(pid) == :active
  end

  @tag :pending
  test "becomes idle after the timeout elapses" do
    pid = start_supervised!({IdleTimer, timeout: 30})
    Process.sleep(70)
    assert IdleTimer.status(pid) == :idle
  end
end
```

Solution (`lessons/16-genserver-2/solutions/lib/idle_timer.ex`):

```elixir
defmodule IdleTimer do
  @moduledoc "A GenServer that flips to :idle after a period of inactivity."
  use GenServer

  def start_link(opts \\ []) do
    {timeout, gen_opts} = Keyword.pop(opts, :timeout, 50)
    GenServer.start_link(__MODULE__, timeout, gen_opts)
  end

  def touch(pid), do: GenServer.cast(pid, :touch)
  def status(pid), do: GenServer.call(pid, :status)

  @impl true
  def init(timeout), do: {:ok, %{status: :active, timeout: timeout}, timeout}

  @impl true
  def handle_cast(:touch, state), do: {:noreply, %{state | status: :active}, state.timeout}

  @impl true
  def handle_call(:status, _from, state), do: {:reply, state.status, state, state.timeout}

  @impl true
  def handle_info(:timeout, state), do: {:noreply, %{state | status: :idle}}
end
```

`cp` test file.

NOTE TO IMPLEMENTER: in the "starts active" test, use a large timeout (10_000) so the timeout doesn't fire before `status/1` is called. In the "becomes idle" test, the 30ms timeout fires at ~30ms and `handle_info(:timeout, …)` flips to `:idle` (returning `{:noreply, state}` with NO timeout, so it won't re-arm). At 70ms we read `:idle`. Verify the timing margin holds in CI; if flaky, widen the sleep.

### Step 7: Verify and commit

```bash
cd lessons/16-genserver-2/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `4 tests, 0 failures` (Ticker 2 + IdleTimer 2).

```bash
git add lessons/16-genserver-2
git commit -m "Add lesson 16-genserver-2: handle_info, send_after, timeouts, testing

Two drills: Ticker (periodic self-message via Process.send_after +
handle_info, tested with start_supervised! and a lower-bound count
assertion) and IdleTimer (GenServer timeout return value flips the
server to :idle after inactivity). README covers handle_info,
scheduling self-messages, the timeout return tuple, and testing with
start_supervised!. Slides have four concept blocks under the cap.

Solutions green: 4 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Lesson 17 — `supervisors`

**Files:** scaffold; replace prose; drills `sup_counter.ex` + `simple_sup.ex`, `worker.ex` + `all_for_one_sup.ex` + tests.

### Step 1: Scaffold

```bash
tools/new-lesson 17-supervisors
```

### Step 2: README (600–900 words)

1. Hook: "By the end of this lesson, you'll build supervision trees — the OTP machinery that restarts crashed processes automatically. This is where 'let it crash' becomes a feature, not a bug."
2. `## Key ideas`:
   - **Recall from lessons 15/16:** you built GenServers. A supervisor's only job is to start child processes and restart them when they crash.
   - **`Supervisor` + child specs.** A supervisor is started with a list of children. Each child is specified by a module (which provides a `child_spec/1`) or an explicit spec map.
   - **Restart strategies.** `:one_for_one` (default) — restart only the crashed child. `:one_for_all` — restart all children when any crashes. `:rest_for_one` — restart the crashed child and any started after it.
   - **Restart types.** `:permanent` (always restart, the default), `:temporary` (never), `:transient` (only on abnormal exit).
   - **Named processes.** Children registered with `name: __MODULE__` can be found with `Process.whereis/1`. After a restart the name points at a *new* pid — that's how you observe a restart happened.
   - **Naming brief: `Registry`** is mentioned as the scalable way to name many dynamic processes; not drilled here.
3. `## Try it in IEx` — start a supervisor with a child, `Process.whereis`, kill it, `Process.whereis` again (new pid).
4. `## How to work this lesson` — note: tests kill a process and poll for the restart.
5. `## Common mistakes`:
   - Expecting state to survive a restart. It doesn't — the child restarts fresh from `init`. (Persisting state needs ETS or external storage — lesson 19.)
   - Setting a child `:temporary` and wondering why it doesn't restart.
   - A crash loop: if a child keeps crashing, the supervisor gives up after `max_restarts` (default 3 in 5 seconds) and crashes itself.
6. `## Going further`:
   - What's `DynamicSupervisor` for? When do you reach for it over a static child list?
   - Read about `:rest_for_one` — sketch a dependency where it's the right strategy.
7. `## Links`: [HexDocs — Supervisor](https://hexdocs.pm/elixir/Supervisor.html)

### Step 3: HINTS — two sections.

### Step 4: slides — 4 concept blocks: "What a supervisor does", "Child specs & strategies", "Watching a restart", "State doesn't survive". Closer → lesson 18.

### Step 5: Drill 1 — `SupCounter` + `SimpleSup`

Exercise (`lessons/17-supervisors/exercises/lib/sup_counter.ex`) — a complete named counter, NOT stubbed (it's supporting cast for the supervisor drill; the supervisor is the thing being learned):

```elixir
defmodule SupCounter do
  @moduledoc "A named counter GenServer, supervised in lesson 17."
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  def inc, do: GenServer.cast(__MODULE__, :inc)
  def get, do: GenServer.call(__MODULE__, :get)

  @impl true
  def init(count), do: {:ok, count}

  @impl true
  def handle_cast(:inc, count), do: {:noreply, count + 1}

  @impl true
  def handle_call(:get, _from, count), do: {:reply, count, count}
end
```

Exercise (`lessons/17-supervisors/exercises/lib/simple_sup.ex`) — the drill, stubbed:

```elixir
defmodule SimpleSup do
  @moduledoc "A one_for_one supervisor over a single SupCounter."
  use Supervisor

  def start_link(_opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok), do: raise("TODO: Supervisor.init([SupCounter], strategy: :one_for_one)")
end
```

Test (`lessons/17-supervisors/exercises/test/simple_sup_test.exs`):

```elixir
defmodule SimpleSupTest do
  # async: false — SupCounter registers under a fixed name, so parallel
  # tests would collide on it.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(SimpleSup)
    :ok
  end

  @tag :pending
  test "restarts the counter with fresh state after a crash" do
    SupCounter.inc()
    assert SupCounter.get() == 1

    old_pid = Process.whereis(SupCounter)
    Process.exit(old_pid, :kill)

    new_pid = wait_for_new_pid(SupCounter, old_pid)
    assert new_pid != old_pid
    assert SupCounter.get() == 0
  end

  defp wait_for_new_pid(name, old_pid, attempts \\ 100)
  defp wait_for_new_pid(_name, _old_pid, 0), do: flunk("process did not restart")

  defp wait_for_new_pid(name, old_pid, attempts) do
    case Process.whereis(name) do
      nil ->
        Process.sleep(10)
        wait_for_new_pid(name, old_pid, attempts - 1)

      ^old_pid ->
        Process.sleep(10)
        wait_for_new_pid(name, old_pid, attempts - 1)

      new_pid ->
        new_pid
    end
  end
end
```

Solution (`lessons/17-supervisors/solutions/lib/sup_counter.ex`) — identical to the exercise SupCounter (it's not stubbed). Solution (`lessons/17-supervisors/solutions/lib/simple_sup.ex`):

```elixir
defmodule SimpleSup do
  @moduledoc "A one_for_one supervisor over a single SupCounter."
  use Supervisor

  def start_link(_opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok) do
    children = [SupCounter]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

`cp` test file. NOTE: `sup_counter.ex` is identical in exercises and solutions — copy it across too.

### Step 6: Drill 2 — `Worker` + `AllForOneSup`

Exercise (`lessons/17-supervisors/exercises/lib/worker.ex`) — complete, not stubbed:

```elixir
defmodule Worker do
  @moduledoc "A trivial GenServer worker used to demo supervision strategies."
  use GenServer

  def start_link(name), do: GenServer.start_link(__MODULE__, name, name: name)

  @impl true
  def init(name), do: {:ok, name}
end
```

Exercise (`lessons/17-supervisors/exercises/lib/all_for_one_sup.ex`) — the drill, stubbed:

```elixir
defmodule AllForOneSup do
  @moduledoc "A one_for_all supervisor over three named workers."
  use Supervisor

  def start_link(_opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok),
    do: raise("TODO: three Worker children (ids :worker_a/b/c), strategy :one_for_all")
end
```

Test (`lessons/17-supervisors/exercises/test/all_for_one_sup_test.exs`):

```elixir
defmodule AllForOneSupTest do
  # async: false — workers register under fixed names.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(AllForOneSup)
    :ok
  end

  @tag :pending
  test "killing one worker restarts all three (one_for_all)" do
    a1 = Process.whereis(:worker_a)
    b1 = Process.whereis(:worker_b)
    c1 = Process.whereis(:worker_c)

    Process.exit(a1, :kill)

    assert wait_until_all_changed(%{worker_a: a1, worker_b: b1, worker_c: c1})
  end

  defp wait_until_all_changed(olds, attempts \\ 100)
  defp wait_until_all_changed(_olds, 0), do: flunk("workers did not all restart")

  defp wait_until_all_changed(olds, attempts) do
    all_changed? =
      Enum.all?(olds, fn {name, old} ->
        pid = Process.whereis(name)
        is_pid(pid) and pid != old
      end)

    if all_changed? do
      true
    else
      Process.sleep(10)
      wait_until_all_changed(olds, attempts - 1)
    end
  end
end
```

Solution (`lessons/17-supervisors/solutions/lib/worker.ex`) — identical to exercise. Solution (`lessons/17-supervisors/solutions/lib/all_for_one_sup.ex`):

```elixir
defmodule AllForOneSup do
  @moduledoc "A one_for_all supervisor over three named workers."
  use Supervisor

  def start_link(_opts \\ []), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  @impl true
  def init(:ok) do
    children = [
      Supervisor.child_spec({Worker, :worker_a}, id: :worker_a),
      Supervisor.child_spec({Worker, :worker_b}, id: :worker_b),
      Supervisor.child_spec({Worker, :worker_c}, id: :worker_c)
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
```

`cp` test file; copy `worker.ex` across.

### Step 7: Verify and commit

```bash
cd lessons/17-supervisors/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `2 tests, 0 failures` (SimpleSup 1 + AllForOneSup 1).

```bash
git add lessons/17-supervisors
git commit -m "Add lesson 17-supervisors: supervision trees and restart strategies

Two drills: SimpleSup (one_for_one over a named SupCounter; test kills
the counter and polls Process.whereis until a fresh pid with reset
state appears) and AllForOneSup (one_for_all over three named Workers;
test kills one and asserts all three pids change). Support modules
(SupCounter, Worker) ship complete; the supervisor init/1 is the drill.
Tests use async: false because of named processes. README frames
let-it-crash as a feature and warns that state doesn't survive a
restart (setting up lesson 19's ETS).

Solutions green: 2 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Lesson 18 — `otp-applications` (Phase 2 capstone)

**Files:** scaffold; replace prose; hand-edit `mix.exs` to add `mod:`; drills `mini_cache/server.ex`, `mini_cache/application.ex`, `mini_cache.ex` + tests.

### Step 1: Scaffold

```bash
tools/new-lesson 18-otp-applications
```

### Step 2: Hand-edit `mix.exs` in BOTH exercises and solutions

Change the `application/0` function to add the `mod:` entry. Final `application/0` (both):

```elixir
def application do
  [
    extra_applications: [:logger],
    mod: {MiniCache.Application, []}
  ]
end
```

Leave the rest of `mix.exs` (the `project/0`, `deps/0`) as the template generated them.

### Step 3: README (700–1000 words)

1. Hook: "By the end of this lesson, you'll have shipped `MiniCache` — a supervised in-memory key-value cache that starts automatically when your app boots. This is a real OTP application, the same shape as Phoenix and every Elixir library."
2. `## Key ideas`:
   - **Recall from lessons 15/16/17:** a GenServer holds state; a Supervisor keeps it alive. An OTP *application* bundles them so they start automatically when you run `iex -S mix` or boot a release.
   - **The `mod:` entry in mix.exs.** `mod: {MiniCache.Application, []}` tells the BEAM "when this app starts, call `MiniCache.Application.start/2`."
   - **The Application callback.** `MiniCache.Application.start/2` starts the top supervisor with its children.
   - **Layered API.** `MiniCache.Server` is the GenServer (callbacks, named). `MiniCache` is the thin public API that delegates to it. Callers use `MiniCache.put/2` and never touch the Server directly.
   - **Restart resets the cache.** Because the cache lives in the GenServer's state (not ETS yet), killing the Server loses the data — the supervisor restarts an empty one. Lesson 19 fixes this with ETS.
3. `## Try it in IEx` — `iex -S mix`, then `MiniCache.put("hello", :world)`, `MiniCache.get("hello")`, `MiniCache.size()`.
4. `## How to work this lesson` — the three drills build the app bottom-up; the final step is `iex -S mix` and using it.
5. `## Common mistakes`:
   - Forgetting the `mod:` entry — the app compiles but nothing starts; `MiniCache.get/1` fails with "no process."
   - Calling the Server directly instead of through the public API. The whole point of the `MiniCache` module is a clean front door.
   - Expecting cache data to survive `iex` restarts or crashes. It won't (yet).
6. `## Going further`:
   - Add a TTL (time-to-live) so entries expire. Hint: store `{value, inserted_at}` and check on `get`.
   - Make the cache survive a Server crash. Hint: that's lesson 19 (ETS).
7. `## Links`: [HexDocs — Application](https://hexdocs.pm/elixir/Application.html), [Mix — application config](https://hexdocs.pm/mix/Mix.Tasks.Compile.App.html)

### Step 4: HINTS — three sections (one per drill).

### Step 5: slides — 4 concept blocks: "What's an OTP application", "The mod: callback", "Server + Supervisor + public API", "Run it & the restart-resets-state caveat". Closer → lesson 19.

### Step 6: Drill 1 — `MiniCache.Server`

Exercise (`lessons/18-otp-applications/exercises/lib/mini_cache/server.ex`):

```elixir
defmodule MiniCache.Server do
  @moduledoc "GenServer holding the cache state as a map."
  use GenServer

  # Client API — done for you.
  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def delete(key), do: GenServer.cast(__MODULE__, {:delete, key})
  def size, do: GenServer.call(__MODULE__, :size)

  # Callbacks — implement these.
  @impl true
  def init(_state), do: raise("TODO: return {:ok, %{}}")

  @impl true
  def handle_cast(_msg, _state), do: raise("TODO: handle {:put, k, v} and {:delete, k}")

  @impl true
  def handle_call(_msg, _from, _state), do: raise("TODO: handle {:get, k} and :size")
end
```

Solution (`lessons/18-otp-applications/solutions/lib/mini_cache/server.ex`):

```elixir
defmodule MiniCache.Server do
  @moduledoc "GenServer holding the cache state as a map."
  use GenServer

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def delete(key), do: GenServer.cast(__MODULE__, {:delete, key})
  def size, do: GenServer.call(__MODULE__, :size)

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:put, key, value}, state), do: {:noreply, Map.put(state, key, value)}
  def handle_cast({:delete, key}, state), do: {:noreply, Map.delete(state, key)}

  @impl true
  def handle_call({:get, key}, _from, state), do: {:reply, Map.get(state, key), state}
  def handle_call(:size, _from, state), do: {:reply, map_size(state), state}
end
```

(No standalone test for the Server — it's tested via the public API in drill 3.)

### Step 7: Drill 2 — `MiniCache.Application`

Exercise (`lessons/18-otp-applications/exercises/lib/mini_cache/application.ex`):

```elixir
defmodule MiniCache.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args),
    do: raise("TODO: Supervisor.start_link([MiniCache.Server], strategy: :one_for_one, name: MiniCache.Supervisor)")
end
```

Solution (`lessons/18-otp-applications/solutions/lib/mini_cache/application.ex`):

```elixir
defmodule MiniCache.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [MiniCache.Server]
    Supervisor.start_link(children, strategy: :one_for_one, name: MiniCache.Supervisor)
  end
end
```

### Step 8: Drill 3 — `MiniCache` public API + integration test

Exercise (`lessons/18-otp-applications/exercises/lib/mini_cache.ex`):

```elixir
defmodule MiniCache do
  @moduledoc "Public API for the supervised in-memory cache."

  @doc "Store value under key."
  def put(_key, _value), do: raise("TODO: delegate to MiniCache.Server.put/2")

  @doc "Fetch the value for key, or nil."
  def get(_key), do: raise("TODO: delegate to MiniCache.Server.get/1")

  @doc "Remove key from the cache."
  def delete(_key), do: raise("TODO: delegate to MiniCache.Server.delete/1")

  @doc "Return the number of entries."
  def size, do: raise("TODO: delegate to MiniCache.Server.size/0")
end
```

Test (`lessons/18-otp-applications/exercises/test/mini_cache_test.exs`):

```elixir
defmodule MiniCacheTest do
  # async: false — MiniCache.Server is a singleton named process started
  # by the application; tests share it, so they must not run in parallel.
  use ExUnit.Case, async: false

  setup do
    # Clear any leftover state from a prior test.
    for key <- [:a, :b, :c], do: MiniCache.delete(key)
    :ok
  end

  @tag :pending
  test "put then get round-trips a value" do
    MiniCache.put(:a, 1)
    assert MiniCache.get(:a) == 1
  end

  @tag :pending
  test "get returns nil for a missing key" do
    assert MiniCache.get(:missing) == nil
  end

  @tag :pending
  test "delete removes a key" do
    MiniCache.put(:b, 2)
    MiniCache.delete(:b)
    assert MiniCache.get(:b) == nil
  end

  @tag :pending
  test "size reflects the number of stored keys" do
    MiniCache.put(:a, 1)
    MiniCache.put(:c, 3)
    assert MiniCache.size() >= 2
  end

  @tag :pending
  test "the cache empties after the Server is killed and restarted" do
    MiniCache.put(:a, 1)
    assert MiniCache.get(:a) == 1

    old_pid = Process.whereis(MiniCache.Server)
    Process.exit(old_pid, :kill)
    wait_for_new_pid(MiniCache.Server, old_pid)

    assert MiniCache.get(:a) == nil
  end

  defp wait_for_new_pid(name, old_pid, attempts \\ 100)
  defp wait_for_new_pid(_name, _old_pid, 0), do: flunk("server did not restart")

  defp wait_for_new_pid(name, old_pid, attempts) do
    case Process.whereis(name) do
      nil ->
        Process.sleep(10)
        wait_for_new_pid(name, old_pid, attempts - 1)

      ^old_pid ->
        Process.sleep(10)
        wait_for_new_pid(name, old_pid, attempts - 1)

      new_pid ->
        new_pid
    end
  end
end
```

Solution (`lessons/18-otp-applications/solutions/lib/mini_cache.ex`):

```elixir
defmodule MiniCache do
  @moduledoc "Public API for the supervised in-memory cache."
  alias MiniCache.Server

  defdelegate put(key, value), to: Server
  defdelegate get(key), to: Server
  defdelegate delete(key), to: Server
  defdelegate size, to: Server
end
```

`cp` test file.

NOTE TO IMPLEMENTER: because `MiniCache.Server` is started by the application (via the `mod:` entry) when the test VM boots, it's already running during tests — no `start_supervised!` needed. The "killed and restarted" test relies on the *application's* supervisor restarting it. Confirm the app is configured to start (the `mod:` entry from Step 2). The `delete`-in-setup keeps tests order-independent despite the shared singleton.

### Step 9: Verify the app runs + commit

```bash
cd lessons/18-otp-applications/solutions && mix deps.get && mix test --include pending; cd -
```

Expected: `5 tests, 0 failures`.

```bash
cd lessons/18-otp-applications/solutions
echo 'MiniCache.put("hello", :world); IO.inspect(MiniCache.get("hello"))' | iex -S mix 2>&1 | grep -q ":world" && echo "DEMO OK"
cd -
```

Expected: prints `DEMO OK` (the app boots, the cache works).

```bash
tools/check-solutions
tools/lint-all
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist
grep -c 'lessons/18-otp-applications/slides/' dist/index.html
rm -rf dist
```

All pass; build_index `1`.

```bash
git add lessons/18-otp-applications
git commit -m "Add lesson 18-otp-applications: MiniCache capstone

Phase 2 capstone — a supervised in-memory cache. Three drills compose
into a working OTP application: MiniCache.Server (the GenServer),
MiniCache.Application (the start/2 callback + supervisor), and
MiniCache (the thin defdelegate public API). mix.exs hand-edited to
add mod: {MiniCache.Application, []} so the cache starts automatically
on boot.

The integration test exercises put/get/delete/size and the
empty-after-restart behaviour (cache state lives in the GenServer, so
a kill loses it — lesson 19 upgrades this to ETS). Tests use
async: false because the Server is an app-started singleton.

Solutions green: 5 tests, 0 failures. 'iex -S mix' boots the app and
MiniCache.put/get works.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Lesson 19 — `ets`

**Files:** scaffold; replace prose; drills `ets_cache.ex`, `atomic.ex` + tests.

### Step 1: Scaffold

```bash
tools/new-lesson 19-ets
```

### Step 2: README (600–900 words)

1. Hook: "By the end of this lesson, you'll store data in ETS — the BEAM's built-in in-memory tables — and you'll see why it beats a GenServer for read-heavy work."
2. `## Key ideas`:
   - **Recall from lesson 18:** MiniCache funnelled *every* read through one GenServer process. Under load, that one process is a bottleneck — reads queue up. ETS lets concurrent reads happen in parallel, skipping the process entirely.
   - **`:ets.new/2`** creates a table. Types: `:set` (one value per key), `:bag` (many), `:ordered_set` (sorted). Access: `:public` (anyone reads/writes), `:protected` (owner writes, others read), `:private`.
   - **`:ets.insert/2`, `:ets.lookup/2`, `:ets.delete/2`.** Tuples in, tuples out. `lookup` returns a list (`[{key, value}]` or `[]`).
   - **Table ownership.** A table is owned by the process that created it and dies with that process. So a GenServer typically owns the table; the data outlives individual requests but not the owner.
   - **Atomic operations.** `:ets.update_counter/3` increments a counter atomically — no read-modify-write race even under heavy concurrency.
3. `## Try it in IEx` — `:ets.new(:t, [:set, :public])`, insert, lookup, delete.
4. `## How to work this lesson` — note: `init/1` (which creates the table) is provided; the operations are the drill.
5. `## Common mistakes`:
   - Forgetting `lookup` returns a *list*. Pattern-match `[{key, value}]` for a hit, `[]` for a miss.
   - Using a `:private` table and wondering why another process can't read it.
   - Doing read-modify-write on a counter with `lookup` + `insert`. Two concurrent updates race. Use `:ets.update_counter/3`.
6. `## Going further`:
   - When would `:ordered_set` be worth the extra cost over `:set`?
   - How does an ETS-backed cache survive a GenServer crash where the lesson-18 version didn't? (Hint: it doesn't, unless the table has a heir — look up `:heir`.)
7. `## Links`: [Erlang — :ets](https://www.erlang.org/doc/man/ets.html), [Elixir — ETS guide](https://hexdocs.pm/elixir/erlang-term-storage.html)

### Step 3: HINTS — two sections.

### Step 4: slides — 4 concept blocks: "What ETS is & why", "Table types & access", "insert/lookup/delete", "Atomic update_counter". Closer → lesson 20.

### Step 5: Drill 1 — `ETSCache`

Exercise (`lessons/19-ets/exercises/lib/ets_cache.ex`) — init provided, operations stubbed:

```elixir
defmodule ETSCache do
  @moduledoc "A cache backed by a public ETS table owned by a GenServer."
  use GenServer

  @table :ets_cache

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc "Store value under key."
  def put(_key, _value), do: raise("TODO: :ets.insert(@table, {key, value})")

  @doc "Fetch the value for key, or nil."
  def get(_key), do: raise("TODO: :ets.lookup and match [{^key, value}] / []")

  @doc "Remove key from the table."
  def delete(_key), do: raise("TODO: :ets.delete(@table, key)")

  # init is provided — study how the table is created.
  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end
end
```

Test (`lessons/19-ets/exercises/test/ets_cache_test.exs`):

```elixir
defmodule ETSCacheTest do
  # async: false — named table + named server.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(ETSCache)
    :ok
  end

  @tag :pending
  test "put then get round-trips a value" do
    ETSCache.put(:a, 1)
    assert ETSCache.get(:a) == 1
  end

  @tag :pending
  test "get returns nil for a missing key" do
    assert ETSCache.get(:missing) == nil
  end

  @tag :pending
  test "delete removes a key" do
    ETSCache.put(:b, 2)
    ETSCache.delete(:b)
    assert ETSCache.get(:b) == nil
  end
end
```

Solution (`lessons/19-ets/solutions/lib/ets_cache.ex`):

```elixir
defmodule ETSCache do
  @moduledoc "A cache backed by a public ETS table owned by a GenServer."
  use GenServer

  @table :ets_cache

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc "Store value under key."
  def put(key, value), do: :ets.insert(@table, {key, value})

  @doc "Fetch the value for key, or nil."
  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  @doc "Remove key from the table."
  def delete(key), do: :ets.delete(@table, key)

  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end
end
```

`cp` test file.

### Step 6: Drill 2 — `Atomic`

Exercise (`lessons/19-ets/exercises/lib/atomic.ex`):

```elixir
defmodule Atomic do
  @moduledoc "Atomic counters via :ets.update_counter."
  use GenServer

  @table :atomic_counters

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Atomically add `by` to the counter at `key`, returning the new value.
  Missing keys start at 0.
  """
  def bump(_key, _by \\ 1), do: raise("TODO: :ets.update_counter(@table, key, by, {key, 0})")

  @doc "Read the current value at key (0 if missing)."
  def value(_key), do: raise("TODO: :ets.lookup; [{^key, v}] -> v ; [] -> 0")

  # init provided.
  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end
end
```

Test (`lessons/19-ets/exercises/test/atomic_test.exs`):

```elixir
defmodule AtomicTest do
  # async: false — named table + named server.
  use ExUnit.Case, async: false

  setup do
    start_supervised!(Atomic)
    :ok
  end

  @tag :pending
  test "bump returns the new value" do
    assert Atomic.bump(:x, 5) == 5
    assert Atomic.bump(:x, 3) == 8
  end

  @tag :pending
  test "bump increments atomically under concurrency" do
    tasks = for _ <- 1..100, do: Task.async(fn -> Atomic.bump(:hits) end)
    Enum.each(tasks, &Task.await/1)
    assert Atomic.value(:hits) == 100
  end
end
```

Solution (`lessons/19-ets/solutions/lib/atomic.ex`):

```elixir
defmodule Atomic do
  @moduledoc "Atomic counters via :ets.update_counter."
  use GenServer

  @table :atomic_counters

  def start_link(_opts), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  @doc """
  Atomically add `by` to the counter at `key`, returning the new value.
  Missing keys start at 0.
  """
  def bump(key, by \\ 1), do: :ets.update_counter(@table, key, by, {key, 0})

  @doc "Read the current value at key (0 if missing)."
  def value(key) do
    case :ets.lookup(@table, key) do
      [{^key, v}] -> v
      [] -> 0
    end
  end

  @impl true
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end
end
```

`cp` test file.

### Step 7: Verify and commit

```bash
cd lessons/19-ets/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
```

Expected: `5 tests, 0 failures` (ETSCache 3 + Atomic 2).

```bash
git add lessons/19-ets
git commit -m "Add lesson 19-ets: in-memory tables, atomic counters

Two drills: ETSCache (the lesson-18 cache API backed by a :public
:named_table so concurrent reads skip the GenServer) and Atomic
(:ets.update_counter/3 with a concurrency test that spawns 100 tasks
and asserts the final count is exactly 100, proving atomicity). The
table-creating init/1 is provided in both drills; the operations are
the drill. README contrasts ETS with lesson 18's GenServer-as-store
bottleneck. Slides have four concept blocks under the cap.

Solutions green: 5 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Lesson 20 — `distribution`

**Files:** scaffold; replace prose; drill `localnode.ex` + test.

### Step 1: Scaffold

```bash
tools/new-lesson 20-distribution
```

### Step 2: README (600–900 words)

1. Hook: "By the end of this lesson, you'll understand how Elixir processes talk across machines. The drills run on a single node; a follow-the-steps demo shows two nodes talking — that part needs two terminals, not CI."
2. `## Key ideas`:
   - **Nodes.** A running BEAM instance is a *node*. Start one with a name: `iex --sname alice`. `Node.self/0` returns the current node's name; `Node.alive?/0` says whether distribution is on.
   - **Connecting nodes.** `Node.connect(:"bob@host")` links two nodes. `Node.list/0` shows who's connected. Nodes must share a *cookie* (`--cookie secret`) to connect.
   - **`:rpc.call/4`.** Run a function on another node: `:rpc.call(:"bob@host", IO, :inspect, ["hi"])`. The function runs *there*, the result comes back *here*.
   - **Global names.** `:global.register_name/2` registers a process under a name visible cluster-wide.
   - **`libcluster`** (mentioned, not used) automates node discovery and connection in production clusters.
3. `## Try it in IEx` — `Node.self()`, `Node.alive?()` (false in plain `iex`).
4. `## The two-node demo (follow along)` — explicit steps:
   - Terminal 1: `iex --sname alice --cookie mycourse`
   - Terminal 2: `iex --sname bob --cookie mycourse`
   - In alice: `Node.connect(:"bob@$(hostname -s)")` (use your actual short hostname; `Node.self()` shows the format).
   - In alice: `Node.list()` → `[:"bob@..."]`
   - In alice: `:rpc.call(:"bob@...", IO, :inspect, ["hi from alice"])` → prints in *bob's* terminal, returns the value in alice.
   - State explicitly: this is manual; CI can't run it.
5. `## How to work this lesson` — the Mix drills test single-node behaviour; do the two-node demo by hand.
6. `## Common mistakes`:
   - Different cookies → nodes silently won't connect.
   - Using `--sname` (short names, same host) vs `--name` (full names, across hosts) inconsistently — pick one.
   - Expecting `Node.alive?/0` to be true in a plain `iex` with no `--sname`. It's false until you name the node.
7. `## Going further`:
   - Read the `libcluster` README — what node-discovery strategies does it offer?
   - What's the security implication of a shared cookie? (Hint: cookie = full RCE on every connected node.)
8. `## Links`: [HexDocs — Node](https://hexdocs.pm/elixir/Node.html), [Erlang — :rpc](https://www.erlang.org/doc/man/rpc.html)

### Step 3: HINTS — one section (the single drill module), three hints.

### Step 4: slides — 4 concept blocks: "Nodes", "Connecting & cookies", "rpc.call", "The 2-node demo (manual)". Closer → "Phase 2 done. Phase 3 — Phoenix — next. `make slides-dev LESSON=21-plug`."

### Step 5: Drill — `Localnode`

Exercise (`lessons/20-distribution/exercises/lib/localnode.ex`):

```elixir
defmodule Localnode do
  @moduledoc "Single-node helpers introducing the Node and :rpc APIs."

  @doc """
  Return `{node_name, alive?}` for the current node.

      iex> {name, alive?} = Localnode.info()
      iex> is_atom(name) and is_boolean(alive?)
      true
  """
  def info, do: raise("TODO: {Node.self(), Node.alive?()}")

  @doc """
  Round-trip a message through :rpc against the current node. Returns
  the inspected string.

      iex> Localnode.echo_via_rpc(:hello)
      ":hello"
  """
  def echo_via_rpc(_msg), do: raise("TODO: :rpc.call(Node.self(), Kernel, :inspect, [msg])")
end
```

Test (`lessons/20-distribution/exercises/test/localnode_test.exs`):

```elixir
defmodule LocalnodeTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "info returns the node name and alive status" do
    {name, alive?} = Localnode.info()
    assert is_atom(name)
    assert is_boolean(alive?)
  end

  @tag :pending
  test "echo_via_rpc round-trips through :rpc.call on the current node" do
    assert Localnode.echo_via_rpc(:hello) == ":hello"
  end
end
```

Solution (`lessons/20-distribution/solutions/lib/localnode.ex`):

```elixir
defmodule Localnode do
  @moduledoc "Single-node helpers introducing the Node and :rpc APIs."

  @doc """
  Return `{node_name, alive?}` for the current node.

      iex> {name, alive?} = Localnode.info()
      iex> is_atom(name) and is_boolean(alive?)
      true
  """
  def info, do: {Node.self(), Node.alive?()}

  @doc """
  Round-trip a message through :rpc against the current node. Returns
  the inspected string.

      iex> Localnode.echo_via_rpc(:hello)
      ":hello"
  """
  def echo_via_rpc(msg), do: :rpc.call(Node.self(), Kernel, :inspect, [msg])
end
```

`cp` test file.

NOTE TO IMPLEMENTER (IMPORTANT): verify `:rpc.call(Node.self(), Kernel, :inspect, [:hello])` returns `":hello"` under a plain `mix test` (non-distributed node, where `Node.self()` is `:nonode@nohost`). The `:rpc` module short-circuits same-node calls, so this should work without distribution started. Run the solution test and confirm. If it returns `{:badrpc, :nodedown}` or similar on the CI's non-distributed node, change `echo_via_rpc/1` to use `:erpc.call(Node.self(), Kernel, :inspect, [msg])` (erpc also handles local calls) OR fall back to asserting the result equals `Kernel.inspect(msg)` via a direct local path. Do NOT ship a drill whose solution test fails on a non-distributed node.

### Step 6: Verify and commit

```bash
cd lessons/20-distribution/solutions && mix deps.get && mix test --include pending; cd -
tools/check-solutions
tools/lint-all
elixir tools/build_index/build_index.exs --lessons lessons --shared shared/reveal --out dist
grep -c 'lessons/20-distribution/slides/' dist/index.html
rm -rf dist
```

Expected: `2 tests, 0 failures`. build_index `1`.

```bash
git add lessons/20-distribution
git commit -m "Add lesson 20-distribution: nodes, rpc, and a 2-node demo

One Mix drill (Localnode.info/0 + echo_via_rpc/1) exercising the Node
and :rpc APIs on a single node, plus a follow-the-steps two-node demo
in the README and slides (iex --sname + cookie + Node.connect +
:rpc.call across terminals). The demo is explicitly manual — CI only
runs the single-node drill. Closes Phase 2 and points to Phase 3
(Phoenix). Slides have four concept blocks under the cap.

Solutions green: 2 tests, 0 failures.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 9: Final smoke + PR

### Step 1: Full pipeline

```bash
make ci-smoke
make solutions-test
make lint
make slides-build
```

Expected: all pass. Total Phase 0+1+2 ≈ 121 + 40 = ~161 tests.

### Step 2: Confirm all 21 lessons published

```bash
for n in 00-setup 01-values-and-types 02-pattern-matching 03-functions-and-modules \
         04-control-flow 05-recursion 06-enum-and-the-pipe 07-collections \
         08-strings-and-binaries 09-streams 10-structs-and-protocols \
         11-error-handling 12-mix-projects 13-processes 14-tasks-and-agents \
         15-genserver-1 16-genserver-2 17-supervisors 18-otp-applications \
         19-ets 20-distribution; do
  grep -q "lessons/$n/slides/" dist/index.html && echo "$n: PUBLISHED" || echo "$n: MISSING"
done
rm -rf dist
```

Expected: all 21 `PUBLISHED`.

### Step 3: Capstone demo

```bash
cd lessons/18-otp-applications/solutions
echo 'MiniCache.put("k", :v); IO.inspect(MiniCache.get("k"))' | iex -S mix 2>&1 | grep -q ":v" && echo "MINICACHE OK"
cd -
```

Expected: `MINICACHE OK`.

### Step 4: Push branch

```bash
git push -u origin plan-d-phase-2
```

### Step 5: Open PR

```bash
gh pr create --base main --head plan-d-phase-2 \
    --title "Plan D: Phase 2 lessons (13 processes through 20 distribution)" \
    --body "$(cat <<'EOF'
## Summary
- Implements [Plan D](docs/superpowers/plans/2026-05-28-plan-d-phase-2-lessons.md) — the eight Phase 2 lessons (concurrency & OTP).
- Lesson 18 is the capstone: `MiniCache`, a supervised in-memory cache (a real OTP application).
- After merge, https://elixir.ristkari.dev/ lights up the Phase 2 row.

## Drills shipped
- **13-processes** (3 drills, 6 tests): Echo, ProcessCounter, Linked.
- **14-tasks-and-agents** (3 drills, 7 tests): Parallel, KVAgent, Async.race.
- **15-genserver-1** (3 drills, 9 tests): Counter, StackServer, BankAccount.
- **16-genserver-2** (2 drills, 4 tests): Ticker, IdleTimer.
- **17-supervisors** (2 drills, 2 tests): SimpleSup (one_for_one), AllForOneSup (one_for_all).
- **18-otp-applications** (3 drills, 5 tests + working app): MiniCache.Server/Application/public-API. mix.exs adds mod: {MiniCache.Application, []}.
- **19-ets** (2 drills, 5 tests): ETSCache, Atomic (concurrency-proving counter).
- **20-distribution** (1 drill, 2 tests + manual 2-node demo): Localnode.

## Test plan
- [ ] CI green (lint, harness, exercises, solutions, slides-build, dist verification).
- [ ] After merge, Deploy republishes the slide site with lessons 13-20.
- [ ] `cd lessons/18-otp-applications/solutions && iex -S mix` then `MiniCache.put("k", :v); MiniCache.get("k")` returns `:v`.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 6: Watch CI, merge after review

```bash
gh pr checks --watch
```

If green and approved: `gh pr merge --squash --delete-branch` → triggers Deploy.

---

## Self-review checklist (already applied)

**Spec coverage:** every spec lesson maps to a task (13→T1, 14→T2, 15→T3, 16→T4, 17→T5, 18→T6, 19→T7, 20→T8). Phase 2 conventions (start_supervised!, assert_receive, restart-poll, async:false, --sup mix.exs mod:, no new deps) are all encoded in the relevant tasks. Capstone (MiniCache) is T6. Definition of done → T9.

**Placeholders:** none. Every drill has exact code. Two drills carry explicit IMPLEMENTER notes where a runtime detail must be verified (Async.race correctness; :rpc.call on a non-distributed node) — these are verification instructions, not placeholders, and each gives the exact code to ship.

**Type consistency:** module names match across exercises/solutions/HINTS/slides. The `MiniCache.Server`/`MiniCache.Application`/`MiniCache` namespace is consistent in T6. Named-process drills (SupCounter, Worker, MiniCache.Server, ETSCache, Atomic) consistently use `name: __MODULE__` and `async: false`. `start_supervised!` is used uniformly in T4/T5/T7 setups.
