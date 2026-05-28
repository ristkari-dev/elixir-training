# Hints for Lesson 14: Tasks and Agents

Read one hint at a time. Try the exercise again before reading the next.

## Drill 1: Parallel.fetch_all/1

### Hint 1

`Task.async_stream/2` runs a function over each element concurrently.
Each element here is itself a zero-arity function, so the mapper just
calls it: `fn f -> f.() end`. The result is a stream of `{:ok, value}`.

### Hint 2

```elixir
funs
|> Task.async_stream(fn f -> f.() end)
|> Enum.map(fn {:ok, result} -> result end)
```

### Hint 3

```elixir
def fetch_all(funs) do
  funs
  |> Task.async_stream(fn f -> f.() end)
  |> Enum.map(fn {:ok, result} -> result end)
end
```

## Drill 2: KVAgent

### Hint 1

`Agent.start_link(fn -> %{} end)` starts an agent holding an empty map.
`put` uses `Agent.update` with `&Map.put(&1, key, value)`. `get` uses
`Agent.get` with `&Map.get(&1, key)`.

### Hint 2

```elixir
def start_link, do: Agent.start_link(fn -> %{} end)
def put(agent, key, value), do: Agent.update(agent, &Map.put(&1, key, value))
def get(agent, key), do: Agent.get(agent, &Map.get(&1, key))
```

### Hint 3

The full module is the three functions above, wrapped in
`defmodule KVAgent do … end` with a `@moduledoc`.

## Drill 3: Async.race/2

### Hint 1

Start both functions with `Task.async`. The trick: when a `Task`
finishes, it sends `{ref, result}` to the caller, where `ref` is the
task's `.ref`. A single `receive` matching either ref returns the
first result.

### Hint 2

```elixir
task_a = Task.async(fun_a)
task_b = Task.async(fun_b)

receive do
  {ref, value} when ref == task_a.ref or ref == task_b.ref -> value
end
```

After grabbing the first result, shut both tasks down with
`Task.shutdown(task, :brutal_kill)` to clean up the loser.

### Hint 3

```elixir
def race(fun_a, fun_b) do
  task_a = Task.async(fun_a)
  task_b = Task.async(fun_b)
  result = race_loop(task_a, task_b)
  Task.shutdown(task_a, :brutal_kill)
  Task.shutdown(task_b, :brutal_kill)
  result
end

defp race_loop(task_a, task_b) do
  receive do
    {ref, value} when ref == task_a.ref or ref == task_b.ref -> value
  end
end
```
