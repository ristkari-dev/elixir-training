# Lesson 11
## Error handling

`{:ok, _}`, `{:error, _}`, and the `with` you already met.

---

## What we'll do

- Use the tagged-tuple convention.
- Decide between returning errors and raising.
- Write multi-step `with` chains with `else`.

---

## Tagged tuples

Success and failure are values, not exceptions. The convention is
`{:ok, payload}` and `{:error, reason}`.

--

### The shape

```
iex> File.read("missing.txt")
{:error, :enoent}
iex> File.read("/etc/hosts")
{:ok, "...file contents..."}
iex> Integer.parse("42")
{42, ""}
iex> Integer.parse("oops")
:error
```

The stdlib mostly uses tagged tuples. `Integer.parse/1` is an
exception that returns a bare `:error` — old API, still around.

--

### Why a tuple, not an exception?

- Callers can pattern-match success vs failure with the same tools.
- Composable with `with` chains.
- Forces the question "what should happen when this fails?" at every
  call site.

--

### Common mistake — bare values

```elixir
def fetch(url) do
  response = HTTP.get(url)
  response
end
```

Better:

```elixir
def fetch(url) do
  case HTTP.get(url) do
    {:ok, response} -> {:ok, response.body}
    {:error, reason} -> {:error, reason}
  end
end
```

Once your function returns the tuple shape, callers can chain it.

---

## raise vs return

Two different tools for two different jobs.

--

### Return for expected failure

```elixir
def divide(_a, 0), do: {:error, :div_by_zero}
def divide(a, b), do: {:ok, a / b}
```

Divide-by-zero is something a caller might want to handle. Tuple.

--

### Raise for "this should never happen"

```elixir
def get_secret_key do
  System.fetch_env!("SECRET_KEY")
end
```

If the env var isn't set, the program can't continue — crash loud
and early. `fetch_env!` raises; the `!` is the convention for
"crash on failure."

--

### Rule of thumb

- Would a sensible caller want to retry, fall back, or log? → tuple.
- Is the situation a bug or a misconfiguration? → raise.
- When in doubt → tuple. You can always add `!`-variants later.

---

## `with` revisited

Lesson 04 showed `with` as "the chain of `{:ok, _}` steps." Now we'll
see `else` and short-circuiting in detail.

--

### Basic chain

```elixir
with {:ok, a} <- step_a(input),
     {:ok, b} <- step_b(a),
     {:ok, c} <- step_c(b) do
  {:ok, c}
end
```

Each `<-` is a pattern match. If it matches, the next runs. If not,
the unmatched value is the whole expression's result.

--

### What happens on failure

```
iex> with {:ok, a} <- {:ok, 1},
...>      {:ok, b} <- {:error, :boom} do
...>   {:ok, a + b}
...> end
{:error, :boom}
```

The second clause didn't match `{:ok, b}`. The unmatched value
`{:error, :boom}` falls through as the `with` expression's result.

--

### `else` for explicit remapping

```elixir
with {:ok, value} <- something() do
  {:ok, value * 2}
else
  {:error, :not_found} -> {:error, :missing}
  {:error, reason} -> {:error, reason}
end
```

`else` catches *any* non-matching `<-` value and lets you rewrite it.
Each clause inside `else` is a pattern; the first that matches wins
(like `case`).

--

### Common mistake — implicit else

Without `else`, a non-matching value goes through as-is. That's often
what you want — but it means upstream errors leak into your function's
return shape. Be explicit when the caller cares about *your* error
shape.

---

## try/rescue (briefly)

For interop with code that raises and for resource cleanup.

--

### When you need it

```elixir
try do
  some_function_that_might_raise()
rescue
  e in [ArgumentError] -> {:error, e.message}
end
```

Catch specific exception types. Avoid `rescue _ -> ...` (catches
everything, masks bugs).

--

### Resource cleanup

```elixir
try do
  do_work()
after
  File.close(handle)
end
```

`after` runs whether or not the body raised. Useful for closing files,
releasing locks.

--

### Recap

- Most error handling is tagged tuples.
- `with` composes them cleanly.
- `try/rescue` is the escape hatch for code outside the convention.

---

## Where this leads

Phoenix controllers, Ecto changesets, GenServer callbacks — all
plumb tagged tuples and `with` chains. Phase 3+ leans hard on this.

---

## Next: lesson 12 — Mix projects (Phase 1 capstone)

Time to build something. We'll wire your knowledge into a tiny CLI
tool called `wc_ex`.

```
make slides-dev LESSON=12-mix-projects
```
