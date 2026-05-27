# Hints for Lesson 09: Streams

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Fibs.take/1

### Hint 1

`Stream.iterate` carries state forward — iterate over `{prev, curr}`
pairs so each step has access to the previous Fibonacci number.

### Hint 2

```elixir
Stream.iterate({0, 1}, fn {a, b} -> {b, a + b} end)
|> Enum.take(n)
|> Enum.map(&elem(&1, 0))
```

### Hint 3

```elixir
def take(n) do
  {0, 1}
  |> Stream.iterate(fn {a, b} -> {b, a + b} end)
  |> Enum.take(n)
  |> Enum.map(&elem(&1, 0))
end
```

## Drill 2: Naturals.evens_below/1

### Hint 1

Stream the naturals starting at `0`, filter to even, take while less
than the bound, then `Enum.to_list/1` to materialise.

### Hint 2

```elixir
Stream.iterate(0, &(&1 + 1))
|> Stream.filter(&(rem(&1, 2) == 0))
|> Stream.take_while(&(&1 < bound))
|> Enum.to_list()
```

### Hint 3

```elixir
def evens_below(bound) do
  0
  |> Stream.iterate(&(&1 + 1))
  |> Stream.filter(&(rem(&1, 2) == 0))
  |> Stream.take_while(&(&1 < bound))
  |> Enum.to_list()
end
```

## Drill 3: LogStats.count_errors/1

### Hint 1

`File.stream!` opens the file as a line stream. Filter lines that
contain `"ERROR"`. Count with `Enum.count`.

### Hint 2

```elixir
path
|> File.stream!()
|> Stream.filter(&String.contains?(&1, "ERROR"))
|> Enum.count()
```

### Hint 3

```elixir
def count_errors(path) do
  path
  |> File.stream!()
  |> Stream.filter(&String.contains?(&1, "ERROR"))
  |> Enum.count()
end
```
