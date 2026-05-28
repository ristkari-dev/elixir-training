# Lesson 15
## GenServer I

The workhorse of OTP. Your lesson-13 receive loop, standardised.

---

## What we'll do

- See the two halves: client API and callbacks.
- Set state in `init`.
- Reply synchronously with `handle_call`.
- Fire-and-forget with `handle_cast`.

---

## Client API vs callbacks

A GenServer module has two distinct parts. Keep them separated.

--

### The shape

```elixir
defmodule Counter do
  use GenServer

  # Client API — what others call
  def start_link(n), do: GenServer.start_link(__MODULE__, n)
  def get(pid), do: GenServer.call(pid, :get)
  def inc(pid), do: GenServer.cast(pid, :inc)

  # Callbacks — run inside the server
  def init(n), do: {:ok, n}
  def handle_call(:get, _from, n), do: {:reply, n, n}
  def handle_cast(:inc, n), do: {:noreply, n + 1}
end
```

--

### Why split them?

The client API runs in the *caller's* process. The callbacks run in
the *server's* process. Mixing them up is the #1 GenServer confusion.
Client functions just send messages; logic lives in callbacks.

---

## init & state

`init/1` runs when the server starts and sets the initial state.

--

### The basics

```elixir
def init(initial), do: {:ok, initial}
```

Returns `{:ok, state}`. The `state` is whatever you want — an integer,
a map, a struct, a list.

--

### start_link

```
iex> {:ok, pid} = Counter.start_link(0)
```

`start_link` spawns the process and calls `init`. You get back
`{:ok, pid}` (or `{:error, reason}` if init fails).

---

## handle_call (synchronous)

`call` sends a message and waits for the reply.

--

### The basics

```elixir
def handle_call(:get, _from, count), do: {:reply, count, count}
```

Return `{:reply, reply_value, new_state}`. The caller blocks until
this returns.

--

### Guards in callbacks

```elixir
def handle_call({:withdraw, amt}, _from, bal) when amt <= bal do
  {:reply, {:ok, bal - amt}, bal - amt}
end

def handle_call({:withdraw, _amt}, _from, bal) do
  {:reply, {:error, :insufficient_funds}, bal}
end
```

Pattern matching + guards pick the right clause, just like ordinary
functions (lesson 03).

--

### Common mistake

Wrong return shape. `handle_call` MUST return `{:reply, value, state}`
(or a few other documented shapes). Returning `count` alone crashes
the server.

---

## handle_cast (fire-and-forget)

`cast` sends a message and returns immediately — no reply.

--

### The basics

```elixir
def handle_cast(:inc, count), do: {:noreply, count + 1}
def handle_cast(:reset, _count), do: {:noreply, 0}
```

Return `{:noreply, new_state}`. There's no reply to send.

--

### The ordering guarantee

```elixir
Counter.inc(pid)   # cast
Counter.inc(pid)   # cast
Counter.get(pid)   # call → returns 2
```

Messages are handled one at a time, in order. By the time the `call`
returns, both casts are done. No sleeps needed in tests.

---

## Where this leads

GenServer is the foundation of OTP applications:

- Lesson 16: handle_info, timeouts, testing.
- Lesson 17: supervising GenServers.
- Lesson 18: bundling them into an application.

Almost every stateful Elixir process you'll meet is a GenServer.

---

## Next: lesson 16 — GenServer II

Messages that don't come through call/cast. Timeouts. Testing.

```
make slides-dev LESSON=16-genserver-2
```
