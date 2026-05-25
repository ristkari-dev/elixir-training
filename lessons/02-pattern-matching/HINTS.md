# Hints for Lesson 02: Pattern matching

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Pairs.first/1

### Hint 1

The whole point of this lesson is that you can destructure in the function head. You don't need to write the destructure in the body.

### Hint 2

You want `def first({a, _}), do: a`. The pattern in the function head pulls out the first slot and ignores the second.

### Hint 3

```elixir
def first({a, _}), do: a
```

## Drill 2: Pairs.second/1

### Hint 1

Same shape as `Pairs.first/1`, but you keep the second slot instead.

### Hint 2

`def second({_, b}), do: b`.

### Hint 3

```elixir
def second({_, b}), do: b
```

## Drill 3: Status.unwrap/1

### Hint 1

Use *two* function clauses — one for `{:ok, value}` and one for `{:error, _}`. Elixir tries them in order and picks the first that matches.

### Hint 2

The `:ok` clause returns `value`; the `:error` clause returns `nil`. The `_` in the `:error` clause says "I don't care what the reason is."

### Hint 3

```elixir
def unwrap({:ok, value}), do: value
def unwrap({:error, _}), do: nil
```

## Drill 4: Coords.origin?/1

### Hint 1

Two clauses again. The first matches the literal tuple `{0, 0}`. The second is a catch-all using `_` for any other input.

### Hint 2

First clause returns `true`. Second clause returns `false`. Order matters — the literal must come before the catch-all, otherwise the catch-all wins for every input.

### Hint 3

```elixir
def origin?({0, 0}), do: true
def origin?(_), do: false
```
