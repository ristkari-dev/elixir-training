# Hints for Lesson 11: Error handling

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: SafeDiv.divide/2

### Hint 1

Two clauses. Match the divisor against `0` in the first clause and
return `{:error, :div_by_zero}`. The second clause catches anything
else and returns `{:ok, a / b}`.

### Hint 2

```elixir
def divide(_a, 0), do: {:error, :div_by_zero}
def divide(a, b), do: {:ok, a / b}
```

### Hint 3

```elixir
def divide(_a, 0), do: {:error, :div_by_zero}
def divide(a, b), do: {:ok, a / b}
```

## Drill 2: Parse.integer/1

### Hint 1

`Integer.parse/1` returns `{n, rest}` on success or `:error` on
failure. You want to reject inputs with trailing garbage, so check
that `rest` is the empty string.

### Hint 2

```elixir
case Integer.parse(s) do
  {n, ""} -> {:ok, n}
  _ -> {:error, :invalid}
end
```

### Hint 3

```elixir
def integer(s) do
  case Integer.parse(s) do
    {n, ""} -> {:ok, n}
    _ -> {:error, :invalid}
  end
end
```

## Drill 3: Pipeline.run/1

### Hint 1

Three helper functions (`step_a/1`, `step_b/1`, `step_c/1`) live in
the same module. The `run/1` function chains them with `with`, and
uses an `else` clause that just passes the `{:error, _}` through
untouched.

### Hint 2

```elixir
with {:ok, a} <- step_a(input),
     {:ok, b} <- step_b(a),
     {:ok, c} <- step_c(b) do
  {:ok, c}
else
  {:error, _} = err -> err
end
```

### Hint 3

```elixir
def run(input) do
  with {:ok, a} <- step_a(input),
       {:ok, b} <- step_b(a),
       {:ok, c} <- step_c(b) do
    {:ok, c}
  else
    {:error, _} = err -> err
  end
end
```
