# Hints for Lesson 08: Strings and binaries

Read one hint at a time. Try the exercise again before reading the next.

## Drills 1+2: Letters.vowel_count/1 and Letters.title_case/1

### Hint 1 — vowel_count

Use `String.graphemes/1` to split the string into a list of single
characters, then count the ones that are vowels. Lower-case the input
first so the predicate doesn't have to check `"A"` and `"a"` separately.

### Hint 2 — vowel_count

```elixir
s |> String.downcase() |> String.graphemes() |> Enum.count(&(&1 in ["a", "e", "i", "o", "u"]))
```

### Hint 3 — vowel_count

```elixir
def vowel_count(s) do
  s
  |> String.downcase()
  |> String.graphemes()
  |> Enum.count(&(&1 in ["a", "e", "i", "o", "u"]))
end
```

### Hint 1 — title_case

Split on spaces, capitalise each word, join back with a space.

### Hint 2 — title_case

```elixir
s |> String.split(" ") |> Enum.map(&String.capitalize/1) |> Enum.join(" ")
```

### Hint 3 — title_case

```elixir
def title_case(s) do
  s
  |> String.split(" ")
  |> Enum.map(&String.capitalize/1)
  |> Enum.join(" ")
end
```

## Drill 3: Header.parse/1

### Hint 1

Pattern-match the first two bytes into named values; bind the rest as
a binary. Do it in the function head — no body logic needed.

### Hint 2

`def parse(<<version, length, rest::binary>>), do: {version, length, rest}`.

### Hint 3

```elixir
def parse(<<version, length, rest::binary>>), do: {version, length, rest}
```

## Drill 4: KV.parse_line/1

### Hint 1

`String.split/3` accepts a `parts: 2` option that stops after the first
split, so `"a=b=c"` becomes `["a", "b=c"]` rather than `["a", "b", "c"]`.

### Hint 2

```elixir
[key, value] = String.split(line, "=", parts: 2)
{key, value}
```

### Hint 3

```elixir
def parse_line(line) do
  [key, value] = String.split(line, "=", parts: 2)
  {key, value}
end
```
