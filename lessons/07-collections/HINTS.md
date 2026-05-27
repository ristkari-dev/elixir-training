# Hints for Lesson 07: Collections

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Freq.count/1

### Hint 1

Use `Enum.reduce` with `%{}` as the accumulator. For each item, increment its count (or set
to 1 if it's the first time you've seen it).

### Hint 2

`Map.update/4` is exactly the right shape: it takes a map, a key, a default for first-seen
keys, and a function for already-present keys.

```
Enum.reduce(words, %{}, fn word, acc -> Map.update(acc, word, 1, &(&1 + 1)) end)
```

### Hint 3

```elixir
def count(list) do
  Enum.reduce(list, %{}, fn item, acc -> Map.update(acc, item, 1, &(&1 + 1)) end)
end
```

Read it as: starting with an empty map, for each `item`, bump its count up by one — or set
it to `1` if it isn't there yet. `Map.update/4` handles both cases in one call.

## Drill 2: Opts.get/3

### Hint 1

`Keyword.get/3` is exactly what you need. It takes a keyword list, a key, and a default —
which is also what your function takes.

### Hint 2

```
def get(opts, key, default), do: Keyword.get(opts, key, default)
```

A one-line delegation. `Keyword.get/3` already does everything the spec asks for.

### Hint 3

```elixir
def get(opts, key, default), do: Keyword.get(opts, key, default)
```

This is the whole solution. The point of the drill isn't to *implement* keyword lookup —
it's to *recognise* that the standard library already gives you the lookup tool, with the
default-handling baked in.

## Drill 3: MapMerge.deep/2

### Hint 1

Use `Map.merge/3` — the three-arg version takes a "merger" function called once per
conflicting key. If both values are themselves maps, recurse; otherwise the second value
wins.

### Hint 2

```
Map.merge(map1, map2, fn _k, v1, v2 ->
  if is_map(v1) and is_map(v2), do: deep(v1, v2), else: v2
end)
```

The merger receives the key plus both values. `_k` because we don't use it. The recursion
keeps the deep-merge behaviour all the way down.

### Hint 3

```elixir
def deep(a, b) do
  Map.merge(a, b, fn _k, v1, v2 ->
    if is_map(v1) and is_map(v2), do: deep(v1, v2), else: v2
  end)
end
```

`Map.merge/2` already handles the "no conflict" case (key in one map only) — it just takes
the value from whichever map has it. The merger fires only for keys present in *both* maps,
which is exactly when you need to decide between "recurse" and "let the second win."
