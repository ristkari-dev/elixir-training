# Lesson 05
## Recursion

Calling yourself with the rest of the work — Elixir's `for` loop.

---

## Recursion is just calling yourself

A function that calls itself on a smaller piece, until there's no work left.

--

### Motivation + tiny example

Elixir has no mutable `for` loop. Walk a list by peeling off the front,
dealing with it, handing the rest back to yourself.

```
defmodule Countdown do
  def from(0), do: :done
  def from(n), do: from(n - 1)
end
```

Two clauses. `from(0)` stops. `from(n)` calls itself with `n - 1`.

--

### Sum.of/1 walked step-by-step

```
def of([]), do: 0
def of([h | t]), do: h + of(t)
```

`Sum.of([1, 2, 3])` unrolls to `1 + (2 + (3 + 0))`. The `0` at the
bottom is the base case `of([])` kicking in.

Common mistake: drop the `[]` clause and you get `FunctionClauseError`
once the tail empties. Always write the base case first.

--

### Recap

- Recursion = call yourself with less work.
- Base case = "what happens when there's nothing left".
- Two clauses: empty list first, head/tail second.

---

## Head/tail decomposition

Patterns peel one element off a list at a time.

--

### Lists are linked + the pattern

A list `[1, 2, 3]` is really `1` followed by `[2, 3]`. All the way
down to `[]`.

```
iex> [h | t] = [1, 2, 3]
[1, 2, 3]
iex> h
1
iex> t
[2, 3]
```

`h` is the first element. `t` is the rest (also a list).

--

### Sum.of/1 uses it

```
def of([]), do: 0
def of([h | t]), do: h + of(t)
```

The second clause's pattern `[h | t]` only matches non-empty lists.
`h` is the first integer, `t` is "everything else". Recurse on `t`.

Common mistake: `[h | t] = 42` raises `MatchError` — `[h | t]`
requires a non-empty list. `[]` isn't matched either; you need the
separate `[]` clause.

--

### Recap

- `[h | t]` = head + tail.
- Only matches non-empty lists.
- The base case `[]` is a separate clause.

---

## The accumulator pattern

Carry a running result forward as an extra argument.

--

### Motivation + helper

You can't mutate a variable in Elixir, so when you need to build
something up while recursing, pass the running result as an extra
argument.

```
def reverse(list), do: do_reverse(list, [])

defp do_reverse([], acc), do: acc
defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
```

Public `reverse/1` seeds the accumulator. Private `do_reverse/2` does
the work.

--

### Trace Reverser.reverse([1, 2, 3])

```
do_reverse([1, 2, 3], [])
do_reverse([2, 3],    [1])
do_reverse([3],       [2, 1])
do_reverse([],        [3, 2, 1])
[3, 2, 1]
```

Each call prepends the head to `acc`. Prepending naturally reverses
the order.

--

### Common mistake — trying a mutable variable

```
def reverse(list) do
  acc = []
  for x <- list, do: acc = [x | acc]   # acc doesn't escape
  acc
end
```

Use the helper pattern instead — pass the accumulator as an argument
and recurse.

--

### Recap

- Public wrapper seeds the accumulator.
- Private helper does the recursion.
- Naming convention: `do_foo/N` for the helper.

---

## A glimpse of tail-call optimisation

Not every recursive function grows the stack.

--

### The rule

If the recursive call is the *last thing* a function does — nothing
wrapping it, no `+`, no `[h | ...]` — the runtime reuses the current
stack frame instead of growing it. Called *tail-call optimisation*
(TCO).

--

### Sum.of/1 is NOT tail-recursive

```
def of([h | t]), do: h + of(t)
```

The recursive call `of(t)` happens, but then we still have to `h + …`
the result. The `+` is the last thing, not the call.

--

### do_reverse/2 IS tail-recursive

```
defp do_reverse([h | t], acc), do: do_reverse(t, [h | acc])
```

The recursive call is the last thing. Nothing wraps it. Million-element
list? No problem.

Common mistake: assuming *all* recursion is fine on huge inputs. For
huge lists, use accumulator helpers (or `Enum`, lesson 06).

--

### Recap

- Tail call = recursive call is the *very last thing*.
- TCO = no stack growth.
- Accumulator helpers are usually tail-recursive.

---

## Next: lesson 06 — `Enum` and the pipe

That recursion you just wrote? Most of the time you don't have to.

```
make slides-dev LESSON=06-enum-and-the-pipe
```
