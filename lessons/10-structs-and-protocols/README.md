# Lesson 10: Structs and protocols

By the end of this lesson, you'll define your own structs (Elixir's named records) and you'll see how protocols let one function (`to_string`, `Enum.map`, etc.) work across types. The spec splits its budget here on purpose: structs deep, protocols briefly. We'll write a struct from scratch in two drills, then implement one stdlib protocol to feel how the polymorphism hooks in.

## Key ideas

Recall from lesson 07: a map is a key-value collection where any key can show up. A struct is a named, fixed-shape map — same keys every time, defaults baked in.

- **`defstruct`.** A named, fixed-shape map with default values. `%MyStruct{}` creates one; `%MyStruct{field: value}` overrides defaults. Define it inside a `defmodule`.
- **`@enforce_keys`.** Lists fields that *must* be provided at creation time. `%Box{}` would raise; `%Box{width: 1, height: 2}` works. Use it when "no sensible default exists."
- **Structs are maps.** `%Point{x: 1, y: 2} |> Map.get(:x)` returns `1`. But pattern matching distinguishes them: `%Point{x: x}` matches only `Point`-shaped structs, not plain maps with `:x` and `:y` keys.
- **Protocols, briefly.** A protocol declares a function signature. Different types provide their own implementations. `to_string/1` is a protocol (`String.Chars`); `Enum.map/2` is built on the `Enumerable` protocol. You'll implement `String.Chars` for `Point` in drill 3.

> 💡 **First time seeing this?** "Struct" sounds like a class but it isn't — there are no methods bundled with the data. The functions that operate on a struct live in the same module as `defstruct`, by convention, but they're just plain functions. Elixir keeps data and behaviour separate.

## Try it in IEx

```
iex> defmodule Demo do
...>   defstruct name: "?", age: 0
...> end
iex> %Demo{}
%Demo{name: "?", age: 0}
iex> %Demo{name: "Aki"}
%Demo{name: "Aki", age: 0}
iex> demo = %Demo{name: "Aki", age: 40}
iex> demo.name
"Aki"
iex> Map.get(demo, :age)
40
iex> %{demo | age: 41}
%Demo{name: "Aki", age: 41}
```

The last line — update syntax — works because structs are maps under the hood.

> 💡 **First time seeing this?** Defining a struct in `iex` like that is fine for tinkering but unusual. In real code, a struct lives in a `.ex` file with its own module. The two drills below show the normal shape.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=10-structs-and-protocols` from the repo root).
- Play in `iex`. Define a small struct, create one, update fields with `%{struct | field: value}`.
- `cd exercises && mix test --include pending` — three drills, two modules.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Treating a struct like a plain map for pattern matching. `%{x: x} = %Point{x: 1, y: 2}` works (struct *is* a map). `%Point{x: x} = %{x: 1, y: 2}` does NOT work (specific struct, not the right shape).
- Forgetting `@enforce_keys`. Without it, every unspecified field defaults to `nil`. That's often not what you want — `%Box{}` shouldn't be allowed.
- Trying to call `to_string/1` on a struct without implementing `String.Chars`. You get a `Protocol.UndefinedError` with a useful message. The fix is to add a `defimpl String.Chars, for: YourStruct`.

## Going further

- Implement `String.Chars` for `Box` so `to_string(%Box{width: 3, height: 4})` returns `"3×4"`.
- Look up `@derive [String.Chars]` — when can you use it? When can't you?
- Read the `Enumerable` and `Collectable` docs. What changes if you implement them for `Point`? (Hint: nothing useful — but the exercise teaches the pattern.)

## Links

- [HexDocs — Structs](https://hexdocs.pm/elixir/structs.html)
- [HexDocs — Protocols](https://hexdocs.pm/elixir/protocols.html)
