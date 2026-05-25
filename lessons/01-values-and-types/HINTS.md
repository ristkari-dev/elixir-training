# Hints for Lesson 01: Values and types

Read these one at a time. Try the exercise after each hint before reading the next.

## Drill 1: `Math.add/2`

### Hint 1

What operator adds two numbers? You've used it in everyday arithmetic.

### Hint 2

The function body just needs `a + b`. Replace the `raise "TODO …"` call with that expression.

### Hint 3

```elixir
def add(a, b), do: a + b
```

## Drill 2: `Greet.hello/1`

### Hint 1

Use string concatenation with `<>`. There is no `+` for strings in Elixir.

### Hint 2

You're building `"Hello, " <> name <> "!"`. Note the comma-space inside the first string and the exclamation mark in the last.

### Hint 3

```elixir
def hello(name), do: "Hello, " <> name <> "!"
```

## Drill 3: `Status.ok?/1`

### Hint 1

Compare with `==` and the atom `:ok`. Remember: a single `=` binds, a double `==` compares.

### Hint 2

The function body is `x == :ok`. The result of a comparison is already `true` or `false` — you don't need an `if`.

### Hint 3

```elixir
def ok?(x), do: x == :ok
```
