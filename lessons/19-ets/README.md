# Lesson 19: ETS (in-memory tables)

By the end of this lesson, you'll store data in ETS — the BEAM's built-in in-memory tables — and you'll see why it beats a GenServer for read-heavy work.

## Key ideas

- **Recall from lesson 18.** `MiniCache` funnelled *every* read through one GenServer process. Under load, that single process is a bottleneck — reads queue up behind one another. ETS lets concurrent reads happen in parallel, skipping the process entirely.
- **`:ets.new/2` creates a table.** Types: `:set` (one value per key), `:bag` (many values per key), `:ordered_set` (keys kept sorted). Access: `:public` (anyone reads/writes), `:protected` (owner writes, others read), `:private` (owner only).
- **`:ets.insert/2`, `:ets.lookup/2`, `:ets.delete/2`.** Tuples in, tuples out. `lookup` returns a *list*: `[{key, value}]` for a hit, `[]` for a miss.
- **Table ownership.** A table is owned by the process that created it and dies with that process. So a GenServer typically owns the table; the data outlives individual requests but not the owner.
- **Atomic operations.** `:ets.update_counter/3` increments a counter atomically — no read-modify-write race even under heavy concurrency.

> 💡 **First time seeing this?** ETS stands for Erlang Term Storage. It's not a database you install — it ships with the BEAM. Think of it as a giant concurrent hash table that lives in memory and that any process can read from at the same time.

## Try it in IEx

```
iex> t = :ets.new(:t, [:set, :public])
iex> :ets.insert(t, {:a, 1})
true
iex> :ets.lookup(t, :a)
[a: 1]
iex> :ets.delete(t, :a)
true
iex> :ets.lookup(t, :a)
[]
```

Note `lookup` returns a list — `[a: 1]` is just how IEx prints `[{:a, 1}]`.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=19-ets` from the repo root).
- Two drills: `ETSCache` (the lesson-18 cache API, now ETS-backed) and `Atomic` (atomic counters).
- In both drills, `init/1` — which creates the table — is provided for you. Study it; the operations are the drill.
- Stuck? Open `HINTS.md` one hint at a time.

## Common mistakes

- Forgetting `lookup` returns a *list*. Pattern-match `[{key, value}]` for a hit and `[]` for a miss — not the bare value.
- Using a `:private` table and then wondering why another process can't read it. Reads from tasks or other processes need `:public` (or `:protected`).
- Doing read-modify-write on a counter with `lookup` + `insert`. Two concurrent updates race and lose increments. Use `:ets.update_counter/3` instead — it's atomic.

## Going further

- When would `:ordered_set` be worth its extra cost over `:set`? (Hint: range queries, "next key" traversal.)
- How does an ETS-backed cache survive a GenServer crash where the lesson-18 version didn't? (Hint: it doesn't by default — the table dies with its owner. Look up `:heir` to hand the table to another process on death.)

## Links

- [Erlang — `:ets`](https://www.erlang.org/doc/man/ets.html)
- [Elixir — ETS guide](https://hexdocs.pm/elixir/erlang-term-storage.html)
