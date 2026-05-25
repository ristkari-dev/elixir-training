# Lesson 02: Pattern matching

By the end of this lesson, you'll understand why `=` is called *match* and not *assign* — and you'll have started destructuring tuples like a native. This is the lesson where `x = 1` stops being obvious. It's worth slowing down: pattern matching is the load-bearing idea Elixir leans on everywhere, and once it clicks, a lot of the language goes from "weird" to "obvious."

## Key ideas

- **`=` is the match operator.** Imagine the value on the right as a parcel, and the left side as a shape on the table. If the parcel fits the shape, the program continues — and any named slots in the shape get filled with the matching parts. If the parcel doesn't fit, Elixir raises a `MatchError` and stops. That's it. That's pattern matching.
- **Destructuring tuples and lists.** Once `=` is a shape-matcher, you can pull pieces out of compound values in one line. `{a, b} = {1, 2}` binds `a = 1` and `b = 2`. For lists, `[h | t] = [1, 2, 3]` gives `h = 1` (the head) and `t = [2, 3]` (the tail — *everything else*).
- **The `_` wildcard.** Use `_` when you want to assert a shape but don't care about a particular slot. `{_, second} = {1, 2}` binds only `second`. `_` is the "I don't care" marker — you can't read it back later.
- **Literal matching.** Patterns can include constants. `{:ok, value} = {:ok, 42}` does two things at once: it asserts the tag is the atom `:ok`, and it binds `value` to `42`. `{:ok, value} = {:error, "nope"}` raises `MatchError` because the constant `:ok` on the left doesn't match `:error` on the right.
- **Rebinding.** Elixir lets you re-`=` a name — `x = 1` then `x = 2` is fine, `x` is now `2`. (Aside: Erlang, Elixir's parent language, doesn't allow this — once-bound is forever-bound there. You can opt into Erlang-style "don't re-bind" using the pin operator `^`, but that's a stretch goal, not a requirement.)

> 💡 **First time seeing this?** "Destructuring" is just programmer-speak for "pulling pieces out of a compound value." If you've ever opened a parcel and laid the contents on the table, you've destructured. The compound value is the parcel; the shape on the left of `=` is your sorting tray.

## Try it in IEx

Open `iex` and type these one at a time:

```
iex> {a, b} = {1, 2}
{1, 2}
iex> a
1
iex> [h | t] = [1, 2, 3]
[1, 2, 3]
iex> h
1
iex> t
[2, 3]
iex> {_, second} = {1, 2}
{1, 2}
iex> second
2
iex> {:ok, value} = {:ok, 42}
{:ok, 42}
iex> value
42
iex> {:ok, value} = {:error, "nope"}
** (MatchError) no match of right hand side value: {:error, "nope"}
```

The last line is the one that surprises people the first time: the program *crashed* because the shape on the left didn't fit the parcel on the right. That's the match operator doing its job.

> 💡 **First time seeing this?** `MatchError` looks scary but it's just Elixir telling you the shape didn't fit. It's not silent corruption; it's a loud "this assumption was wrong." You'll see it a lot while learning, and that's fine.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=02-pattern-matching` from the repo root).
- Open `iex` and play with `=`. Try patterns that fit and patterns that don't. Watch for `MatchError`.
- `cd exercises && mix test --include pending` — make the failing tests pass by editing the files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished (or Hint 3 still hasn't unstuck you).

## Common mistakes

- Forgetting that `=` raises on mismatch. `{:ok, v} = {:error, "nope"}` is not a silent failure; it crashes loudly. That's a feature, not a bug.
- Reading `[h | t]` left-to-right as a list literal. It's destructuring. `h` is the *first element*; `t` is *everything else* (still a list). `[h | t] = [42]` gives `h = 42` and `t = []` (the empty list).
- Treating `_` as a real variable. It isn't — you can't read it back. `_ = 5` is legal (it matches and throws the value away); `_ + 1` is a compile error ("unbound variable _").
- Confusing `=` with `==`. `=` matches (and may bind). `==` compares and returns `true` or `false`. They're not interchangeable.

## Going further

- Try matching nested tuples in `iex`: `{:ok, {x, y}} = {:ok, {1, 2}}`. What does it bind?
- What does `[a, b, c | rest] = [1, 2, 3, 4, 5]` bind? Predict before typing.
- Try the pin operator `^` in `iex`: `x = 1; ^x = 2`. What happens? Now try `x = 1; ^x = 1`. Why does that work?

## Links

- [Elixir Getting Started — Pattern matching](https://hexdocs.pm/elixir/pattern-matching.html)
- [HexDocs — Kernel.match?/2](https://hexdocs.pm/elixir/Kernel.html#match?/2)
