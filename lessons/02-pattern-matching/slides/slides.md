# Lesson 02
## Pattern matching

The lesson where `=` stops being obvious.

---

## What we'll do

- Reframe `=` as the **match operator**, not assignment.
- Destructure tuples and lists in one line.
- Use wildcards `_` and literal patterns.
- Glance at rebinding and the pin operator `^`.

---

## `=` is the match operator

The thing every other language calls "assignment" is actually doing
*matching* in Elixir. It just *looks* like assignment when both sides
agree.

--

### Match success

```
iex> x = 1
1
iex> 1 = x
1
```

Both work. The second one isn't a typo — it matches the value `1`
on the left against the value of `x` (also `1`) on the right.

--

### Match failure

```
iex> 2 = x
** (MatchError) no match of right hand side value: 1
```

The left side asks for `2`. The right side is `1`. They don't match.
Loud crash, not silent corruption.

--

### Common mistake

`=` is not equality. `==` is.

```
iex> 1 == 1
true
iex> 1 = 1
1
```

`==` answers a question. `=` makes an assertion (and may bind names).

--

### Recap

- `=` matches both sides.
- Match success: continues.
- Match failure: `MatchError`.

---

## Destructuring tuples and lists

Once `=` is a shape-matcher, you can pull values out of compound
shapes in one line.

--

### Tuples

```
iex> {a, b} = {1, 2}
{1, 2}
iex> a
1
iex> b
2
```

Both names get bound from the same line.

--

### Lists — head and tail

```
iex> [h | t] = [1, 2, 3]
[1, 2, 3]
iex> h
1
iex> t
[2, 3]
```

`h` is the first element. `t` is "everything else" — still a list.

--

### Common mistake — shape mismatch

```
iex> {a, b} = {1, 2, 3}
** (MatchError) no match of right hand side value: {1, 2, 3}
```

A two-tuple shape does not match a three-tuple value.

--

### Recap

- `{a, b}` matches a two-tuple.
- `[h | t]` splits head and tail.
- Wrong shape → `MatchError`.

---

## Wildcards and literal patterns

You can ignore slots you don't need, and you can match against
constants to assert the shape.

--

### Wildcard `_`

```
iex> {_, second} = {1, 2}
{1, 2}
iex> second
2
```

`_` means "I don't care." You can't read it back later.

--

### Literal pattern

```
iex> {:ok, value} = {:ok, 42}
{:ok, 42}
iex> value
42
```

The atom `:ok` is a constant in the pattern. It asserts the tag.

--

### Literal mismatch crashes

```
iex> {:ok, value} = {:error, "nope"}
** (MatchError) no match of right hand side value: {:error, "nope"}
```

The constant didn't match. The program stops.

--

### Recap

- `_` ignores a slot.
- Constants in patterns assert exact values.
- The combination lets one line pull out *and* validate.

---

## Rebinding (and a glimpse of `^`)

Elixir lets you re-bind a name. Erlang doesn't. The pin operator
`^` opts into Erlang-style "use the existing value."

--

### Re-bind works

```
iex> x = 1
1
iex> x = 2
2
iex> x
2
```

Names can be rebound. The old value is forgotten.

--

### Pin says "no, match the old one"

```
iex> x = 1
1
iex> ^x = 2
** (MatchError) no match of right hand side value: 2
```

`^x` means "use the current value of `x` as a pattern, don't rebind."

--

### Common mistake

"I thought variables were immutable in Elixir!"

Values are immutable. Names can be rebound. That's a subtle but
important distinction.

--

### Recap

- Rebinding is allowed.
- `^x` opts out of rebinding for one match.
- The data itself is still immutable.

---

## Where this leads

Pattern matching is everywhere in Elixir from here on:

- Function clauses (lesson 03).
- `case` and `with` (lesson 04).
- Receiving messages between processes (Phase 2).
- Phoenix controller actions (Phase 3).

Get comfortable with the shape-against-shape mental model and the
rest of the course gets a lot easier.

---

## Next: lesson 03 — functions and modules

Multiple function clauses use these same patterns.

```
make slides-dev LESSON=03-functions-and-modules
```
