# Lesson 03
## Functions and modules

The lesson where you stop typing into iex and start writing files.

---

## Modules and named functions

You've been typing into iex. Now you'll write files that iex can call.
A module is just a folder of related functions.

--

### Basics

```
defmodule MyMath do
  def double(x), do: x * 2
end
```

Call it:

```
iex> MyMath.double(5)
10
```

--

### Arity and the block form

`MyMath.double/1` — the `/1` is the *arity*, how many arguments it
takes. Same function name with different arities are different functions.

The block form works for longer bodies:

```
def double(x) do
  x * 2
end
```

Single-line `def name(args), do: expr` is sugar for that.

--

### Common mistake

A `def` outside a `defmodule` won't compile.

```
def double(x), do: x * 2   # at the top of a file by itself
** (CompileError) cannot invoke def/2 outside module
```

Every `def` needs a module around it.

---

## Anonymous functions and `&`

Sometimes you want a function inline — to pass as an argument, or
to bind to a local name — not declared in a module.

--

### Basics

```
iex> square = fn x -> x * x end
#Function<...>
iex> square.(5)
25
```

`fn x -> … end` builds a function value. `square.(5)` calls it.
Note the dot.

--

### The `&` shorthand

```
iex> double = &(&1 * 2)
#Function<...>
iex> double.(7)
14
iex> Enum.map([1, 2, 3], &(&1 * 10))
[10, 20, 30]
```

`&1` is the first argument. `&(&1 * 2)` is sugar for
`fn x -> x * 2 end`.

--

### Common mistake — forgetting the dot

```
iex> square = fn x -> x * x end
iex> square(5)
** (CompileError) undefined function square/1
```

Without the dot, Elixir thinks you're calling a *named* function.
The dot says "this is the bound anonymous one." `square.(5)` works.

---

## Multiple clauses

You can write two (or more) `def`s with the same name. Elixir picks
the first whose pattern matches.

--

### Basics

```
def hello("world"), do: "Hello, world!"
def hello(name),    do: "Hello, " <> name <> "!"
```

Calling `hello("world")` runs the first clause. Calling `hello("Aki")`
falls through to the second.

--

### Clause order matters

Elixir tries clauses *top to bottom*. The first match wins.
Put the most specific patterns first; the catch-all (a bare variable
like `name`) goes last.

--

### Common mistake — catch-all first

```
def hello(name),    do: "Hello, " <> name <> "!"
def hello("world"), do: "Hello, world!"   # dead code!
```

The first clause matches *every* string. The second is unreachable.
The compiler will usually warn — read the warnings.

---

## Guards

Patterns match *shape*. Sometimes you need to check a *property*
(positive? a list? non-empty?) too. That's what guards are for.

--

### Basics

```
def classify(n) when n < 0, do: :negative
def classify(0),            do: :zero
def classify(n) when n > 0, do: :positive
```

The `when …` is a guard. The clause runs only if the pattern matches
*and* the guard is true.

--

### Combining and built-in guards

You can combine with `and` / `or`:

```
def small?(n) when is_integer(n) and n < 10, do: true
def small?(_), do: false
```

Many built-in guards exist: `is_integer/1`, `is_binary/1`,
`is_list/1`, `is_atom/1`, `is_map/1`, and more.

--

### Common mistake — arbitrary functions in guards

Only specific "guard-safe" functions are allowed inside `when`. Your
own functions are *not*. If you write `when my_check(n)`, Elixir
will refuse to compile.

Use the built-ins; if you need richer logic, do it in the body.

--

### Recap

- `when` adds a property check on top of the pattern.
- Use built-in guards like `is_integer/1`.
- No user-defined functions inside `when`.

---

## Next: lesson 04 — control flow

`case`, `cond`, `with` are mostly more pattern matching.

```
make slides-dev LESSON=04-control-flow
```
