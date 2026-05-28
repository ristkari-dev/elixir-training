# Hints for Lesson 17: Supervisors

Read one hint at a time. Try the exercise again before reading the next.
The worker modules are provided; you implement the supervisor `init/1`.

## Drill 1: SimpleSup

### Hint 1

`init(:ok)` builds a child list with the one worker module and calls
`Supervisor.init/2` with `strategy: :one_for_one`.

### Hint 2

```elixir
def init(:ok) do
  children = [SupCounter]
  Supervisor.init(children, strategy: :one_for_one)
end
```

### Hint 3

Exactly the `init/1` above. The `start_link/1` (provided) names the
supervisor; `SupCounter` (provided) names itself, so the test can find
it with `Process.whereis(SupCounter)`.

## Drill 2: AllForOneSup

### Hint 1

Three `Worker` children, each needs a distinct child id (you can't add
the same module twice without one). Use `Supervisor.child_spec/2` with
an `id:` for each. Strategy is `:one_for_all`.

### Hint 2

```elixir
def init(:ok) do
  children = [
    Supervisor.child_spec({Worker, :worker_a}, id: :worker_a),
    Supervisor.child_spec({Worker, :worker_b}, id: :worker_b),
    Supervisor.child_spec({Worker, :worker_c}, id: :worker_c)
  ]

  Supervisor.init(children, strategy: :one_for_all)
end
```

### Hint 3

Exactly the `init/1` above. `{Worker, :worker_a}` passes `:worker_a` to
`Worker.start_link/1`, which registers the worker under that name. With
`:one_for_all`, killing any one worker restarts all three.
