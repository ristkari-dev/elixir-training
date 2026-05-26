# Lesson 01: Values and types

By the end of this lesson, you'll be able to name the basic types Elixir works with — integers, floats, atoms, strings — and understand what's happening when you write `x = 1`. (Spoiler: it's not assignment in the way you may have heard the word elsewhere; we'll dig into why in lesson 02.) These are the building blocks every later lesson stacks on top of, so it's worth slowing down here even if some of it feels obvious.

## Key ideas

- **Numbers.** Two flavours: integers like `1`, `0`, `-7`, and floats like `3.14`, `2.0`. Math works the way you remember from school — `+`, `-`, `*`, `/`. The wrinkle: division `/` always returns a float (`5 / 2` is `2.5`, not `2`). For integer division and remainder, Elixir gives you `div/2` and `rem/2`: `div(7, 2)` is `3`, `rem(7, 2)` is `1`.
- **Booleans.** Just two values: `true` and `false`. Under the hood they're actually atoms in disguise — `:true == true` is `true`, and so is `:false == false`. You'll almost never write `:true` directly, but it's nice to know they're the same animal.
- **Atoms.** An atom is a named constant — think of it as a bookmark with no contents, just the name. You write them with a leading colon: `:ok`, `:error`, `:apple`. The same atom anywhere in your program is the same value, which makes them perfect for tags and labels. They show up everywhere in Elixir, especially in return tuples like `{:ok, result}` and `{:error, reason}`.
- **Strings.** Text in quotes: `"hello"`, `"Hello, Aki!"`. A string in Elixir is a binary (a sequence of bytes, UTF-8 by default). You join two strings together with `<>` — that's string concatenation. There's also a thing called a charlist, written `~c"hello"` (a list of character codes inherited from Erlang), but you'll rarely write one by hand. When in doubt, use double-quoted strings.
- **Binding `x = 1`.** When you write `x = 1`, you're giving the name `x` to the value `1`. From this line down, `x` refers to `1`. This is *not* assignment in the way you may have heard the word — Elixir doesn't really have assignment. The `=` operator is actually called the match operator, and we'll see what makes it special in lesson 02. For now, "give the name `x` to the value `1`" is the right mental model.

> 💡 **First time seeing this?** A "type" in programming means *what kind of value something is* — a number, a piece of text, a true/false flag, and so on. Every value has a type. Elixir doesn't make you declare types up front, but it does keep track of them, and many bugs come from mixing types that don't go together (like trying to add a string to a number).

## Try it in IEx

Open a terminal and run `iex`. Type these one at a time and watch what happens:

```
iex> 1 + 1
2
iex> 5 / 2
2.5
iex> :ok == :ok
true
iex> "hi " <> "there"
"hi there"
iex> x = 42
42
```

That last line bound the name `x` to `42`. If you now type `x + 1`, you'll get `43`. Now try `x = "hello"` and then `x + 1`. You'll see a scary-looking error message — that's expected. Read the top line of it; everything below is the call stack. The top line says `ArithmeticError`, because `"hello"` is a string and `+` only adds numbers. That's Elixir telling you the types don't line up.

> 💡 **First time seeing this?** The `iex>` you see in code samples is the prompt — you don't type it. You type whatever comes after it, then press Enter. The line directly below is what Elixir prints back at you.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or run `make slides-dev LESSON=01-values-and-types` from the repo root to view them in your browser).
- Open `iex` and play with values until the concepts feel familiar. Try things that should work and things that shouldn't — error messages are part of how you learn.
- `cd exercises && mix test --include pending`. You'll see three failing tests. Make them pass by editing the files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time — don't binge them.
- Compare against `solutions/` only after you have a working answer (or after Hint 3 still hasn't unstuck you).

## Common mistakes

- Confusing `=` with comparison. `=` binds (or matches, lesson 02); `==` compares. `x = 5` makes `x` equal to `5`. `x == 5` asks "is `x` equal to `5`?" and returns `true` or `false`.
- Mixing string concatenation `<>` with the `+` operator. `+` is for numbers only. `"a" + "b"` will crash; you want `"a" <> "b"`.
- Thinking `:ok` and `"ok"` are the same thing. They're not — `:ok` is an atom (a named constant), `"ok"` is a string (two text characters). `:ok == "ok"` returns `false`.

## Going further

- In `iex`, try `String.upcase("hello")` and `String.length("hello")`. Then type `h String.upcase` for the inline documentation — `h` is the IEx help command and works for any function.
- Find something in your everyday life that's atom-shaped — a fixed label from a small set, like the days of the week, or HTTP status categories like `:success` / `:redirect` / `:error`. Why would a string be a worse choice for that?

## Links

- [Elixir Getting Started — Basic types](https://hexdocs.pm/elixir/basic-types.html)
- [HexDocs — String](https://hexdocs.pm/elixir/String.html)
- [HexDocs — Integer](https://hexdocs.pm/elixir/Integer.html)
