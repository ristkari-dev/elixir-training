# Lesson 17: Supervisors

By the end of this lesson, you'll build supervision trees — the OTP machinery that restarts crashed processes automatically. This is where "let it crash" becomes a feature: a broken process dies, a supervisor starts a fresh one, and the system heals itself.

## Key ideas

Recall from lessons 15/16: you built GenServers that hold state. A supervisor's only job is to start child processes and restart them when they crash. It doesn't do business logic — it does resilience.

- **`Supervisor` + child specs.** A supervisor is started with a list of children. Each child is named by a module (which provides a `child_spec/1`) or an explicit spec. `use Supervisor` + `Supervisor.init(children, strategy: …)` is the usual shape.
- **Restart strategies.** `:one_for_one` (default) — restart only the crashed child. `:one_for_all` — restart *all* children when any one crashes. `:rest_for_one` — restart the crashed child and any started after it.
- **Restart types.** `:permanent` (always restart, the default), `:temporary` (never restart), `:transient` (restart only on an abnormal exit).
- **Named processes.** A child registered with `name: __MODULE__` can be found with `Process.whereis/1`. After a restart the name points at a *new* pid — that's how you observe that a restart happened.
- **`Registry`** (mentioned, not drilled) is the scalable way to name many dynamic processes; static names suffice for these drills.

> 💡 **First time seeing this?** A "supervision tree" is just supervisors supervising workers (and sometimes other supervisors). When you crash a worker, its supervisor notices the exit signal and starts a replacement. Your code never writes "try/rescue and restart" — the supervisor does it structurally.

## Try it in IEx

```
iex> {:ok, _sup} = SimpleSup.start_link()
iex> SupCounter.inc()
iex> SupCounter.get()
1
iex> Process.exit(Process.whereis(SupCounter), :kill)
iex> Process.sleep(50)
iex> SupCounter.get()
0
```

The counter came back after being killed — and its state reset to 0, because a restart starts fresh from `init`.

> 💡 **First time seeing this?** `Process.exit(pid, :kill)` is the unconditional "die now" signal — even a process trapping exits can't survive `:kill`. It's how tests simulate a crash so they can watch the supervisor restart the child.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=17-supervisors` from the repo root).
- `cd exercises && mix test --include pending`. The worker modules (`SupCounter`, `Worker`) are **provided** — you implement the supervisor `init/1`.
- Tests kill a process and poll `Process.whereis` until a new pid appears.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Expecting state to survive a restart. It doesn't — the child restarts fresh from `init`. Persisting state needs ETS or external storage (lesson 19).
- Setting a child `:temporary` and wondering why it doesn't restart. `:temporary` children are never restarted.
- A crash loop: if a child keeps crashing, the supervisor gives up after `max_restarts` (default 3 within 5 seconds) and crashes itself. That's intentional — endless restart of a doomed process helps no one.

## Going further

- What's `DynamicSupervisor` for? When do you reach for it over a static child list? (Hint: when children come and go at runtime.)
- Read about `:rest_for_one`. Sketch a dependency chain where it's the right strategy.

## Links

- [HexDocs — Supervisor](https://hexdocs.pm/elixir/Supervisor.html)
