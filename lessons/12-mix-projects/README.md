# Lesson 12: Mix projects (Phase 1 capstone)

By the end of this lesson, you'll have built `wc_ex` — a tiny CLI tool that counts lines, words, and characters in a file, just like Unix `wc`. You'll use everything from Phase 1 — streams, strings, `Enum.reduce`, and a small struct — and you'll build it with the same Mix tooling every Elixir library and Phoenix app uses.

## Key ideas

Recall from lessons 06, 08, 09, 10. This lesson stitches them together:

- **Lesson 06** — `Enum.reduce` to fold a stream of lines into a single accumulator.
- **Lesson 08** — `String.split/1` to count words on a line.
- **Lesson 09** — `File.stream!` to read a file line by line without loading it into memory.
- **Lesson 10** — `defstruct` for the running counts.

Plus the new bits:

- **`mix new <name>`** scaffolds a fresh Mix project. The generated tree has `lib/`, `test/`, `mix.exs`, `README.md`, `.formatter.exs`. Every Elixir library you'll ever use was bootstrapped this way.
- **`mix.exs` structure.** The `project/0` function returns the config. `application/0` declares what to start. `deps/0` lists Hex dependencies.
- **The `escript:` field.** Adding `escript: [main_module: WcEx.CLI]` to `project/0` tells Mix this project produces a runnable script. `mix escript.build` then builds a self-contained Erlang script (with a `#!` line) that you can invoke as `./wc_ex some.txt`.
- **The CLI entry point.** A module with a `main/1` function that takes argv as a list of strings. Mix wires that up from the `escript:` field.

> 💡 **First time seeing this?** An "escript" is a single-file executable produced by Mix. It bundles your code into one binary that needs only Erlang installed to run. It's the simplest way to ship an Elixir CLI tool.

## Try it in IEx

You can run `WcEx.count_file/1` directly without building the escript:

```
iex -S mix
iex> WcEx.count_file("test/fixtures/lorem.txt")
%WcEx.Counts{lines: 10, words: 68, chars: 477}
```

The CLI is just a thin wrapper around this. Once you have the function, building the binary is a one-liner.

> 💡 **First time seeing this?** `iex -S mix` starts an `iex` session with the current Mix project loaded. Different from plain `iex` — you can call your own modules without explicitly compiling them first.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=12-mix-projects` from the repo root).
- Write drills 1, 2, 3 in order. The tests for each drill drive the design.
- Final step: build and run the escript:
  ```
  cd lessons/12-mix-projects/solutions
  mix escript.build
  ./wc_ex test/fixtures/lorem.txt
  ```
  You should see something like `10	68	477	test/fixtures/lorem.txt`.

## Common mistakes

- **Forgetting `escript: [main_module: WcEx.CLI]` in `mix.exs`.** Without it, `mix escript.build` says "no main_module specified." The starter `mix.exs` for this lesson already has the line — leave it.
- **Returning a non-zero exit from `main/1` accidentally.** `IO.puts` returns `:ok`, which is fine; using `System.halt(1)` deliberately for "user asked for impossible thing" is fine. Don't mix the two.
- **Hard-coding the path inside `count_file/1`.** Take the path as an argument; defer file-not-found handling to `main/1` if you want to be polite about it (or just let `File.stream!` raise — that's fine for a tiny demo CLI).

## Going further

- Add a `-l` / `-w` / `-c` flag so the CLI prints only the requested count. Hint: `OptionParser.parse/2`.
- Make the CLI accept multiple file arguments — what changes in `main/1`? In `count_file/1`?
- Write a `WcEx.count_string/1` that takes a string instead of a path and returns a `%Counts{}`. Reuse it from `count_file/1`.

## Links

- [HexDocs — Mix.Tasks.Escript.Build](https://hexdocs.pm/mix/Mix.Tasks.Escript.Build.html)
- [HexDocs — File](https://hexdocs.pm/elixir/File.html)
- [The Unix `wc` man page](https://www.man7.org/linux/man-pages/man1/wc.1.html)
