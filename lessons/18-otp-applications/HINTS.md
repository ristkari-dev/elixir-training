# Hints for Lesson 18: OTP applications

Read one hint at a time. Try the exercise again before reading the next.
Build the three drills in order — each depends on the one before.

## Drill 1: MiniCache.Server

### Hint 1

A GenServer holding a map. The client API is provided; implement the
callbacks. `init` returns `{:ok, %{}}`. Casts handle `{:put, k, v}` and
`{:delete, k}`. Calls handle `{:get, k}` and `:size`.

### Hint 2

```elixir
def init(state), do: {:ok, state}
def handle_cast({:put, key, value}, state), do: {:noreply, Map.put(state, key, value)}
def handle_cast({:delete, key}, state), do: {:noreply, Map.delete(state, key)}
def handle_call({:get, key}, _from, state), do: {:reply, Map.get(state, key), state}
def handle_call(:size, _from, state), do: {:reply, map_size(state), state}
```

### Hint 3

The five callbacks above, each group prefixed with `@impl true`.

## Drill 2: MiniCache.Application

### Hint 1

`use Application` and implement `start/2`. It starts a supervisor with
`MiniCache.Server` as the only child, `:one_for_one` strategy.

### Hint 2

```elixir
def start(_type, _args) do
  children = [MiniCache.Server]
  Supervisor.start_link(children, strategy: :one_for_one, name: MiniCache.Supervisor)
end
```

### Hint 3

The `start/2` above, with `@impl true` above it. The `mix.exs` already
points `mod:` at this module, so it runs on boot.

## Drill 3: MiniCache (public API)

### Hint 1

Thin delegation. Each public function forwards to the matching
`MiniCache.Server` function. `defdelegate` is the cleanest way.

### Hint 2

```elixir
alias MiniCache.Server

defdelegate put(key, value), to: Server
defdelegate get(key), to: Server
defdelegate delete(key), to: Server
defdelegate size, to: Server
```

### Hint 3

Exactly the alias + four `defdelegate` lines above, inside
`defmodule MiniCache do … end`.
