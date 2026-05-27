# Lesson 11: Error handling

By the end of this lesson, you'll know when to return `{:ok, _}`/`{:error, _}` vs when to raise, and you'll have written `with` chains that compose fallible steps cleanly. Lesson 04 gave you a preview; this lesson goes deeper, especially the `else` clause that lets you re-route failures.

## Key ideas

Recall from lesson 04: `with` lets you chain steps that each return `{:ok, value}` and short-circuit on the first failure. The preview was deliberately shallow. Now we'll see `else` clauses and the broader "tagged tuple" convention that makes `with` work.

- **The tagged-tuple convention.** `{:ok, value}` for success; `{:error, reason}` for expected failure. Used everywhere in Elixir (Phoenix, Ecto, Plug, the stdlib's `File.read/1`, `Integer.parse/1`, …). When in doubt, follow this shape.
- **`raise` is for things that should never happen.** Network call failed? Return `{:error, _}`. File didn't have the expected format because the file is corrupt and you don't know how to recover? Raise. The rule of thumb: if a sensible caller would want to retry/handle it, return a tuple; if not, raise.
- **`with` revisited.** Each `<-` clause is a pattern match. If it matches (the `{:ok, value}` shape), the next clause runs. If it doesn't, the failed value is the whole expression's result — unless you provide an `else` clause that can transform it.
- **`try`/`rescue` exists** but is rarely needed in idiomatic Elixir. Use it for cleaning up resources (`try ... after`) or for interop with code that raises. If you're writing your own code, prefer tagged tuples.

> 💡 **First time seeing this?** "Tagged tuple" is jargon for "a tuple whose first element is an atom that says what's inside." `{:ok, 42}` and `{:error, :not_found}` are both tagged tuples. The atom is the tag; the rest is the payload. Pattern matching on the tag is how you branch on success vs failure.

## Try it in IEx

```
iex> case Integer.parse("42") do
...>   {n, ""} -> {:ok, n}
...>   _ -> {:error, :invalid}
...> end
{:ok, 42}
iex> with {:ok, x} <- {:ok, 1},
...>      {:ok, y} <- {:ok, 2} do
...>   {:ok, x + y}
...> end
{:ok, 3}
iex> with {:ok, x} <- {:ok, 1},
...>      {:ok, y} <- {:error, :boom} do
...>   {:ok, x + y}
...> end
{:error, :boom}
```

The third example shows the short-circuit: the second `<-` didn't match `{:ok, y}`, so `{:error, :boom}` is the whole expression's result.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=11-error-handling` from the repo root).
- Open `iex` and play with `with` — try chains where everything succeeds, where the first step fails, where the last step fails.
- `cd exercises && mix test --include pending` — three drills.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Returning bare values instead of tagged tuples. `def fetch(url), do: response` is less composable than `def fetch(url), do: {:ok, response}`. Once you start using `with`, every function that returns a "maybe-failed" result wants the tuple shape.
- Rescuing too broadly. `rescue _ -> ...` swallows all errors, including bugs you want to see. Catch specific exception types (`rescue e in [ArgumentError, ArithmeticError] -> ...`) or don't rescue at all.
- Forgetting the `else` clause in `with`. Without it, the first non-matching `<-` value falls through as the whole expression's result. Often that's what you want, but be explicit about your error shape — `else` lets you remap.

> 💡 **First time seeing this?** "Short-circuit" in this lesson means "stop early." When a `with` step fails, no further steps run. This is the same pattern as `&&` in JavaScript or `and` in Python — but applied to tagged tuples instead of booleans.

## Going further

- Write a `with` chain where the `else` clause logs the error and returns a sentinel `:fallback`.
- Look up `Kernel.then/2` — when is it useful inside a `with` chain (or anywhere)?
- Read the `File.read/1` docs — what does success and failure look like?

## Links

- [HexDocs — with](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1)
- [HexDocs — try/catch/rescue](https://hexdocs.pm/elixir/try-catch-and-rescue.html)
