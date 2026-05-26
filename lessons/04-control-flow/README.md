# Lesson 04: Control flow

By the end of this lesson, you'll use `case`, `cond`, and `with` to write branching code — and you'll see that they're all forms of pattern matching. If lesson 02 taught you to read `=` as "make these shapes match" and lesson 03 taught you to write multiple `def` clauses, this lesson is the same idea wearing different clothes.

## Key ideas

- **`case`** is *multiple function clauses, inline.* Instead of declaring two `def hello/1`s with different patterns, you can hold a value and ask "which of these shapes does it look like?" right inside a function body. `case value do {:ok, x} -> x; {:error, _} -> :failed end` is exactly the same machinery as two `def` clauses — the patterns on the left, the body on the right, top-to-bottom matching. Same rules: most specific first, catch-all last. If nothing matches, you get a `CaseClauseError`.
- **`cond`** is *first truthy condition wins.* When you can't naturally pattern-match — say, you want to branch on `n < 0` vs `n == 0` vs `n > 0` — `cond` walks a list of boolean expressions top-to-bottom and runs the body of the first truthy one. It's the closest thing Elixir has to an `else if` chain in other languages. The convention is to end with `true ->` as a catch-all; without one, if nothing is truthy you get a `CondClauseError`.
- **`with`** is *a chain of `{:ok, _}` steps that short-circuits on the first `{:error, _}`.* Each `<-` line tries to match its left side against its right side. If they match, the bindings are available to the next line. If they *don't*, `with` stops right there and gives back the value that failed to match. It's pattern matching turned into a pipeline of "must succeed before we continue."
- **`if` / `unless`** exist and they read nicely for one-line yes/no questions (`if x > 0, do: :positive, else: :negative`), but they're *sugar over `case`*. In real Elixir code you'll reach for `case`, `cond`, multiple `def` clauses, or a `with` chain far more often than `if`. Don't avoid `if` — but don't reach for it first.

> 💡 **First time seeing this?** All three of `case`, `cond`, `with` are *expressions*, not statements. They return a value — the body of whichever branch ran. That means you can put the whole thing on the right side of `=` (`status = case x do ... end`) or use it as the last expression in a function. There's no separate "return" keyword in Elixir; the last expression *is* the return value.

## Try it in IEx

Open `iex` and type these one at a time:

```
iex> case {1, 2} do
...>   {1, x} -> x
...>   _ -> :nope
...> end
2
iex> cond do
...>   1 > 2 -> :a
...>   true -> :b
...> end
:b
iex> with {:ok, n} <- {:ok, 10},
...>      {:ok, m} <- {:ok, n + 1} do
...>   {:ok, m}
...> end
{:ok, 11}
iex> with {:ok, n} <- {:error, :boom},
...>      {:ok, m} <- {:ok, n + 1} do
...>   {:ok, m}
...> end
{:error, :boom}
```

The `case` extracts `2` because `{1, 2}` matches `{1, x}` and binds `x = 2`. The `cond` skips `1 > 2` (false), takes `true` (always truthy), and returns `:b`. The first `with` runs both steps and returns `{:ok, 11}`. The second `with` fails on the first step and gives back `{:error, :boom}` unchanged — it never even tries the second step.

> 💡 **First time seeing this?** Notice how `with` doesn't unwrap the failure into something else. The value that broke the chain (`{:error, :boom}`) is what comes out. That's the whole short-circuit: "stop here, hand back the offending value, we're done."

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=04-control-flow` from the repo root).
- Open `iex` and play. Type a `case` on a tuple. Try a `cond` with no truthy branch and read the error.
- `cd exercises && mix test --include pending` — make the failing tests pass by editing the files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished (or Hint 3 still hasn't unstuck you).

## Common mistakes

- A `cond` with no truthy clause raises `CondClauseError`. Always end with `true ->` as a catch-all unless you've proved every prior condition covers every input.
- A `case` with no matching clause raises `CaseClauseError` at runtime. The compiler often warns, but not always. If the input could be anything, end with `_ ->` as a catch-all.
- `with` short-circuits on the *whole* failing value, not an unwrapped version of it. If `step1` returns `{:error, :boom}` and your pattern is `{:ok, x}`, `with` hands back `{:error, :boom}` — not `:boom`, not `nil`. If you need to transform the error, use an `else` block on the `with`.

## Going further

- Rewrite Drill 1's `Sign.of/1` using three `def` clauses with guards (lesson 03 style) instead of `cond`. Compare both versions side-by-side. Which one reads better to you? There isn't a single right answer — guards win when the branches map onto function inputs, `cond` wins when the conditions are messier or computed.
- In a `with`, what does the `else` clause do? Try this in iex:
  ```
  iex> with {:ok, x} <- {:error, "nope"} do
  ...>   x
  ...> else
  ...>   error -> error
  ...> end
  ```
  Then try changing the `else` to `_ -> :handled`. `else` lets you intercept and transform a short-circuited value before it leaves the `with`.

## Links

- [HexDocs — Case, cond and if](https://hexdocs.pm/elixir/case-cond-and-if.html)
- [HexDocs — with](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1)
