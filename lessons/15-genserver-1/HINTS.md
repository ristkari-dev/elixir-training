# Hints for Lesson 15: GenServer I

Read one hint at a time. Try the exercise again before reading the next.
In every drill the client API is already written — you implement the
callbacks.

## Drill 1: Counter

### Hint 1

`init/1` returns `{:ok, initial}`. `handle_cast` needs two clauses
(`:inc` and `:reset`). `handle_call(:get, …)` replies with the count.

### Hint 2

```elixir
def init(initial), do: {:ok, initial}
def handle_cast(:inc, count), do: {:noreply, count + 1}
def handle_cast(:reset, _count), do: {:noreply, 0}
def handle_call(:get, _from, count), do: {:reply, count, count}
```

### Hint 3

The three callbacks above, each with `@impl true` above the first
clause of its group.

## Drill 2: StackServer

### Hint 1

State is a list (the stack). Push prepends. Pop and peek need an
empty-list clause returning `{:error, :empty}` and a `[top | rest]`
clause.

### Hint 2

```elixir
def handle_cast({:push, value}, stack), do: {:noreply, [value | stack]}
def handle_call(:pop, _from, []), do: {:reply, {:error, :empty}, []}
def handle_call(:pop, _from, [top | rest]), do: {:reply, {:ok, top}, rest}
def handle_call(:peek, _from, []), do: {:reply, {:error, :empty}, []}
def handle_call(:peek, _from, [top | _] = stack), do: {:reply, {:ok, top}, stack}
```

### Hint 3

Add `def init(stack), do: {:ok, stack}` and the five clauses above.

## Drill 3: BankAccount

### Hint 1

Deposit is a cast (adds to balance). Withdraw is a call with a guard:
one clause `when amount <= balance` succeeds, a fallback clause
returns `{:error, :insufficient_funds}`. Balance is a call.

### Hint 2

```elixir
def handle_call({:withdraw, amount}, _from, balance) when amount <= balance do
  {:reply, {:ok, balance - amount}, balance - amount}
end

def handle_call({:withdraw, _amount}, _from, balance) do
  {:reply, {:error, :insufficient_funds}, balance}
end
```

### Hint 3

Add `init/1`, the deposit cast (`{:noreply, balance + amount}`), the
two withdraw clauses above, and `handle_call(:balance, …)`.
