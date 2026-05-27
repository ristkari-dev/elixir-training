# Hints for Lesson 12: Mix projects (capstone)

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: WcEx.Counts struct + add/2

### Hint 1

`defstruct lines: 0, words: 0, chars: 0`. The `add/2` function takes
a `%Counts{}` and a string (one line) and returns an updated
`%Counts{}` with each field incremented.

### Hint 2

Words = `line |> String.split() |> length()`. Chars = `String.length(line)`.
`String.split/1` defaults to splitting on whitespace, which is what
you want here.

### Hint 3

```elixir
defmodule WcEx.Counts do
  @moduledoc "Accumulator struct for line/word/char counts."

  defstruct lines: 0, words: 0, chars: 0

  def add(%__MODULE__{lines: l, words: w, chars: c}, line) do
    %__MODULE__{
      lines: l + 1,
      words: w + (line |> String.split() |> length()),
      chars: c + String.length(line)
    }
  end
end
```

## Drill 2: WcEx.count_file/1

### Hint 1

`File.stream!(path)` gives you a line stream. `Enum.reduce` over it
with an empty `%Counts{}` as the initial accumulator and
`Counts.add/2` as the reducer.

### Hint 2

Watch the argument order: `Enum.reduce/3` calls the reducer as
`reducer.(elem, acc)`, but `Counts.add/2` takes `(counts, line)`.
You need a wrapping function or to flip the args.

### Hint 3

```elixir
def count_file(path) do
  path
  |> File.stream!()
  |> Enum.reduce(%Counts{}, &Counts.add(&2, &1))
end
```

The `&Counts.add(&2, &1)` flips the args so it matches `Enum.reduce`'s
calling convention.

## Drill 3: WcEx.CLI.main/1

### Hint 1

`main/1` receives argv as a list of strings. The first element is
the path. Destructure it, call `count_file/1`, format the result,
print with `IO.puts`.

### Hint 2

```elixir
def main([path | _]) do
  %Counts{lines: l, words: w, chars: c} = WcEx.count_file(path)
  IO.puts("#{l}\t#{w}\t#{c}\t#{path}")
end
```

Also handle the no-args case (`main([])`) — print a usage line to
stderr and halt with `System.halt(1)`.

### Hint 3

```elixir
defmodule WcEx.CLI do
  @moduledoc "Escript entry point — wired up via mix.exs :escript option."

  alias WcEx.Counts

  def main([path | _]) do
    %Counts{lines: l, words: w, chars: c} = WcEx.count_file(path)
    IO.puts("#{l}\t#{w}\t#{c}\t#{path}")
  end

  def main([]) do
    IO.puts(:stderr, "usage: wc_ex FILE")
    System.halt(1)
  end
end
```
