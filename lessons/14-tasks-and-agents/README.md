# Lesson 14: Tasks and Agents

By the end of this lesson, you'll run work concurrently with `Task` and hold shared state with `Agent` — two friendly, batteries-included wrappers over the raw processes from lesson 13.

## Key ideas

Recall from lesson 13: spawning processes and passing messages by hand is powerful but verbose. `Task` and `Agent` package the two most common cases so you rarely write a raw `receive` loop.

- **`Task.async/1` + `Task.await/1`.** Run a function in a separate process and collect its result later. `task = Task.async(fn -> expensive() end)`; do other work; `Task.await(task)`. Good for "do these N independent things at once."
- **`Task.async_stream/3`.** Map a function over an enumerable with bounded concurrency. Returns a *stream* of `{:ok, result}` tuples (lazy — recall lesson 09). Ordered by default.
- **`Agent`.** A process that holds state you read and update with `Agent.get/2` and `Agent.update/2`. Good for "I want some shared mutable state but don't want to write a whole GenServer."
- **When to use which.** `Task` for fire-and-collect concurrency. `Agent` for simple shared state. GenServer (next lessons) when you need custom message handling, multiple operations, or anything beyond get/update.

> 💡 **First time seeing this?** "Concurrent" means several things are in flight at once. If three tasks each sleep 50ms, running them concurrently finishes in ~50ms total, not 150ms — they overlap. That's the whole point of `Task.async_stream`.

## Try it in IEx

```
iex> task = Task.async(fn -> 1 + 1 end)
iex> Task.await(task)
2
iex> {:ok, agent} = Agent.start_link(fn -> %{} end)
iex> Agent.update(agent, &Map.put(&1, :name, "Aki"))
:ok
iex> Agent.get(agent, &Map.get(&1, :name))
"Aki"
```

> 💡 **First time seeing this?** `Agent.update` takes a function that receives the current state and returns the new state. `Agent.get` takes a function that receives the state and returns whatever you want to read. The state never leaves the agent process except through these functions.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=14-tasks-and-agents` from the repo root).
- Open `iex` and play with `Task.async`/`await` and a small `Agent`.
- `cd exercises && mix test --include pending` — make the failing tests pass.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Forgetting to `Task.await`. The result is lost and you may leak the task process. Every `Task.async` should be awaited (or explicitly shut down).
- Using an `Agent` for complex logic. If the update functions get gnarly or you need to coordinate multiple operations, reach for a GenServer.
- Assuming `async_stream` runs unbounded. It caps concurrency at the number of schedulers by default (`:max_concurrency`). That's usually what you want.

## Going further

- `Task.async_stream/3` takes a `:max_concurrency` option. What's the default? When would you lower it (e.g., calling a rate-limited API)?
- When does `Agent` become the wrong tool and you should reach for `GenServer`? (Hint: when "get" and "update" stop being enough.)

## Links

- [HexDocs — Task](https://hexdocs.pm/elixir/Task.html)
- [HexDocs — Agent](https://hexdocs.pm/elixir/Agent.html)
