# Hints for Lesson 16: GenServer II

Read one hint at a time. Try the exercise again before reading the next.
The client API is provided in both drills; you implement the callbacks.

## Drill 1: Ticker

### Hint 1

`init/1` schedules the first tick and returns
`{:ok, %{count: 0, interval: interval}}`. `handle_info(:tick, state)`
increments the count AND schedules the next tick. A private
`schedule/1` helper wraps `Process.send_after(self(), :tick, interval)`.

### Hint 2

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

### Hint 3

Add the provided `handle_call(:count, …)` and the three pieces above.
The key: reschedule inside `handle_info` or it only ticks once.

## Drill 2: IdleTimer

### Hint 1

The trick is the third element of the return tuple — the timeout.
`init` returns `{:ok, state, timeout}`. `handle_cast(:touch, …)` and
`handle_call(:status, …)` also return the timeout (any activity resets
it). `handle_info(:timeout, …)` flips status to `:idle` and returns
WITHOUT a timeout (so it doesn't re-arm).

### Hint 2

```elixir
def init(timeout), do: {:ok, %{status: :active, timeout: timeout}, timeout}
def handle_cast(:touch, state), do: {:noreply, %{state | status: :active}, state.timeout}
def handle_call(:status, _from, state), do: {:reply, state.status, state, state.timeout}
def handle_info(:timeout, state), do: {:noreply, %{state | status: :idle}}
```

### Hint 3

Exactly the four callbacks above. The `:timeout` message is sent by
OTP automatically when the server is idle for `timeout` ms — you don't
schedule it yourself.
