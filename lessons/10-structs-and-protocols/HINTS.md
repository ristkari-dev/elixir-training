# Hints for Lesson 10: Structs and protocols

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Point with new/2 + distance/2

### Hint 1

Two fields: `x` and `y`. Plus a `new/2` constructor and `distance/2`
between two points (Euclidean: `:math.sqrt((x2-x1)^2 + (y2-y1)^2)`).

### Hint 2

`defstruct [:x, :y]`. `new(x, y), do: %__MODULE__{x: x, y: y}`. For
distance: `:math.sqrt(:math.pow(bx - ax, 2) + :math.pow(by - ay, 2))`.

### Hint 3

```elixir
defstruct [:x, :y]

def new(x, y), do: %__MODULE__{x: x, y: y}

def distance(%Point{x: ax, y: ay}, %Point{x: bx, y: by}) do
  :math.sqrt(:math.pow(bx - ax, 2) + :math.pow(by - ay, 2))
end
```

## Drill 2: Box with @enforce_keys + area/1

### Hint 1

`@enforce_keys [:width, :height]` immediately followed by
`defstruct [:width, :height]`. Then `area/1` pattern-matches the
struct and multiplies the fields.

### Hint 2

`def area(%Box{width: w, height: h}), do: w * h`.

### Hint 3

```elixir
@enforce_keys [:width, :height]
defstruct [:width, :height]

def area(%Box{width: w, height: h}), do: w * h
```

## Drill 3: defimpl String.Chars for Point

### Hint 1

Inside `point.ex`, after `defmodule Point`, add a `defimpl String.Chars, for: Point do ... end` block. It needs a `to_string/1` function that takes a `%Point{}` and returns a string.

### Hint 2

```elixir
defimpl String.Chars, for: Point do
  def to_string(%Point{x: x, y: y}), do: "(#{x}, #{y})"
end
```

Place this after the `defmodule Point ... end` block in the same file.

### Hint 3

End of `point.ex` looks like:

```elixir
end  # of defmodule Point

defimpl String.Chars, for: Point do
  def to_string(%Point{x: x, y: y}), do: "(#{x}, #{y})"
end
```
