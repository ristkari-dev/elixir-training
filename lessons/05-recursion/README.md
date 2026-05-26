# Lesson 05: Recursion

By the end of this lesson, you'll write your own recursive list functions — the way Elixir replaces `for` loops. You'll see the base-case-plus-recursive-case shape that shows up in every Elixir codebase you'll ever read.

## Key ideas

- **Recursion is calling yourself with the rest of the work.** A recursive function does a small amount of work on one piece, then calls itself with everything except that piece. Eventually it runs out of work and stops (the base case). In practice it's almost mechanical: peel off the front, deal with it, hand the rest of the list back to yourself. Repeat.
- **The base case is what happens when there's no work left.** For lists, that's the empty list `[]`. Define this clause first; it's how recursion terminates. If you forget it, Elixir raises `FunctionClauseError` — the runtime's way of saying "you forgot to tell me when to stop."
- **Head/tail decomposition.** `[h | t] = [1, 2, 3]` gives `h = 1` and `t = [2, 3]`. Patterns in function heads use this to peel off one element at a time. (Recall from lesson 02 — this is pattern matching against the cons cell shape that lists are built from.)
- **The accumulator pattern.** Sometimes you need to "carry forward" a running result while you recurse — a count, a reversed list, a sum-so-far. The trick: write a helper function with an extra argument (the accumulator), and a public wrapper that supplies the initial value. Conventional name: prefix the helper with `do_` (e.g. `reverse/1` calls `do_reverse/2`).
- **One sentence on tail-call optimisation.** Elixir is smart: if the recursive call is the very last thing a function does — no `+ something`, no `[h | ...]` wrapping it — the runtime doesn't grow the stack. Infinite-looking recursion (millions of items) doesn't blow up. You'll rarely have to think about it, but it's why accumulator-style helpers are so common.

> 💡 **First time seeing this?** `[h | t]` is the same pattern you saw in lesson 02. It says "match a list with a first element `h` and the rest (which is also a list) `t`." It does *not* match `[]` — the empty list has no head and no tail. That's why you write the `[]` clause separately. Two clauses, two cases: empty and non-empty.

## Try it in IEx

Open `iex` and define a recursive sum interactively:

```
iex> defmodule Sum do
...>   def of([]), do: 0
...>   def of([h | t]), do: h + of(t)
...> end
{:module, Sum, ..., {:of, 1}}
iex> Sum.of([1, 2, 3])
6
iex> Sum.of([])
0
iex> [h | t] = [10, 20, 30]
[10, 20, 30]
iex> h
10
iex> t
[20, 30]
```

Two clauses. The first matches the empty list and returns `0`. The second peels off `h`, computes `of(t)` on the tail, and adds them. `Sum.of([1, 2, 3])` unrolls to `1 + (2 + (3 + 0))` — the `0` at the bottom is your base case kicking in.

> 💡 **First time seeing this?** Look at how `of/1` calls itself in the second clause. That's recursion. No `for` loop — the function calls itself with a *smaller* list each time, until the list is empty, the base case fires, and everything unwinds. If this feels strange, trace `Sum.of([1, 2])` on paper: `1 + of([2])` → `1 + (2 + of([]))` → `1 + (2 + 0)` → `3`.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=05-recursion` from the repo root).
- Open `iex` and play. Define `Sum.of/1` yourself. Try forgetting the base case and see what error you get.
- `cd exercises && mix test --include pending` — make the failing tests pass by editing the files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished (or Hint 3 still hasn't unstuck you).

## Common mistakes

- **Forgetting the base case.** No `def f([]), do: ...` clause means the empty list has nothing to match against, and you get `FunctionClauseError`. Elixir refuses to call a function with no matching clause.
- **Putting the recursive case before the base case.** Clause order matters: Elixir tries them top-to-bottom. `[]` and `[h | t]` are mutually exclusive — only one will match — but the convention is to write the base case first, to match the way you think about the problem ("when is this *done*?").
- **Trying to update a "running total" by reassigning a variable.** Elixir is immutable — `total = total + h` doesn't carry across recursive calls the way it would in Python or JavaScript. Use the accumulator pattern: pass the running total as a function argument and recurse with the updated value.

## Going further

- Try implementing `MyEnum.filter/2` with recursion: take a list and a predicate, return a new list of elements where `pred.(x)` is true. Three clauses if you want; two clauses and a `case` inside the recursive one works fine too.
- Look up "tail call optimisation Elixir" — what does it mean for `Mapper.double_all/1` vs `Reverser.reverse/1`? One of them grows the stack with each recursive call; the other doesn't. Can you tell which, just by looking?

## Links

- [HexDocs — List](https://hexdocs.pm/elixir/List.html)
- [Elixir School — Recursion](https://elixirschool.com/en/lessons/basics/recursion/)
