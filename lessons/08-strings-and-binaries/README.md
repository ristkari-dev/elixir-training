# Lesson 08: Strings and binaries

By the end of this lesson, you'll be comfortable manipulating strings with the `String`
module and you'll have used Elixir's binary pattern matching to peel structure out of raw
bytes.

## Key ideas

- **Strings are binaries.** `"hello"` is just five bytes (UTF-8 encoded). There's no
  separate "string type" lurking under the surface — the printed quotes are a convention,
  not a wrapper. The `String` module knows about *characters* (which can be one or several
  bytes each); the `Kernel` and `Bitwise` modules know about raw *bytes*. Pick the module
  by the question you're asking: "how many letters?" → `String`; "how many bytes on the
  wire?" → `byte_size/1`.
- **`String.upcase`, `.downcase`, `.split`, `.contains?`, `.replace`, `.trim`** — the
  everyday ops. Almost every string job is one of these (or a pipe of them). Skim
  [`String`](https://hexdocs.pm/elixir/String.html) once and you'll know where to look
  the second time.
- **Binary syntax `<<>>`.** `<<104, 101, 108, 108, 111>>` is `"hello"` (same bytes — try it
  in `iex`). The cool part is that you can pattern-match into a binary the same way you
  match into a tuple or list: `<<first_byte, rest::binary>> = "hello"` binds
  `first_byte = 104` and `rest = "ello"`. That's the foundation of every binary parser
  you'll ever write in Elixir — file headers, network protocols, fixed-format records.
- **Sigils** — `~w(a b c)` is `["a", "b", "c"]` (a list of words, no quoting needed).
  `~r/foo/` is a regex. There are others (`~D`, `~T`, `~U` for dates and times) which
  you'll see in passing but won't need today. Sigils are just compile-time shortcuts —
  syntactic sugar that saves keystrokes when a literal would be noisy.

> 💡 **First time seeing this?** A "binary" in Elixir is a contiguous chunk of bytes —
> exactly the same idea as a `bytes` object in Python or a `[]byte` in Go. Strings are
> just binaries that happen to contain valid UTF-8. So every string is a binary, but not
> every binary is a string (a JPEG isn't valid UTF-8). That's why `is_binary("hi")` and
> `is_binary(<<1, 2, 3>>)` both return `true`.

## Try it in IEx

Open `iex` from the repo root:

```
iex> String.upcase("hello")
"HELLO"
iex> String.split("a, b, c", ", ")
["a", "b", "c"]
iex> String.replace("hello world", "world", "Elixir")
"hello Elixir"
iex> String.contains?("hello", "ell")
true
iex> byte_size("hello")
5
iex> String.length("hello")
5
iex> "hello" == <<104, 101, 108, 108, 111>>
true
iex> <<first_byte, rest::binary>> = "hello"
"hello"
iex> first_byte
104
iex> rest
"ello"
iex> ~w(red green blue)
["red", "green", "blue"]
```

The last block is the load-bearing one — read it twice. `<<>>` lets you *take a binary
apart by shape* the same way `[head | tail] = list` takes a list apart.

> 💡 **First time seeing this?** Notice `first_byte` came out as `104`, not `"h"`. A
> single-byte match binds to the *integer codepoint*. If you want a substring instead, use
> `<<head::binary-size(1), rest::binary>>` — the `binary-size(n)` qualifier says "match
> `n` bytes as a binary, not as an integer."

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=08-strings-and-binaries` from the
  repo root).
- Open `iex` and play. Build a few strings, split and rejoin them, then experiment with
  `<<>>` pattern matches on small binaries you build yourself.
- `cd exercises && mix test --include pending` — make the failing tests pass by editing
  the files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished (or Hint 3 still hasn't unstuck
  you).

## Common mistakes

- **Reaching for `String.length/1` when you want byte count.** `byte_size/1` gives the
  number of *bytes*; `String.length/1` gives the number of *characters*, and those aren't
  always the same — `"é"` is one character but two bytes. Use bytes for protocols and
  buffers; use length for "how many letters did the user type?"
- **Treating `<<>>` patterns as if size were optional.** `<<a, b, rest::binary>>` matches
  *one byte* for `a` and *one byte* for `b`. If you want a multi-byte field, you have to
  say so: `<<version::16, length::16, rest::binary>>` matches two 16-bit fields. Forgetting
  the size qualifier is the most common bug in hand-rolled binary parsers.
- **Forgetting that string concatenation is `<>` (not `+`).** We saw this back in lesson
  01, but it bites once a lesson for a while: `"hello" + " world"` is an arithmetic
  error. Use `"hello" <> " world"` (the binary concatenation operator) or
  `Enum.join(["hello", "world"], " ")` when you have a list.

## Going further

- Look up `String.graphemes/1` vs `String.codepoints/1`. When does the difference matter?
  (Hint: emoji, combining accents, flag sequences — visible characters that *display* as
  one but are several codepoints under the hood.)
- Write a tiny binary parser for a fixed-format record: 4-byte version, 2-byte length,
  payload. Match it with `<<version::32, length::16, payload::binary-size(length)>>` and
  see how cleanly the shape falls out.

## Links

- [HexDocs — String](https://hexdocs.pm/elixir/String.html)
- [Binary pattern matching in Elixir](https://hexdocs.pm/elixir/patterns-and-guards.html#binaries)
