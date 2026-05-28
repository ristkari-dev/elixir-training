# Lesson 17
## Supervisors

Restart crashed processes automatically. "Let it crash" as a feature.

---

## What we'll do

- See what a supervisor does (and doesn't) do.
- Write child specs and pick a strategy.
- Watch a process restart after a crash.
- Learn that state doesn't survive a restart.

---

## What a supervisor does

Its only job: start children and restart them when they crash.

--

### The shape

```elixir
defmodule SimpleSup do
  use Supervisor

  def start_link(_), do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    children = [SupCounter]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
```

--

### No business logic

A supervisor never does work itself. It starts workers, watches them,
restarts them. That separation — workers do work, supervisors do
resilience — is the heart of OTP.

---

## Child specs & strategies

How the supervisor knows what to start and what to do on a crash.

--

### Strategies

- `:one_for_one` — restart only the crashed child (the default).
- `:one_for_all` — restart all children when any one crashes.
- `:rest_for_one` — restart the crashed child and any started after it.

--

### Multiple children need ids

```elixir
children = [
  Supervisor.child_spec({Worker, :worker_a}, id: :worker_a),
  Supervisor.child_spec({Worker, :worker_b}, id: :worker_b)
]
```

You can't list the same module twice without giving each an `id:`.

--

### Restart types

- `:permanent` — always restart (default).
- `:temporary` — never restart.
- `:transient` — restart only on abnormal exit.

---

## Watching a restart

Named children let you observe the restart.

--

### Kill and re-find

```elixir
old = Process.whereis(SupCounter)
Process.exit(old, :kill)
# supervisor restarts it; the name now points at a NEW pid
new = Process.whereis(SupCounter)
new != old   # true
```

`Process.exit(pid, :kill)` is the unconditional crash signal.

--

### Testing the restart

```elixir
old_pid = Process.whereis(SupCounter)
Process.exit(old_pid, :kill)
new_pid = wait_for_new_pid(SupCounter, old_pid)
assert new_pid != old_pid
```

Poll `Process.whereis` until the name resolves to a different pid —
that's the restart confirmed.

---

## State doesn't survive

A restarted child starts fresh from `init`.

--

### The caveat

```elixir
SupCounter.inc()           # count = 1
Process.exit(pid, :kill)   # crash
# ... supervisor restarts ...
SupCounter.get()           # 0 — fresh state
```

The restart gives you a *clean* process, not the old one's state. If
you need state to survive, store it outside the process.

--

### That's lesson 19

ETS (next-but-one lesson) is one way to keep data alive across a
worker crash — the table outlives the process that reads it.

---

## Where this leads

Supervision trees are the backbone of every OTP application. Next
lesson bundles a GenServer + Supervisor into a real application that
boots automatically.

---

## Next: lesson 18 — OTP applications

The MiniCache capstone — a supervised app that starts on boot.

```
make slides-dev LESSON=18-otp-applications
```
