# Lesson 01

## Values and types

The building blocks: numbers, atoms, strings, and binding.

---

## Numbers

Computers count, but there are two flavours: integers and floats.

--

### Basics

```
iex> 1 + 1
2
iex> 1.0 + 1.0
2.0
```

Integers stay exact. Floats are decimal approximations.

--

### Worked: division

```
iex> 7 / 2
3.5
iex> div(7, 2)
3
iex> rem(7, 2)
1
```

`/` always returns a float. Use `div/2` and `rem/2` for integer math.

--

### Common mistake

Expecting `5 / 2` to be `2`:

```
iex> 5 / 2
2.5
```

It's `2.5`. If you want `2`, write `div(5, 2)`.

---

## Atoms

Sometimes you want a name without contents — a label like `:ok`.

--

### Basics

```
iex> :ok
:ok
iex> :error
:error
```

The leading colon makes it an atom. Same name everywhere = same value.

--

### Worked: typed results

```
iex> {:ok, 42}
{:ok, 42}
iex> {:error, :not_found}
{:error, :not_found}
```

A tuple with an atom tag is how Elixir functions report success vs failure.

--

### Common mistake

`:ok` is **not** `"ok"`:

```
iex> :ok == "ok"
false
```

Atom (named constant) vs string (text). Different types, never equal.

---

## Strings

Text in double quotes.

--

### Basics

```
iex> "hello"
"hello"
iex> "Hello, Aki!"
"Hello, Aki!"
```

Under the hood: UTF-8 binaries.

--

### Worked: concatenation

```
iex> "hi " <> "there"
"hi there"
```

`<>` is the string-join operator. Mind the trailing space inside the first string.

--

### Common mistake

`+` doesn't work on strings:

```
iex> "1" + "2"
** (ArithmeticError) bad argument in arithmetic expression
```

For text, use `<>`. To add numbers from strings, you'd need to convert the strings to numbers first — we'll see how later in the course.

---

## Binding

We need to name values.

--

### Basics

```
iex> x = 42
42
```

"Give the name `x` to the value `42`." From now on, `x` refers to `42`.

--

### Worked: build on it

```
iex> x = 42
42
iex> y = x + 1
43
```

`y` is now `43`. `x` is still `42`.

--

### Common mistake

`=` is **not** assignment — it's the match operator. Preview of lesson 02:

```
iex> 1 = 1
1
iex> 1 = 2
** (MatchError) no match of right hand side value: 2
```

Why that works is the whole point of the next lesson.

---

## Next

Lesson 02 — pattern matching.

The thing that makes `=` actually interesting.

Run:

```
make slides-dev LESSON=02-pattern-matching
```
