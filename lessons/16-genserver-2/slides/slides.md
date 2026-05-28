# Lesson 16
## GenServer II

Messages beyond call/cast. Timeouts. Testing.

---

## What we'll do

- Handle other messages with `handle_info`.
- Do periodic work with `Process.send_after`.
- Use the GenServer inactivity timeout.
- Test GenServers with `start_supervised!`.

---

## handle_info

Messages that aren't `call` or `cast` land in `handle_info/2`.

--

### Where they come from

- Timer messages (`Process.send_after`).
- Monitor/link notifications (`:DOWN`, `:EXIT`).
- Raw `send(pid, msg)` from other code.

--

### The basics

```elixir
def handle_info(:tick, state) do
  # do something
  {:noreply, state}
end
```

Same return shapes as `handle_cast` — there's no reply to a plain
message.

---

## Periodic work with send_after

A GenServer schedules messages to itself to do recurring work.

--

### Schedule, handle, reschedule

```elixir
def init(interval) do
  schedule(interval)
  {:ok, %{count: 0, interval: interval}}
end

def handle_info(:tick, state) do
  schedule(state.interval)
  {:noreply, %{state | count: state.count + 1}}
end

defp schedule(interval), do: Process.send_after(self(), :tick, interval)
```

--

### Common mistake

Forgetting to reschedule. If `handle_info(:tick, …)` doesn't call
`schedule` again, the server ticks exactly once and then goes quiet.

--

### Never sleep in a callback

```elixir
# BAD — blocks every other message
def handle_call(:slow, _from, state) do
  Process.sleep(5000)
  {:reply, :ok, state}
end
```

A callback runs in the server's single process. Sleeping there freezes
the whole server. Schedule a message instead.

---

## GenServer timeouts

Return a timeout as the last tuple element to get an inactivity timer.

--

### The shape

```elixir
def init(t), do: {:ok, %{status: :active, timeout: t}, t}
def handle_call(:status, _from, s), do: {:reply, s.status, s, s.timeout}
def handle_info(:timeout, s), do: {:noreply, %{s | status: :idle}}
```

If no message arrives within `t` ms, OTP sends `:timeout`. Any message
resets the clock.

--

### Use cases

- Idle session expiry.
- "Flush a buffer if nothing's happened for a while."
- Closing an idle connection.

---

## Testing GenServers

`start_supervised!/1` is the idiomatic test setup.

--

### The pattern

```elixir
test "advances over time" do
  pid = start_supervised!({Ticker, interval: 20})
  Process.sleep(70)
  assert Ticker.count(pid) >= 2
end
```

ExUnit starts the server and tears it down after the test. No manual
cleanup, no leaked processes between tests.

--

### Lower-bound assertions for timers

```elixir
assert Ticker.count(pid) >= 2   # good
assert Ticker.count(pid) == 3   # flaky — timing varies
```

Sleep a little longer than the interval and assert "at least N," never
an exact count.

---

## Where this leads

`handle_info` + timers power most long-running OTP processes:
heartbeats, polling, retries, idle expiry. Next we keep these servers
alive automatically.

---

## Next: lesson 17 — Supervisors

Restart crashed processes. "Let it crash" becomes a feature.

```
make slides-dev LESSON=17-supervisors
```
