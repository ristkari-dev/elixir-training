# Lesson 15: GenServer I

By the end of this lesson, you'll write GenServers — the workhorse of OTP. A GenServer is the `ProcessCounter` loop from lesson 13, generalised and made bulletproof: you write a few callbacks, and OTP runs the receive loop for you.

## Key ideas

Recall from lesson 13: the hand-rolled `ProcessCounter` had a `receive` loop carrying state and a set of message shapes. GenServer is that exact pattern, standardised — you fill in callbacks, OTP handles the loop, timeouts, error reporting, and a dozen other details you'd otherwise get wrong.

- **The two halves of a GenServer.** The *client API* (public functions other code calls) and the *callbacks* (`init`, `handle_call`, `handle_cast`) that run inside the server process. Keep them visually separated in the module.
- **`call` vs `cast`.** `GenServer.call/2` is synchronous — it sends a message and waits for a reply. `GenServer.cast/2` is fire-and-forget — no reply. Use `call` when you need the answer (`get`), `cast` when you don't (`inc`).
- **`init/1`** sets the starting state and returns `{:ok, state}`. It runs inside the new process when `start_link` is called.
- **The callback return shapes.** `handle_call` returns `{:reply, reply, new_state}`. `handle_cast` returns `{:noreply, new_state}`. Getting these tuples right is most of the job.
- **A subtle guarantee:** messages to one GenServer are processed one at a time, in arrival order. A `cast` followed by a `call` to the same server means the cast is fully handled before the call returns — so tests need no `Process.sleep`.

> 💡 **First time seeing this?** `use GenServer` at the top of your module pulls in the OTP machinery and gives you sensible defaults. You override the callbacks you care about (`init`, `handle_call`, `handle_cast`). The `@impl true` annotation above each one tells the compiler "this is a behaviour callback" — it'll warn if you misspell one.

## Try it in IEx

```
iex> defmodule Mini do
...>   use GenServer
...>   def init(n), do: {:ok, n}
...>   def handle_call(:get, _from, n), do: {:reply, n, n}
...> end
iex> {:ok, pid} = GenServer.start_link(Mini, 42)
iex> GenServer.call(pid, :get)
42
```

> 💡 **First time seeing this?** The `_from` argument in `handle_call` is who's asking (a pid + ref). You rarely need it — OTP uses it to route the reply back automatically when you return `{:reply, …}`.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=15-genserver-1` from the repo root).
- `cd exercises && mix test --include pending`. The client API is **provided** — you implement the callbacks (`init`, `handle_cast`, `handle_call`).
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Putting business logic in the client API instead of the callback. The client API should just `call`/`cast`; the logic lives in `handle_*`.
- Forgetting `@impl true` on a callback. Not required, but it catches typos — a misspelled `handle_calll` would otherwise silently never run.
- Returning the wrong tuple shape. `handle_call` → `{:reply, reply, new_state}`; `handle_cast` → `{:noreply, new_state}`. A wrong shape crashes the server.

## Going further

- What happens if a `handle_call` takes longer than 5 seconds? (Hint: the default `call` timeout — the caller gets an exit.)
- Read about `GenServer.start_link/3`'s `:name` option. How do you call a server by name instead of carrying its pid around?

## Links

- [HexDocs — GenServer](https://hexdocs.pm/elixir/GenServer.html)
