# Hints for Lesson 06: Enum and the pipe

Read one hint at a time. Try the exercise again before reading the next.

## Drills 1–3: Lists.doubled/1, Lists.evens/1, Lists.sum/1

### Hint 1

Each of these is a one-liner with a single `Enum` function. No recursion, no clauses, no
helpers — pick the right `Enum.*` call and you're done.

### Hint 2

- `def doubled(list), do: Enum.map(list, &(&1 * 2))`
- `def evens(list), do: Enum.filter(list, &(rem(&1, 2) == 0))`
- `def sum(list), do: Enum.reduce(list, 0, &+/2)`

The `&+/2` in `sum/1` is a function capture — it's `Kernel.+/2` passed as a value. You could
equivalently write `fn x, acc -> x + acc end`.

### Hint 3

```elixir
defmodule Lists do
  @moduledoc "Enum drills for lesson 06."

  def doubled(list), do: Enum.map(list, &(&1 * 2))

  def evens(list), do: Enum.filter(list, &(rem(&1, 2) == 0))

  def sum(list), do: Enum.reduce(list, 0, &+/2)
end
```

## Drill 4: Pipeline.pipeline/1

### Hint 1

Three steps: filter the list down to the evens, square each one, sum the results. All in a
`|>` chain that starts from the input list. No intermediate variables.

### Hint 2

```
list |> Enum.filter(...) |> Enum.map(...) |> Enum.sum()
```

The filter predicate is the same one from `Lists.evens/1`. The map function is `&(&1 * &1)`
— multiply each element by itself.

### Hint 3

```elixir
def pipeline(list) do
  list
  |> Enum.filter(&(rem(&1, 2) == 0))
  |> Enum.map(&(&1 * &1))
  |> Enum.sum()
end
```

Each `|>` feeds the previous result as the *first* argument of the next call. The list flows
top-to-bottom; the final `Enum.sum/1` collapses it to a single integer.
