# Lesson 08
## Strings and binaries

The same bytes, two ways of looking at them.

---

## What we'll do

- Use the everyday `String` ops.
- Take binaries apart with `<<>>` pattern matching.
- Glance at sigils.
- Wire it all together in a tiny KV parser.

---

## String operations

The `String` module is your everyday toolkit for text. Almost any
string-manipulation job is one of these, or a pipe of them.

--

### The basics

```
iex> String.upcase("hello")
"HELLO"
iex> String.split("a, b, c", ", ")
["a", "b", "c"]
iex> String.replace("hello world", "world", "Elixir")
"hello Elixir"
```

--

### Length vs byte size

```
iex> String.length("hello")
5
iex> byte_size("hello")
5
iex> String.length("é")
1
iex> byte_size("é")
2
```

`String.length/1` counts characters. `byte_size/1` counts bytes.

--

### Common mistake

Concatenation is `<>`, not `+`.

```
iex> "hello" + " world"
** (ArithmeticError)
iex> "hello" <> " world"
"hello world"
```

`+` is numeric only. Strings live in `<>` (the binary concat operator).

---

## Binary syntax and pattern matching

Strings are just binaries that happen to contain UTF-8. You can write
binaries directly with `<<>>` and pull them apart with the same syntax.

--

### Strings are binaries

```
iex> "hi" == <<104, 105>>
true
iex> is_binary("hi")
true
iex> is_binary(<<1, 2, 3>>)
true
```

Same bytes, different way of writing the literal.

--

### Pattern matching into a binary

```
iex> <<version, length, rest::binary>> = <<1, 4, "data">>
<<1, 4, "data">>
iex> version
1
iex> length
4
iex> rest
"data"
```

`<<>>` patterns work just like `[h | t]` for lists — peel off the
shape you know about, bind the rest.

--

### Common mistake — forgetting size

```
iex> <<a, b, rest::binary>> = <<1, 2, 3, 4>>
iex> a
1
iex> b
2
```

`a` and `b` each match **one byte**. If you want a multi-byte field,
say so: `<<version::16, length::16, rest::binary>>` matches two 16-bit
fields. The size qualifier is mandatory whenever the slot isn't a
single byte.

---

## Sigils

Sigils are compile-time shortcuts for literals that would be noisy with
the usual syntax. You'll see a few; you'll write `~w` and `~r` most.

--

### Word lists

```
iex> ~w(red green blue)
["red", "green", "blue"]
```

`~w(...)` is "list of words." Same as `["red", "green", "blue"]` but
shorter for literals.

--

### Regex (preview)

```
iex> Regex.run(~r/hello (\w+)/, "hello world")
["hello world", "world"]
```

`~r/.../` builds a regex literal. We won't write regex in any drill
today — just know the sigil exists.

--

### Recap

- `~w(a b c)` → list of strings.
- `~r/.../` → regex.
- Other sigils exist (`~D` dates, `~T` times, …) — you'll meet them when
  you need them.

---

## Putting it together — a tiny KV parser

`"name=Aki"` should become `{"name", "Aki"}`. One String op, one pattern
match, done.

--

### Step 1 — split with `parts: 2`

```
iex> String.split("name=Aki", "=", parts: 2)
["name", "Aki"]
iex> String.split("greeting=hello=world", "=", parts: 2)
["greeting", "hello=world"]
```

`parts: 2` stops after the first split, so equals signs inside the
value are preserved.

--

### Step 2 — pattern-match the result

```elixir
def parse_line(line) do
  [key, value] = String.split(line, "=", parts: 2)
  {key, value}
end
```

Two-element list, pattern-match on the shape, return the tuple.

--

### Recap

- String ops for everyday text work.
- `<<>>` for byte-level destructuring.
- Sigils for compact literals.
- Combine them when the data needs both layers.

---

## Next: lesson 09 — streams

Lazy enumeration. Process bigger-than-memory files line by line.

```
make slides-dev LESSON=09-streams
```
