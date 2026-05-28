# Hints for Lesson 19: ETS

Read one hint at a time. Try the exercise again before reading the next.
`init/1` (which creates the named table) is already written for you in
both drills — you only fill in the operations.

## Drill 1: ETSCache

### Hint 1

The table is named (`:ets_cache`) and `:public`, so the client functions
can call `:ets` directly — no `GenServer.call` needed. `put` inserts a
`{key, value}` tuple. `get` looks the key up. `delete` removes it.

### Hint 2

```elixir
def put(key, value), do: :ets.insert(@table, {key, value})
def delete(key), do: :ets.delete(@table, key)
```

For `get`, remember `:ets.lookup/2` returns a *list*, not the value.

### Hint 3

```elixir
def get(key) do
  case :ets.lookup(@table, key) do
    [{^key, value}] -> value
    [] -> nil
  end
end
```

The `^key` pin matches the same key you looked up; `[]` means a miss.

## Drill 2: Atomic

### Hint 1

`:ets.update_counter/3` does the read-add-write in one atomic step, so
concurrent bumps can't lose increments. Its third argument can be
`{key, by}`, and a fourth gives a default tuple for missing keys.

### Hint 2

```elixir
def bump(key, by \\ 1), do: :ets.update_counter(@table, key, by, {key, 0})
```

The `{key, 0}` default means a missing key starts at 0, then `by` is
added — so the first `bump(:x, 5)` returns `5`.

### Hint 3

`value/1` is the same `lookup`-and-match shape as `ETSCache.get/1`, but
return `0` (not `nil`) for a missing counter:

```elixir
def value(key) do
  case :ets.lookup(@table, key) do
    [{^key, v}] -> v
    [] -> 0
  end
end
```
