# Lesson 09
## Streams

Lazy enumeration — recipes for results, not results.

---

## What we'll do

- Build an infinite stream with `Stream.iterate`.
- Filter and limit it lazily.
- Process a file line-by-line without slurping.

---

## Streams are recipes

`Enum` walks a list and returns a new list. `Stream` describes the
walk; it only runs when you ask for output.

--

### Eager (Enum) vs lazy (Stream)

```
iex> Enum.map([1, 2, 3], &(&1 * 2))
[2, 4, 6]
iex> Stream.map([1, 2, 3], &(&1 * 2))
#Stream<[enum: [1, 2, 3], funs: [#Function<...>]]>
```

The second line returns a *plan*, not a list. Nothing has happened
yet.

--

### Build an infinite stream

```
iex> Stream.iterate(1, &(&1 * 2)) |> Enum.take(5)
[1, 2, 4, 8, 16]
```

`Stream.iterate(seed, fn)` is "start from `seed`, apply `fn` forever."
`Enum.take(5)` caps it at the first five elements.

--

### Common mistake — forgetting to cap

```
iex> Stream.iterate(0, &(&1 + 1))
#Stream<[enum: ..., funs: [...]]>
```

No `Enum.*` terminator → nothing happens. The stream just sits there
as a description.

---

## Lazy map/filter

`Stream.map` and `Stream.filter` chain like `Enum`, but they don't
materialise intermediate lists.

--

### Chain lazily

```
iex> Stream.iterate(0, &(&1 + 1))
...> |> Stream.filter(&(rem(&1, 2) == 0))
...> |> Enum.take(4)
[0, 2, 4, 6]
```

Filter the infinite stream of naturals to evens, take the first four.
No 100-element intermediate list is ever built.

--

### Bounded with `take_while`

```
iex> 0
...> |> Stream.iterate(&(&1 + 1))
...> |> Stream.take_while(&(&1 < 5))
...> |> Enum.to_list()
[0, 1, 2, 3, 4]
```

`take_while` stops as soon as the predicate becomes false.

--

### Common mistake — `Enum.map` mid-pipeline

```
iex> 1..1_000_000
...> |> Enum.map(&(&1 * 2))      # materialises 1M-element list HERE
...> |> Stream.filter(...)
...> |> Enum.take(3)
```

Mixing `Enum` and `Stream` is fine, but every `Enum.*` in the middle
of a pipeline materialises that point in memory. Save them for the
end.

---

## File streaming

`File.stream!` opens a file as a line stream. Read line by line, no
matter how big the file.

--

### The basic shape

```elixir
File.stream!("path/to/file.log")
|> Stream.filter(&String.contains?(&1, "ERROR"))
|> Enum.count()
```

Open, filter to the lines you care about, terminate by counting.
Constant memory regardless of file size.

--

### What you get per line

Each element is the line *including* the trailing newline. If you
need the line without the newline, `String.trim_trailing/1` is the
common cleanup.

--

### Common mistake — `File.read!` for big files

`File.read!` returns the entire file as one binary. Fine for small
configs; catastrophic for a 10 GB log. When you don't know the size,
default to `File.stream!`.

--

### Recap

- `File.stream!` → line stream.
- Chain `Stream.*` for lazy ops.
- Terminate with an `Enum.*` (count, to_list, reduce).

---

## Where this leads

Lazy enumeration shows up everywhere in production Elixir:

- Processing log files at scale.
- Reading data from external APIs page by page.
- Building infinite "tick" streams for testing time-based code.

Get comfortable with the recipe-vs-result model and big-data work
in Elixir gets a lot less scary.

---

## Next: lesson 10 — structs and protocols

Define your own named types. Hook into stdlib's polymorphism.

```
make slides-dev LESSON=10-structs-and-protocols
```
