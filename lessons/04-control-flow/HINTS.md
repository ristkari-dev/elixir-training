# Hints for Lesson 04: Control flow

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Sign.of/1

### Hint 1

Three branches — negative, zero, positive — but they're conditions on `n`, not shapes you can pattern-match against. That's exactly what `cond` is for. It walks the conditions top-to-bottom and runs the first one that's true.

### Hint 2

Inside the function body, write `cond do … end` with three lines. The first checks `n < 0`, the second checks `n == 0`, the third is the catch-all `true ->` for everything else (positive). Each line returns the atom for that case.

### Hint 3

```elixir
def of(n) do
  cond do
    n < 0 -> :negative
    n == 0 -> :zero
    true -> :positive
  end
end
```

## Drill 2: Traffic.action/1

### Hint 1

The input is one of three atoms: `:red`, `:yellow`, `:green`. You could write three `def action/1` clauses — but this drill is about `case`. Same idea, inline.

### Hint 2

`case light do … end` with three branches. The pattern on the left is the atom literal (`:red`); the body on the right is the string. No catch-all needed — the three atoms exhaust the inputs the tests give you.

### Hint 3

```elixir
def action(light) do
  case light do
    :red -> "stop"
    :yellow -> "slow"
    :green -> "go"
  end
end
```

## Drill 3: Account.status/1

### Hint 1

Three patterns. Two start with `{:ok, _}` and need to be split apart — one for positive balance, one for zero. The third is any `{:error, _}`. Order matters because the positive-balance branch needs a guard to distinguish it from the zero branch.

### Hint 2

Inside `case result do … end`: a `{:ok, balance} when balance > 0` clause, then `{:ok, 0}`, then `{:error, _}`. The `_` underscore says "I don't care what's inside this tuple — match anything."

### Hint 3

```elixir
def status(result) do
  case result do
    {:ok, balance} when balance > 0 -> :open
    {:ok, 0} -> :empty
    {:error, _} -> :closed
  end
end
```

## Drill 4: Steps.run/1

### Hint 1

Three steps in a chain. Each returns `{:ok, value}` on success or `{:error, reason}` on failure. You want all three to succeed; if any fails, return its error unchanged. That's textbook `with`.

### Hint 2

`with {:ok, a} <- step1(input), {:ok, b} <- step2(a), {:ok, c} <- step3(b) do {:ok, c} end`. Each `<-` matches the `{:ok, _}` shape; if any returns `{:error, _}` instead, `with` short-circuits and returns that value as-is.

### Hint 3

```elixir
def run(input) do
  with {:ok, a} <- step1(input),
       {:ok, b} <- step2(a),
       {:ok, c} <- step3(b) do
    {:ok, c}
  end
end
```

## Drill 5: Pick.first_match/2

### Hint 1

Two function clauses (lesson 03 style). One for the empty list — answer is `nil`. One for `[head | tail]` — check `pred.(head)`; if true, you've found it; if false, recurse on `tail`. Remember `pred` is an anonymous function, so call it with the dot.

### Hint 2

The recursive clause holds a `case` inside it. `case pred.(head) do true -> head; false -> first_match(tail, pred) end`. The base case (empty list) just returns `nil` directly — no `case` needed there.

### Hint 3

```elixir
def first_match([], _pred), do: nil

def first_match([head | tail], pred) do
  case pred.(head) do
    true -> head
    false -> first_match(tail, pred)
  end
end
```
