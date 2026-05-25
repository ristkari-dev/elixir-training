# Hints for Lesson 03: Functions and modules

Read one hint at a time. Try the exercise again before reading the next.

## Drills 1+2: MyMath.double/1 and MyMath.area_of_rectangle/2

### Hint 1

Two tiny functions in one module. Use the single-line `def name(args), do: expr` form for both — there's no need for a multi-line `do … end` block when the body is one expression.

### Hint 2

`def double(x), do: x * 2` and `def area_of_rectangle(w, h), do: w * h`. Drop the leading underscores from the parameter names — Elixir uses `_x` to mean "I'm intentionally not using this", so once you actually use `x` you write it without the underscore.

### Hint 3

```elixir
defmodule MyMath do
  @moduledoc "Tiny math helpers used in lesson 03."

  def double(x), do: x * 2
  def area_of_rectangle(w, h), do: w * h
end
```

## Drill 3: Greeter.hello/1

### Hint 1

Two function clauses. The first matches the literal string `"world"`, the second matches any name. Clause order matters — the literal must come first, otherwise the catch-all swallows every input.

### Hint 2

First clause is `def hello("world"), do: "Hello, world!"`. Second falls through with `def hello(name), do: "Hello, " <> name <> "!"`. The `<>` operator concatenates strings.

### Hint 3

```elixir
def hello("world"), do: "Hello, world!"
def hello(name), do: "Hello, " <> name <> "!"
```

## Drill 4: Numbers.classify/1

### Hint 1

Three clauses with `when` guards: one for negative, one for zero (matches the literal `0` directly — no guard needed), one for positive.

### Hint 2

`def classify(n) when n < 0, do: :negative` / `def classify(0), do: :zero` / `def classify(n) when n > 0, do: :positive`. Note that the middle clause uses a literal pattern instead of a guard — `0` matches only the number zero.

### Hint 3

```elixir
def classify(n) when n < 0, do: :negative
def classify(0), do: :zero
def classify(n) when n > 0, do: :positive
```

## Drill 5: ApplyHelper.twice/2

### Hint 1

You're passed a function `f` and a value `x`. You need to call `f` on `x`, then call `f` on the result. The output of the first call becomes the input of the second.

### Hint 2

Anonymous functions are invoked with the dot: `f.(x)`. So you want `f.(f.(x))` — the inner call evaluates first, then the outer call uses its result.

### Hint 3

```elixir
def twice(f, x), do: f.(f.(x))
```
