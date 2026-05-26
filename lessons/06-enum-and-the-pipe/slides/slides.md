# Lesson 06
## Enum and the pipe

The recursion you don't have to write — and how to read it left-to-right.

---

## Enum.map

Apply a function to every element. Same length out as in.

You don't have to write `[h * 2 | double_all(t)]` ever again. Lesson 05's
`Mapper.double_all/1` is exactly `Enum.map/2` with one specific function.

--

### Basics

```
iex> Enum.map([1, 2, 3], &(&1 * 2))
[2, 4, 6]
iex> Enum.map([1, 2, 3], fn x -> x * 2 end)
[2, 4, 6]
```

Two ways to write the same thing. `&(&1 * 2)` is shorthand for
`fn x -> x * 2 end`. `&1` means "the first argument."

--

### Worked: rewriting lesson 05

```
# Lesson 05:
def double_all([]), do: []
def double_all([h | t]), do: [h * 2 | double_all(t)]

# Lesson 06:
def doubled(list), do: Enum.map(list, &(&1 * 2))
```

Same output. One line vs. two clauses. `Enum.map` is *the* recursion,
already written, taking your per-element function as an argument.

--

### Common mistake — wrong arity in the capture

```
iex> Enum.map(["a"], &String.upcase/2)
** (BadArityError) ...
```

`Enum.map/2`'s callback takes one argument (the element). `String.upcase`
captured at arity `/2` won't work. Use `&String.upcase/1`.

---

## Enum.filter

Keep elements where the predicate is truthy. Same elements, possibly shorter.

`map` transforms each element. `filter` *selects* — same elements, in the
same order, but only the ones that pass a test.

--

### Basics

```
iex> Enum.filter([1, 2, 3, 4], &(rem(&1, 2) == 0))
[2, 4]
iex> Enum.filter([1, 2, 3, 4], fn x -> rem(x, 2) == 0 end)
[2, 4]
```

Predicate returns truthy/falsy. Truthy values pass through. Falsy values
(`false` and `nil`) get dropped.

--

### Worked: Lists.evens/1

```
def evens(list), do: Enum.filter(list, &(rem(&1, 2) == 0))
```

`rem(x, 2) == 0` is true exactly for the even integers. Everything else
gets dropped.

--

### Common mistake — non-boolean predicates

Elixir uses truthiness: anything except `false` and `nil` is "true."
Returning `0` or `""` from a predicate keeps the element. That's
confusing to readers — be explicit and return a real boolean (`==`, `>`,
`<`, etc.).

---

## Enum.reduce

The universal fold. Start with an accumulator, fold each element in.

`map` and `filter` both return lists. `Enum.reduce/3` is more general:
sum, count, build a map — anything that collapses or reshapes.

--

### Basics

```
iex> Enum.reduce([1, 2, 3, 4], 0, &+/2)
10
iex> Enum.reduce([:a, :b], %{}, fn x, acc -> Map.put(acc, x, true) end)
%{a: true, b: true}
```

`Enum.reduce(list, start, fn elem, acc -> new_acc end)`. Sum collapses
to one integer. The map version builds a different-shaped value.

--

### Worked: Lists.sum/1

```
def sum(list), do: Enum.reduce(list, 0, &+/2)
```

Start at `0`. For each element `x`, replace `acc` with `x + acc`. After
the last element, return `acc`. That's the whole fold.

--

### Common mistake — forgetting the initial accumulator

`Enum.reduce/2` (no initial value) exists — it uses the first element as
the start and errors on an empty list:

```
iex> Enum.reduce([], &+/2)
** (Enum.EmptyError) ...
```

Prefer `Enum.reduce/3` with an explicit initial value (`0`, `[]`, `%{}`).

---

## The pipe `|>`

Read left-to-right, not inside-out.

Without the pipe, transformations read inside-out from the deepest paren.
With the pipe, you read them in the order the data moves.

--

### Basics

```
iex> [1, 2, 3] |> Enum.map(&(&1 * 2))
[2, 4, 6]
```

`x |> f(args)` rewrites to `f(x, args)`. The value on the left becomes
the *first* argument on the right.

--

### Worked: the drill 4 pipeline

```
def pipeline(list) do
  list
  |> Enum.filter(&(rem(&1, 2) == 0))
  |> Enum.map(&(&1 * &1))
  |> Enum.sum()
end
```

Start with a list. Keep the evens. Square each one. Sum. Reads top to
bottom in the same order the data moves through.

--

### Common mistake — the pipe always feeds the first arg

```
iex> "foo" |> Map.put(:key, "bar")
** (FunctionClauseError) ...
```

`Map.put/3` expects a map first. The pipe puts `"foo"` there, and it
doesn't match. `list |> String.split(",")` works because `String.split/2`
takes the string first.

---

## Next: lesson 07 — collections

We've been on lists this whole time. There's more — tuples, maps, keyword
lists, and what each is good for.

```
make slides-dev LESSON=07-collections
```
