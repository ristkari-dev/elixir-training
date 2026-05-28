# Lesson 18: OTP applications (Phase 2 capstone)

By the end of this lesson, you'll have shipped `MiniCache` — a supervised in-memory key-value cache that starts automatically when your app boots. This is a real OTP application, the same shape as Phoenix and every Elixir library on Hex.

## Key ideas

Recall from lessons 15/16/17: a GenServer holds state; a Supervisor keeps it alive. An OTP *application* bundles them so they start automatically when you run `iex -S mix` or boot a release — no manual `start_link` calls.

- **The `mod:` entry in `mix.exs`.** `mod: {MiniCache.Application, []}` in the `application/0` function tells the BEAM "when this app starts, call `MiniCache.Application.start/2`." That callback starts the top supervisor.
- **The Application callback.** `MiniCache.Application.start/2` starts the supervision tree with its children (here, just `MiniCache.Server`).
- **Layered API.** `MiniCache.Server` is the GenServer — callbacks, named, holds the map. `MiniCache` is the thin public API that delegates to it with `defdelegate`. Callers use `MiniCache.put/2`; they never touch the Server directly.
- **Restart resets the cache.** Because the cache lives in the GenServer's state (not ETS yet), killing the Server loses the data — the supervisor restarts an empty one. Lesson 19 fixes this with ETS, whose table outlives the process.

> 💡 **First time seeing this?** "Application" here is an OTP term, not "an app with a UI." It means a startable, stoppable unit of code with its own supervision tree. Your project is already an application; adding the `mod:` entry just gives it something to start on boot.

## Try it in IEx

```
iex -S mix
iex> MiniCache.put("hello", :world)
:ok
iex> MiniCache.get("hello")
:world
iex> MiniCache.size()
1
```

No `start_link` needed — the cache is already running because the application started it.

> 💡 **First time seeing this?** `iex -S mix` boots your Mix project (running the application's `start/2`) and drops you into IEx with everything loaded. Plain `iex` wouldn't start your app.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=18-otp-applications` from the repo root).
- The three drills build the app bottom-up: Server, then Application, then the public API.
- The `mix.exs` already has the `mod:` entry wired for you — study it.
- Final step: `cd solutions && iex -S mix`, then `MiniCache.put("k", :v)` and `MiniCache.get("k")`.
- Stuck? Open `HINTS.md` one hint at a time.

## Common mistakes

- Forgetting the `mod:` entry (it's already there for you) — without it, the app compiles but nothing starts, and `MiniCache.get/1` fails with "no process."
- Calling the Server directly instead of through the public API. The whole point of the `MiniCache` module is a clean front door.
- Expecting cache data to survive a Server crash or an `iex` restart. It won't — yet (lesson 19).

## Going further

- Add a TTL (time-to-live) so entries expire. Hint: store `{value, inserted_at}` and check on `get`.
- Make the cache survive a Server crash. Hint: that's lesson 19 — move the data into ETS.

## Links

- [HexDocs — Application](https://hexdocs.pm/elixir/Application.html)
- [Mix — application config](https://hexdocs.pm/mix/Mix.Tasks.Compile.App.html)
