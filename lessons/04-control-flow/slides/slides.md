# Lesson 04
## Control flow

`case`, `cond`, `with` — pattern matching wearing different clothes.

---

## `case`

Multiple function clauses, but inline in a function body.

--

### Motivation

In lesson 03 you wrote two `def hello/1` clauses for `"world"` and
any other name. Sometimes you want that same branching *inside* a
function, against a value you already have. That's `case`.

--

### Basics

```
case value do
  pattern1 -> body1
  pattern2 -> body2
end
```

Top-to-bottom. First pattern that matches wins. Same rule as multiple
`def` clauses — most specific first, catch-all last.

--

### Worked example

```
iex> case {1, 2} do
...>   {1, x} -> x
...>   _ -> :nope
...> end
2
```

`{1, 2}` matches `{1, x}`, binds `x = 2`, returns `2`. The `_` would
have caught anything else.

--

### Common mistake — no matching clause

```
iex> case 3 do
...>   1 -> :one
...>   2 -> :two
...> end
** (CaseClauseError) no case clause matching: 3
```

If your input can be anything, end with `_ ->` as a catch-all.

--

### Recap

- `case` is inline clauses against one value.
- Top-to-bottom, first match wins.
- No match? `CaseClauseError` at runtime.

---

## `cond`

First truthy condition wins. The closest thing Elixir has to
`else if`.

--

### When to reach for it

When you can't naturally pattern-match — e.g. branching on `n < 0`
vs `n == 0` vs `n > 0`. Each branch is a *condition*, not a *shape*.

--

### Basics

```
iex> cond do
...>   1 > 2 -> :a
...>   true -> :b
...> end
:b
```

Walks top-to-bottom. Skips falsy/nil branches. Runs the body of the
first truthy one.

--

### Common mistake — no truthy clause

```
iex> cond do
...>   false -> :a
...>   nil -> :b
...> end
** (CondClauseError) no cond clause evaluated to a truthy value
```

Always end with `true ->` as a catch-all.

---

## `with`

A chain of `{:ok, _}` steps that short-circuits on the first
`{:error, _}`.

--

### The shape

```
with {:ok, a} <- step1(),
     {:ok, b} <- step2(a),
     {:ok, c} <- step3(b) do
  {:ok, c}
end
```

Each `<-` is a pattern match. If it matches, the next line runs.
If it doesn't, `with` stops and returns the failing value as-is.

--

### Worked example

```
iex> with {:ok, n} <- {:ok, 10},
...>      {:ok, m} <- {:ok, n + 1} do
...>   {:ok, m}
...> end
{:ok, 11}
```

Both steps succeed; the `do` block runs.

--

### Short-circuit

```
iex> with {:ok, n} <- {:error, :boom},
...>      {:ok, m} <- {:ok, n + 1} do
...>   {:ok, m}
...> end
{:error, :boom}
```

First step doesn't match `{:ok, n}`. `with` hands back
`{:error, :boom}` — the *whole* failing value, unchanged.

--

### Common mistake — expecting unwrapping

`with` doesn't unwrap the error. If you need to transform it, use
an `else` block:

```
with {:ok, x} <- thing() do
  x
else
  {:error, reason} -> {:error, "wrapped: #{reason}"}
end
```

---

## Wrap-up — pattern matching everywhere

Three constructs, one idea.

--

### Same idea, different syntax

- `case` — inline function clauses against one value.
- `cond` — chained boolean conditions, first truthy wins.
- `with` — chained `{:ok, _}` steps, first failure short-circuits.

All three are *expressions*. They return a value. Use the one that
fits the branching shape you have.

--

### Phase 0 is done

Lesson 05 — recursion — next.

```
make slides-dev LESSON=05-recursion
```
