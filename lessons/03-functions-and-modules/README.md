# Lesson 03: Functions and modules

By the end of this lesson, you'll write your own modules with named functions, anonymous `fn` expressions, and multiple clauses guarded by type. This is where you start writing Elixir, not just typing into IEx.

## Key ideas

- **Modules** are *a folder of related functions.* You group functions that belong together into a `defmodule` block. `defmodule MyMath do … end` declares a module called `MyMath`; everything you put between `do` and `end` is part of it. You've already seen one — the `defmodule Hello do … end` that `mix new hello` generated in lesson 00. Now you'll write your own.
- **Named functions** are the recipes inside that folder. You write them with `def name(args) do … end` or, for one-liners, `def name(args), do: result`. Elixir identifies a function by its *name and arity* (how many arguments it takes), written as `name/N`. So `double/1` is "the `double` function that takes 1 argument" — distinct from a hypothetical `double/2` that takes 2.
- **Anonymous functions** are functions without a name. You build them inline with `fn x -> x + 1 end`. You can bind one to a name (`square = fn x -> x * x end`) but it's still anonymous under the hood — the name is just a label. The catch: calling an anonymous function uses a *dot*: `square.(5)` returns `25`. The `&` shorthand makes short anonymous functions terser: `&(&1 * 2)` is the same as `fn x -> x * 2 end`, with `&1` standing in for the first argument.
- **Multiple clauses** are the second half of pattern matching. You can write two (or more) `def`s with the same name. When you call the function, Elixir tries each clause from top to bottom and runs the first one whose pattern matches. "Try this clause first; if its pattern doesn't match, try the next one" — that's the whole rule.
- **Guards** are an extra `when` check after the pattern. `def classify(n) when n < 0, do: :negative` says "match any value, bind it to `n`, but only run this clause when `n < 0`." Guards let you split on a value's *property* (positive? a list? non-empty?) on top of its *shape*.

> 💡 **First time seeing this?** A "module" sounds fancy, but it's just a named bag of functions in a file. Other languages call this a class, a namespace, or a package. In Elixir it's a `defmodule`. You'll write one per file (by convention) and call its functions with `ModuleName.function_name(args)`.

## Try it in IEx

Open `iex` and type these one at a time:

```
iex> double = fn x -> x * 2 end
#Function<...>
iex> double.(5)
10
iex> defmodule Greet do
...>   def hello(name), do: "Hello, " <> name <> "!"
...> end
{:module, Greet, ...}
iex> Greet.hello("world")
"Hello, world!"
iex> Enum.map([1, 2, 3], &(&1 * 10))
[10, 20, 30]
```

The first block defines an anonymous function and calls it (note the dot). The second defines a real module *inline in iex* — yes, you can do that — and calls its function the normal way (no dot). The third uses the `&` shorthand to multiply each element of a list by 10.

> 💡 **First time seeing this?** The dot in `double.(5)` is *not* a typo. Elixir uses it to make a clear visual difference between calling a named function in a module (`Module.fun(args)` — no dot before the parens) and calling an anonymous function bound to a name (`f.(args)` — dot before the parens). Once you know what to look for, it's a useful signal.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=03-functions-and-modules` from the repo root).
- Open `iex` and play. Define a tiny `defmodule` inline. Bind an `fn` to a name and call it with the dot.
- `cd exercises && mix test --include pending` — make the failing tests pass by editing the files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished (or Hint 3 still hasn't unstuck you).

## Common mistakes

- Forgetting the dot when calling an anonymous function. If you do `f = fn x -> x + 1 end` and then write `f(5)`, Elixir thinks `f` is a *named* function and complains it doesn't exist. The right call is `f.(5)`.
- Putting clause order wrong. Elixir uses the *first* clause whose pattern matches. If you put `def hello(name), do: …` (which matches anything) *above* `def hello("world"), do: …`, the catch-all wins for every call and the specific clause is dead code. Most specific first; catch-alls last.
- Confusing `def` and `fn`. `def` defines a function *inside a module* — it needs a `defmodule … do … end` around it. `fn x -> x + 1 end` is an expression you can use anywhere a value can appear. They're not interchangeable.

## Going further

- Write a `Greeter.hello/2` that takes a `name` and a `greeting`, with two clauses: one when `greeting` is given, one with a default. (Hint: Elixir also supports `\\` for default arguments — but two clauses works too.)
- Try the `&` shorthand on real data: `Enum.map([1, 2, 3], &(&1 * 10))`. What does it return? Now try `Enum.filter([1, 2, 3, 4], &(&1 > 2))`.

## Links

- [Elixir Getting Started — Modules and functions](https://hexdocs.pm/elixir/modules-and-functions.html)
- [HexDocs — Anonymous functions](https://hexdocs.pm/elixir/anonymous-functions.html)
