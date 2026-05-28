# Lesson 19
## ETS — in-memory tables

Concurrent reads without a GenServer bottleneck.

---

## Why ETS

In lesson 18, every `MiniCache.get` was a message to one process.

--

### One process = one queue

```
caller ─┐
caller ─┼─→ [ GenServer ] ─→ map
caller ─┘     (serial)
```

A thousand readers wait in line behind one mailbox. Fine for low
traffic, a bottleneck under load.

--

### ETS reads in parallel

```
caller ─→ ┐
caller ─→ ┼─→ [ :public ETS table ]
caller ─→ ┘     (concurrent)
```

Reads hit the table directly — no process in the middle.

---

## Creating a table

```elixir
:ets.new(:my_table, [:set, :public, :named_table])
```

--

### Types

- `:set` — one value per key (what you'll use).
- `:bag` — many values per key.
- `:ordered_set` — keys kept sorted.

--

### Access

- `:public` — any process reads and writes.
- `:protected` — owner writes, others read.
- `:private` — owner only.

A table is owned by the process that created it and dies with it.

---

## insert / lookup / delete

```elixir
:ets.insert(:t, {:a, 1})   # tuple in
:ets.lookup(:t, :a)        # => [{:a, 1}]
:ets.lookup(:t, :missing)  # => []
:ets.delete(:t, :a)        # => true
```

--

### lookup returns a *list*

```elixir
def get(key) do
  case :ets.lookup(@table, key) do
    [{^key, value}] -> value
    [] -> nil
  end
end
```

The #1 ETS mistake: expecting the bare value. Match the list.

---

## Atomic counters

Read-modify-write races. ETS gives you one atomic step.

--

### The race

```elixir
v = :ets.lookup(:t, :hits)  # read
:ets.insert(:t, {:hits, v + 1})  # write — another bump snuck in!
```

--

### update_counter

```elixir
:ets.update_counter(:t, :hits, 1, {:hits, 0})
```

One atomic operation. 100 concurrent bumps → exactly 100. No lock,
no race.

---

## Next: lesson 20 — distribution

Run code on another node. The same message passing, across machines.

```
make slides-dev LESSON=20-distribution
```
