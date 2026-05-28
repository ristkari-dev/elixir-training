# Lesson 14
## Tasks and Agents

Friendly wrappers over the raw processes from lesson 13.

---

## What we'll do

- Run work concurrently with `Task.async`/`await`.
- Map concurrently with `Task.async_stream`.
- Hold shared state with `Agent`.
- Know which tool fits which job.

---

## Task.async / await

Run a function in its own process; collect the result later.

--

### The basics

```
iex> task = Task.async(fn -> 1 + 1 end)
iex> Task.await(task)
2
```

`async` returns immediately with a task struct. `await` blocks until
the result is ready (default 5s timeout).

--

### Concurrency that overlaps

```elixir
a = Task.async(fn -> slow_thing() end)
b = Task.async(fn -> other_slow_thing() end)
{Task.await(a), Task.await(b)}
```

Both run at the same time. Two 50ms jobs finish in ~50ms, not 100ms.

--

### Common mistake

Forgetting to `await`. The result is lost and the task process may
leak. Every `async` gets an `await` (or an explicit shutdown).

---

## Task.async_stream

Map a function over a collection, concurrently, with a built-in
concurrency cap.

--

### The basics

```
iex> 1..5
...> |> Task.async_stream(fn n -> n * n end)
...> |> Enum.to_list()
[ok: 1, ok: 4, ok: 9, ok: 16, ok: 25]
```

Each result is wrapped `{:ok, value}`. It's a lazy stream (lesson 09) —
nothing runs until you consume it.

--

### Bounded concurrency

```elixir
urls
|> Task.async_stream(&fetch/1, max_concurrency: 10)
|> Enum.map(fn {:ok, body} -> body end)
```

Defaults to one task per scheduler. Lower `:max_concurrency` when
hitting a rate-limited service.

---

## Agent

A process that holds state, read and updated through functions.

--

### The basics

```
iex> {:ok, agent} = Agent.start_link(fn -> %{} end)
iex> Agent.update(agent, &Map.put(&1, :name, "Aki"))
:ok
iex> Agent.get(agent, &Map.get(&1, :name))
"Aki"
```

`update` takes `state -> new_state`. `get` takes `state -> value`.

--

### Common mistake

Reaching for an Agent when the logic gets complex. Agents are great
for "shared get/update." The moment you need multiple coordinated
operations or custom message handling, write a GenServer.

---

## Which tool when?

- **`Task`** — fire-and-collect concurrency. "Do these N things at once."
- **`Agent`** — simple shared state. "Hold this map; let me get/update it."
- **`GenServer`** (lessons 15-16) — anything richer: custom messages,
  multiple operations, lifecycle, timeouts.

All three are processes underneath. Pick the lightest one that fits.

---

## Next: lesson 15 — GenServer I

The workhorse of OTP. Your lesson-13 receive loop, standardised.

```
make slides-dev LESSON=15-genserver-1
```
