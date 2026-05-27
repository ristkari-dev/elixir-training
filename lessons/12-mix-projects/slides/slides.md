# Lesson 12
## Mix projects (Phase 1 capstone)

Build a real CLI tool. Tie Phase 1 together.

---

## What we'll build

`wc_ex` — a tiny Unix-`wc`-style counter.

```
$ ./wc_ex test/fixtures/lorem.txt
10  68  477  test/fixtures/lorem.txt
```

Lines, words, chars, filename. Three drills, one working binary.

---

## Mix project anatomy

You've been inside a Mix project for every lesson. This time we'll
look at what's in it.

--

### `mix new` scaffolds a project

```
$ mix new wc_ex
* creating README.md
* creating .formatter.exs
* creating .gitignore
* creating mix.exs
* creating lib/wc_ex.ex
* creating test/test_helper.exs
* creating test/wc_ex_test.exs
```

Every Elixir library you'll ever install (`phoenix`, `ecto`, `jason`)
started life with this command.

--

### `mix.exs`

```elixir
defmodule WcEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :wc_ex,
      version: "0.1.0",
      elixir: "~> 1.18",
      deps: deps()
    ]
  end

  defp deps, do: []
end
```

Three things: `project/0` config, `application/0` runtime, `deps/0`
Hex dependencies.

--

### The lesson's `mix.exs` has one extra line

```elixir
escript: [main_module: WcEx.CLI],
```

Inside `project/0`. Tells Mix "this project also produces a runnable
escript." We'll come back to it.

---

## The `escript:` field

`mix escript.build` produces a single-file binary you can run on any
machine with Erlang installed.

--

### The shape

```elixir
def project do
  [
    app: :wc_ex,
    # ...
    escript: [main_module: WcEx.CLI]
  ]
end
```

`main_module` points to the module whose `main/1` function is the
entry point.

--

### Build and run

```
$ mix escript.build
Generated escript wc_ex
$ ./wc_ex test/fixtures/lorem.txt
10  68  477  test/fixtures/lorem.txt
```

The binary has a `#!` line and contains your compiled BEAM bytecode.
Runs anywhere Erlang runs.

--

### The entry point — `main/1`

```elixir
defmodule WcEx.CLI do
  def main([path | _]) do
    # ...
    IO.puts("...")
  end
end
```

`argv` is a list of strings. Destructure or call `OptionParser` on
it. Return value is ignored — output is via `IO.puts` or
`System.halt(n)`.

---

## The capstone — three drills

Build it bottom-up. Each drill's tests drive the design.

--

### Drill 1 — the counts struct

```elixir
defmodule WcEx.Counts do
  defstruct lines: 0, words: 0, chars: 0

  def add(%__MODULE__{...} = counts, line) do
    # increment each field
  end
end
```

A reducer that takes the running totals and one line, returns the
new running totals.

--

### Drill 2 — count_file/1

```elixir
def count_file(path) do
  path
  |> File.stream!()
  |> Enum.reduce(%Counts{}, &Counts.add(&2, &1))
end
```

Open the file as a line stream (lesson 09). Reduce with the struct
accumulator (lesson 06). One line of code does the whole job.

--

### Drill 3 — the CLI

```elixir
def main([path | _]) do
  %Counts{lines: l, words: w, chars: c} = WcEx.count_file(path)
  IO.puts("#{l}\t#{w}\t#{c}\t#{path}")
end

def main([]) do
  IO.puts(:stderr, "usage: wc_ex FILE")
  System.halt(1)
end
```

Two clauses — one for the happy path, one for "no args."

---

## You did Phase 1

By the end of this lesson you can:

- Write a recursive function and recognise when to use `Enum` instead.
- Build a pipeline of `Enum`/`Stream` operations.
- Choose between lists, maps, tuples, keyword lists.
- Manipulate strings and binaries with pattern matching.
- Process huge files lazily.
- Define structs and implement protocols.
- Compose fallible operations with `{:ok, _}` / `with`.
- Bundle it all into a Mix project with a runnable CLI.

That's a programming foundation. Phase 2 builds on it: concurrency
and OTP.

---

## Next: lesson 13 — processes

Spawning processes, sending messages, "let it crash."

```
make slides-dev LESSON=13-processes
```
