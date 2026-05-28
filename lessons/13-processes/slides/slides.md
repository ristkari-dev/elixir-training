# Lesson 13
## Processes

The steepest climb in the course. Tiny workers with mailboxes.

---

## What we'll do

- Spawn processes with `spawn`.
- Pass messages with `send` and `receive`.
- Keep state in a receive loop.
- Link processes and trap exits ("let it crash").

---

## Processes & spawn

A process is a tiny isolated worker: its own private state, its own
mailbox, no shared memory with anyone.

--

### The basics

```
iex> pid = spawn(fn -> IO.puts("hi from a process") end)
hi from a process
#PID<0.123.0>
```

`spawn` runs the function in a new process and returns its pid. The
process exits when its function finishes.

--

### Cheap and plentiful

```
iex> for _ <- 1..100_000, do: spawn(fn -> :ok end)
```

The BEAM runs millions of processes. They're not OS threads — they're
far lighter. Spawning one is cheap.

--

### Common mistake

Thinking a process shares memory with its parent. It doesn't —
everything is copied. That isolation is the whole point.

---

## send & receive

`send` drops a message in a mailbox. `receive` reads one out.

--

### The basics

```
iex> pid = spawn(fn -> receive do msg -> IO.inspect(msg) end end)
iex> send(pid, :hello)
:hello
:hello
```

`send` returns the message immediately. The process prints it when
`receive` matches.

--

### send is fire-and-forget

```
iex> send(pid, :anything)
:anything
```

You get the message back as the return value — NOT a reply. For a
reply, put `self()` in the message:

```elixir
send(pid, {self(), :ping})
receive do
  {:pong, _} -> :got_it
end
```

--

### receive blocks

```elixir
receive do
  {:wanted, x} -> x
after
  1000 -> :timed_out
end
```

A `receive` with no matching message waits forever. `after` adds a
timeout.

---

## State via a receive loop

A long-lived process "remembers" by recursing with new state.

--

### The pattern

```elixir
def start(initial), do: spawn(fn -> loop(initial) end)

defp loop(count) do
  receive do
    :inc -> loop(count + 1)
    {:get, from} ->
      send(from, {:count, count})
      loop(count)
  end
end
```

State is the loop's argument. "Updating" it means recursing with a new
value (recall lesson 05).

--

### Why this matters

This little loop IS what a GenServer does for you (lesson 15). Once you
see the pattern by hand, GenServer stops being magic.

---

## Links & let-it-crash

`spawn_link` ties two processes' fates together.

--

### Linked processes die together

```
iex> spawn_link(fn -> raise "boom" end)
** the caller crashes too
```

A linked crash propagates. Usually that's what you want — fail fast.

--

### Trapping exits

```elixir
Process.flag(:trap_exit, true)
spawn_link(fn -> raise "boom" end)
# caller receives {:EXIT, pid, reason} instead of dying
```

Trapping converts the exit signal into a message. This is how
supervisors (lesson 17) watch their children.

--

### "Let it crash"

Don't defensively rescue every error. Let a broken process die, and
have a supervisor start a fresh one. Isolation makes this safe — a
crash can't corrupt anyone else's state.

---

## Where this leads

Everything in OTP is processes + messages underneath:

- `Task` and `Agent` (lesson 14) wrap them.
- `GenServer` (lessons 15-16) is the receive loop, standardised.
- `Supervisor` (lesson 17) restarts crashed processes.

Get comfortable with spawn/send/receive and the rest of Phase 2 builds
naturally on top.

---

## Next: lesson 14 — Tasks and Agents

Friendlier wrappers over raw processes.

```
make slides-dev LESSON=14-tasks-and-agents
```
