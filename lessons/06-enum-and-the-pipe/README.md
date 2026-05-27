# Lesson 06: Enum and the pipe

By the end of this lesson, you'll use `Enum.map`, `Enum.filter`, and `Enum.reduce` plus the
pipe operator `|>` — the way most Elixir code actually walks lists.

## Key ideas

- **Recall from lesson 05:** you wrote recursive functions that walked a list head-by-tail —
  `Sum.of/1`, `Mapper.double_all/1`, and friends. Two clauses, base case, recurse on the tail.
  `Enum` is that recursion written for you, once, by the standard library, for every common
  shape of "do something to every element."
- **`Enum.map/2`** applies a function to every element and returns a new list of the same
  length. That's exactly the `[h * 2 | double_all(t)]` shape from lesson 05 — except instead
  of writing a module, you write `Enum.map(list, &(&1 * 2))` and you're done.
- **`Enum.filter/2`** keeps only the elements where the predicate returns truthy. The output
  is a list of the same elements, in the same order, but possibly shorter. No transformation
  of the elements themselves — that's `map`'s job.
- **`Enum.reduce/3`** is the generalised fold. "Give me a starting jar and a recipe for
  adding the next item." `Enum.reduce(list, 0, &+/2)` sums. `Enum.reduce(list, 0, fn _, acc
  -> acc + 1 end)` counts. `Enum.reduce(list, %{}, fn x, acc -> Map.put(acc, x, true) end)`
  builds a map. Any time you're collapsing a list down to a single value (or building up
  something different-shaped), `reduce` is the tool.
- **The pipe operator `|>`** rewrites `x |> f(y)` as `f(x, y)` — it takes the value on the
  left and passes it as the *first* argument to the function on the right. Chains of pipes
  let you read transformations left-to-right, top-to-bottom, instead of having to read
  nested function calls inside-out.

> 💡 **First time seeing this?** The expression `&(&1 * 2)` is Elixir's shorthand for an
> anonymous function — it's the same as writing `fn x -> x * 2 end`. The `&1` means "the
> first argument." You'll see this everywhere in `Enum` calls because it's compact. If it
> looks weird right now, that's fine — the longer `fn x -> ... end` form works identically.

## Try it in IEx

Open `iex` from the repo root:

```
iex> Enum.map([1, 2, 3], &(&1 * 2))
[2, 4, 6]
iex> Enum.filter([1, 2, 3, 4], &(rem(&1, 2) == 0))
[2, 4]
iex> Enum.reduce([1, 2, 3, 4], 0, &+/2)
10
iex> [1, 2, 3, 4]
...> |> Enum.filter(&(rem(&1, 2) == 0))
...> |> Enum.map(&(&1 * &1))
...> |> Enum.sum()
20
```

Three independent calls, then one pipeline. The pipeline reads top-to-bottom: start with a
list, keep the evens, square each one, sum. The list flows through. That's the whole idea.

> 💡 **First time seeing this?** Pipes feel strange until they don't. Without the pipe, the
> pipeline above would be `Enum.sum(Enum.map(Enum.filter([1, 2, 3, 4], &(rem(&1, 2) == 0)),
> &(&1 * &1)))` — you read it inside-out, from the deepest paren outward. With the pipe you
> read it in the order the data moves. Same code, easier eyes.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=06-enum-and-the-pipe` from the repo
  root).
- Open `iex` and play. Try `Enum.map`, `Enum.filter`, `Enum.reduce` on a few lists.
- `cd exercises && mix test --include pending` — make the failing tests pass by editing the
  files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished (or Hint 3 still hasn't unstuck
  you).

## Common mistakes

- **Confusing `&(&1 + 1)` with `&Foo.bar/1`.** Both start with `&`. The first is the
  anonymous-function shorthand (`fn x -> x + 1 end`). The second is a *function capture* —
  it references an existing named function. Both are valid; the first is inline, the second
  points at code you've already written. `Enum.map(list, &String.upcase/1)` is identical to
  `Enum.map(list, fn s -> String.upcase(s) end)`.
- **Where to put `|>` on multi-line pipelines.** Community convention: at the *start* of the
  continuation line, not the end of the previous one. That way commenting out a step is one
  line, not two. Your formatter (`mix format`) enforces this.
- **Reaching for `Enum.map` when `Enum.reduce` is the right tool — or vice versa.** Rule of
  thumb: use `map` when the output is one-element-per-input-element (same length, same
  shape). Use `reduce` when you're collapsing the list to a single value, or building
  something different-shaped (a map, a count, a tuple). If you find yourself writing
  `Enum.map(list, ...) |> Enum.sum()`, that's two passes — a single `Enum.reduce` would do
  it in one, though the two-pass version is often clearer.

## Going further

- Find an `Enum.reduce` in your own code or any open-source Elixir project. Trace what's
  happening on each iteration — what's the accumulator's type? What does each step
  contribute?
- Try `Enum.flat_map/2`. When is it different from `Enum.map/2 |> Enum.concat/1`? (Hint:
  they're semantically equivalent, but one is a single pass.)

## Links

- [HexDocs — Enum](https://hexdocs.pm/elixir/Enum.html)
- [Elixir School — Enum](https://elixirschool.com/en/lessons/basics/enum/)
