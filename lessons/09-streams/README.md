# Lesson 09: Streams

By the end of this lesson, you'll use `Stream` to define infinite sequences and to process files lazily — bigger than memory if needed. You'll see that the difference between `Enum` and `Stream` is "results now" vs "a recipe for results when you ask."

## Key ideas

Recall from lesson 06: `Enum.map` returns a new list immediately. Sometimes you don't want that — either the source is infinite (you only need the first N items), or the source is huge (the whole list won't fit in memory), or you're piping into another operation and the intermediate list is wasted work.

- **Streams are recipes, not results.** `Stream.iterate(0, &(&1 + 1))` describes "every natural number." Nothing is computed until you ask for elements with `Enum.take/2`, `Enum.to_list/1`, or any other `Enum.*` function.
- **`Stream.iterate/2`, `Stream.repeatedly/1`, `Stream.cycle/1`** — three ways to make an infinite stream.
- **`Stream.map/2`, `Stream.filter/2`** — same shape as the `Enum` versions but lazy. Chain them; nothing is computed until you cap the stream with an `Enum.*` call.
- **`File.stream!/1`** — opens a file as a line-by-line stream. Lets you process arbitrarily big files in constant memory.

> 💡 **First time seeing this?** "Lazy" here doesn't mean slow — it means "deferred." A stream is a blueprint. The actual reading-and-mapping happens only when you ask for output. That's how you can describe "every Fibonacci number" without your program freezing.

## Try it in IEx

```
iex> Stream.iterate(1, &(&1 * 2)) |> Enum.take(5)
[1, 2, 4, 8, 16]
iex> Stream.iterate(0, &(&1 + 1)) |> Stream.filter(&(rem(&1, 2) == 0)) |> Enum.take(4)
[0, 2, 4, 6]
iex> File.stream!("/etc/hosts") |> Enum.count()
... # some number, depending on your /etc/hosts
```

The first line builds an infinite stream of powers of two; `Enum.take(5)` says "give me the first five." Everything in the middle is lazy.

> 💡 **First time seeing this?** Look at the second line carefully. `Stream.iterate` is infinite. `Stream.filter` is also infinite (filtering an infinite stream is still infinite). The whole thing only stops being infinite when you put `Enum.take(4)` on the end. That's the lazy-vs-eager distinction in one line.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=09-streams` from the repo root).
- Open `iex` and play with `Stream.iterate` until the laziness clicks.
- `cd exercises && mix test --include pending` — make the three failing tests pass.
- Drill 3 reads a fixture file at `test/fixtures/sample.log` — that file is provided for you.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Calling `Enum.map` on a stream. It works — but you've thrown away laziness. `Enum.map` materialises the full list; the stream stops being a stream once you do.
- Forgetting to "cap" the stream. `Stream.iterate(0, &(&1 + 1))` by itself doesn't do anything useful — pipe it into `Enum.take/2`, `Enum.reduce_while/3`, or another terminator. The shell will print `#Stream<...>` if you forget.
- Using `File.read!` when the file is huge. `File.read!` slurps the whole file into memory; `File.stream!` reads line by line.

## Going further

- Implement a streaming `Enum.uniq` equivalent — keep a `MapSet` of seen items in a `Stream.transform/3` chain.
- What does `Stream.transform/3` do? Find one use case it makes easier than `Stream.map`.
- Try `File.stream!` on a really big file (say, a multi-GB log) and compare memory usage against `File.read!` + `String.split("\n")`.

## Links

- [HexDocs — Stream](https://hexdocs.pm/elixir/Stream.html)
- [HexDocs — File](https://hexdocs.pm/elixir/File.html)
