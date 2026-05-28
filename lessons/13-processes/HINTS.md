# Hints for Lesson 13: Processes

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Echo

### Hint 1

`spawn` a process running a private `loop/0` function. Inside the loop,
`receive` a `{from, msg}` tuple, send `{:echo, msg}` back to `from`,
then call `loop/0` again so it keeps serving.

### Hint 2

```elixir
def start, do: spawn(fn -> loop() end)

defp loop do
  receive do
    {from, msg} ->
      send(from, {:echo, msg})
      loop()
  end
end
```

### Hint 3

The full module is exactly the two functions above, wrapped in
`defmodule Echo do … end` with a `@moduledoc`.

## Drill 2: ProcessCounter

### Hint 1

`spawn` a process running `loop(initial)`. The loop `receive`s three
message shapes: `:inc` (recurse with `count + 1`), `{:get, from}`
(send `{:count, count}` to `from`, then recurse with the same count),
and `:reset` (recurse with `0`).

### Hint 2

```elixir
def start(initial \\ 0), do: spawn(fn -> loop(initial) end)

defp loop(count) do
  receive do
    :inc -> loop(count + 1)
    {:get, from} -> send(from, {:count, count}); loop(count)
    :reset -> loop(0)
  end
end
```

### Hint 3

Same as Hint 2, formatted with each `receive` clause on its own lines.
The key insight: state lives in the loop's argument, and you "update"
it by recursing with a new value.

## Drill 3: Linked

### Hint 1

Two steps: set the current process to trap exits with
`Process.flag(:trap_exit, true)`, then `spawn_link` a function that
raises. Because exits are trapped, the crash arrives as a message
instead of killing the caller.

### Hint 2

```elixir
def crash do
  Process.flag(:trap_exit, true)
  spawn_link(fn -> raise "boom" end)
end
```

### Hint 3

The function returns the child pid (the return value of `spawn_link`).
The caller will find `{:EXIT, that_pid, reason}` in its mailbox.
