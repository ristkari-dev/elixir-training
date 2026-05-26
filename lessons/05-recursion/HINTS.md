# Hints for Lesson 05: Recursion

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Sum.of/1

### Hint 1

Two clauses. The first matches `[]` and returns `0`. The second matches `[h | t]` and recursively sums.

### Hint 2

`def of([]), do: 0` / `def of([h | t]), do: h + of(t)`.

### Hint 3

```elixir
def of([]), do: 0
def of([h | t]), do: h + of(t)
```

## Drill 2: Counter.length/1

### Hint 1

Same shape as `Sum.of/1`. Base case returns `0`. Recursive case adds `1` plus a recursive call on the tail.

### Hint 2

`def length([]), do: 0` / `def length([_ | t]), do: 1 + length(t)`.

### Hint 3

```elixir
def length([]), do: 0
def length([_ | t]), do: 1 + length(t)
```

## Drill 3: Mapper.double_all/1

### Hint 1

Return a new list. Base case returns `[]`. Recursive case prepends `h * 2` to the recursive result on the tail.

### Hint 2

`def double_all([]), do: []` / `def double_all([h | t]), do: [h * 2 | double_all(t)]`.

### Hint 3

```elixir
def double_all([]), do: []
def double_all([h | t]), do: [h * 2 | double_all(t)]
```

## Drill 4: Reverser.reverse/1

### Hint 1

Two functions — a public `reverse/1` that calls a private `reverse/2` with an empty accumulator.

### Hint 2

Public clause: `def reverse(list), do: do_reverse(list, [])`. Private base: `defp do_reverse([], acc), do: acc`. Private recursive: `defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])`.

### Hint 3

```elixir
def reverse(list), do: do_reverse(list, [])

defp do_reverse([], acc), do: acc
defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
```
