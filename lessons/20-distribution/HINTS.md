# Hints for Lesson 20: Distribution

Read one hint at a time. Try the exercise again before reading the next.
One drill module, `Localnode`, with two functions.

## Hint 1

Both functions are one-liners over standard APIs. `info/0` reports the
current node: its name and whether distribution is on. `echo_via_rpc/1`
runs `Kernel.inspect/1` *via* `:rpc` — but against the current node, so
it works even without a cluster.

## Hint 2

`Node.self/0` returns the node name; `Node.alive?/0` returns the boolean.
Return them as a tuple:

```elixir
def info, do: {Node.self(), Node.alive?()}
```

For `echo_via_rpc/1`, `:rpc.call/4` takes the node, module, function, and
an argument *list*.

## Hint 3

```elixir
def echo_via_rpc(msg), do: :rpc.call(Node.self(), Kernel, :inspect, [msg])
```

Targeting `Node.self()` makes `:rpc` short-circuit to a local call, so
the result (`Kernel.inspect(msg)`, e.g. `":hello"`) comes straight back —
no distribution required.
