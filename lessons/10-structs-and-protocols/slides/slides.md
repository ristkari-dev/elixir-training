# Lesson 10
## Structs and protocols

Named, shape-locked maps. Plus a glimpse of polymorphism.

---

## What we'll do

- Define a struct with `defstruct`.
- Enforce required keys with `@enforce_keys`.
- Implement one stdlib protocol (`String.Chars`).

---

## `defstruct` — a named map

A struct is a map with a known shape and default values. Define one
inside a `defmodule`.

--

### The basics

```elixir
defmodule Point do
  defstruct [:x, :y]
end
```

Two fields, both default to `nil`. The struct's name *is* the module
name.

--

### Create and use

```
iex> %Point{x: 1, y: 2}
%Point{x: 1, y: 2}
iex> p = %Point{x: 1, y: 2}
iex> p.x
1
iex> %{p | y: 5}
%Point{x: 1, y: 5}
```

Map syntax works on structs because structs are maps under the hood.

--

### A constructor function

```elixir
def new(x, y), do: %__MODULE__{x: x, y: y}
```

`__MODULE__` is the current module. Conventional — keeps the
constructor stable if the module is later renamed.

--

### Common mistake — pattern matching

```
iex> %Point{x: x} = %{x: 1, y: 2}
** (MatchError)
```

A plain map doesn't match a struct pattern. The other way around does:

```
iex> %{x: x} = %Point{x: 1, y: 2}
%Point{x: 1, y: 2}
```

---

## `@enforce_keys` — required fields

Sometimes there's no sensible default. `@enforce_keys` lists fields
that must be provided at creation time.

--

### Syntax

```elixir
defmodule Box do
  @enforce_keys [:width, :height]
  defstruct [:width, :height]

  def area(%Box{width: w, height: h}), do: w * h
end
```

Must come immediately before `defstruct`.

--

### Caller sees the constraint at compile time

```
iex> %Box{width: 1}
** (ArgumentError) the following keys must also be given: [:height]
iex> %Box{width: 1, height: 2}
%Box{width: 1, height: 2}
```

Missing keys → compile error or `ArgumentError` from `struct!/2`.

--

### When to use

- All fields are required → enforce them all.
- Some are required, some have sensible defaults → enforce just the
  required ones.
- Skip `@enforce_keys` entirely if `nil` is genuinely OK everywhere.

---

## Protocols — one function, many types

A protocol declares a function signature. Different types provide
their own implementations. `to_string/1` works on integers, atoms,
binaries, dates… because each has a `String.Chars` impl.

--

### The motivation

```
iex> to_string(42)
"42"
iex> to_string(:hello)
"hello"
iex> to_string(%Point{x: 1, y: 2})
** (Protocol.UndefinedError) protocol String.Chars not implemented for Point
```

`to_string/1` doesn't know about `Point`. Until we tell it.

--

### `defimpl` — implement a protocol for a type

```elixir
defimpl String.Chars, for: Point do
  def to_string(%Point{x: x, y: y}), do: "(#{x}, #{y})"
end
```

Place after the `defmodule Point ... end` block in the same file.
Now `to_string(%Point{x: 1, y: 2})` returns `"(1, 2)"`.

--

### What protocols give you

- Polymorphism — write code against the protocol, not the type.
- Extensibility — add a new type later without changing the protocol.
- Stdlib hooks — `Inspect`, `String.Chars`, `Enumerable`,
  `Collectable`, `JSON.Encoder` (in third-party libs).

We've only touched `String.Chars`. The pattern repeats.

---

## Where this leads

Structs are everywhere in production Elixir:

- Phoenix changesets, Ecto schemas.
- LiveView state, GenServer state.
- Domain models (`%User{}`, `%Order{}`, `%Invoice{}`).

Protocols power most of the stdlib's "this just works" feeling.
`Enum.map` works on lists, maps, ranges, streams because of
`Enumerable`. The same hook is open to your structs.

---

## Next: lesson 11 — error handling

`{:ok, _}` / `{:error, _}` and `with`-chains revisited.

```
make slides-dev LESSON=11-error-handling
```
