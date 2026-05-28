# Lesson 13: Processes

By the end of this lesson, you'll spawn your own processes and pass messages between them — the foundation everything else in OTP is built on. This is the steepest new idea in the course; take it slowly, and lean on the analogy below until it clicks.

## Key ideas

- **A process is a tiny isolated worker.** It has its own private state (its "desk") and a mailbox. It can't see other processes' desks — the only way to interact is to send a message to a mailbox. Processes are cheap: the BEAM happily runs millions of them at once.
- **`spawn/1`** starts a process running a function and returns a pid (process id). The new process runs independently of the one that spawned it.
- **`send/2` and `receive`.** `send(pid, msg)` drops a message into a mailbox and returns immediately — it does not wait for a reply. `receive do … end` blocks until a message matching one of its patterns arrives. The mailbox is FIFO; `receive` scans it for the first matching pattern.
- **Keeping state with recursion.** A process that wants to "remember" something loops: it `receive`s a message, computes a new state, and calls its own loop function again with the new state. (Recall lesson 05's recursion — same shape, now driving a long-lived process.)
- **Links and "let it crash."** `spawn_link/1` ties two processes together — if one dies, the other gets an exit signal (and dies too, unless it traps exits with `Process.flag(:trap_exit, true)`). This is the seed of supervision (lesson 17): rather than defensively rescuing every possible error, you let a process crash and have something else restart it clean.

> 💡 **First time seeing this?** A "mailbox" is exactly what it sounds like — a queue of messages waiting to be read. Other processes drop messages in; this process reads them one at a time, oldest first. Nothing is shared; every message is *copied* in, so two processes can never corrupt each other's data.

## Try it in IEx

```
iex> pid = spawn(fn -> receive do msg -> IO.inspect(msg) end end)
#PID<0.123.0>
iex> send(pid, :hello)
:hello
:hello
```

The `send` returns `:hello` (its return value is always the message), and a moment later the spawned process prints `:hello` from its `receive`. After that one message the process exits — its function ran to completion.

> 💡 **First time seeing this?** `send` returning the message does NOT mean you got a reply. `send` is fire-and-forget. To get an answer back, you put `self()` (your own pid) inside the message so the other process knows where to send its reply, then you `receive` it.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=13-processes` from the repo root).
- Open `iex` and spawn a few processes. Send them messages. Watch what `receive` does.
- `cd exercises && mix test --include pending` — make the failing tests pass.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Expecting `send` to return a reply. It doesn't — it's fire-and-forget. To get a reply, include `self()` in the message and `receive` the answer.
- A `receive` with no matching clause blocks *forever*. Use `receive ... after 1000 -> …` to time out if that's a risk.
- Thinking processes share memory. They don't — everything in a message is copied. That isolation is what makes "let it crash" safe.

## Going further

- Read about `Process.monitor/1` — how does it differ from `Process.link/1`? (Hint: a monitor is one-directional and gives you a `:DOWN` message instead of an exit signal.)
- What does `receive ... after 0 -> …` do? When is checking the mailbox without blocking useful?

## Links

- [HexDocs — Process](https://hexdocs.pm/elixir/Process.html)
- [Elixir — Processes guide](https://hexdocs.pm/elixir/processes.html)
