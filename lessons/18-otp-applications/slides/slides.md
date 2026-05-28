# Lesson 18
## OTP applications (capstone)

Ship MiniCache — a supervised cache that boots with your app.

---

## What we'll build

```
iex -S mix
iex> MiniCache.put("hello", :world)
iex> MiniCache.get("hello")
:world
```

A cache that's already running when you start the app. Three drills:
Server, Application, public API.

---

## What's an OTP application

A startable, stoppable unit of code with its own supervision tree.

--

### Not "an app with a UI"

"Application" is an OTP term. Your Mix project is already one. Phoenix,
Ecto, Jason — all OTP applications. They each declare a supervision
tree that starts on boot.

--

### The mod: entry

```elixir
def application do
  [
    extra_applications: [:logger],
    mod: {MiniCache.Application, []}
  ]
end
```

`mod:` says "on boot, call `MiniCache.Application.start/2`." That's the
one line that turns a library into a running system.

---

## The Application callback

`start/2` builds the supervision tree.

--

### The shape

```elixir
defmodule MiniCache.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [MiniCache.Server]
    Supervisor.start_link(children, strategy: :one_for_one, name: MiniCache.Supervisor)
  end
end
```

Same `Supervisor.start_link` you saw in lesson 17 — now wired to run
automatically.

---

## Server + Supervisor + public API

Three layers, each with one job.

--

### Layer 1 — the Server (state)

```elixir
defmodule MiniCache.Server do
  use GenServer
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def put(k, v), do: GenServer.cast(__MODULE__, {:put, k, v})
  def get(k), do: GenServer.call(__MODULE__, {:get, k})
  # ... callbacks ...
end
```

--

### Layer 2 — the Application (supervision)

Starts the Server under a supervisor on boot. (Slide above.)

--

### Layer 3 — the public API (front door)

```elixir
defmodule MiniCache do
  alias MiniCache.Server
  defdelegate put(key, value), to: Server
  defdelegate get(key), to: Server
end
```

Callers use `MiniCache.put/2`, never `MiniCache.Server` directly.
Clean separation.

---

## Run it & the restart caveat

--

### It just works

```
iex -S mix
iex> MiniCache.put("k", :v)
iex> MiniCache.get("k")
:v
```

No `start_link` — the app started the Server for you.

--

### Restart resets the cache

```
iex> Process.exit(Process.whereis(MiniCache.Server), :kill)
iex> MiniCache.get("k")
nil
```

The supervisor restarts the Server fresh. The map lived in the
process, so the data is gone. Lesson 19 (ETS) fixes this.

---

## You did Phase 2

You can now:

- Spawn processes and pass messages.
- Use Task and Agent.
- Write GenServers (call/cast, handle_info, timeouts).
- Build supervision trees.
- Ship a supervised OTP application.

Two extension lessons remain: ETS (fast shared storage) and
distribution (multiple nodes).

---

## Next: lesson 19 — ETS

Make the cache survive a crash. Concurrent reads without a bottleneck.

```
make slides-dev LESSON=19-ets
```
