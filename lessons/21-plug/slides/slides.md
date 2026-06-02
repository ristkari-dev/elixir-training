# Lesson 21
## Plug

Phoenix is an OTP app that speaks HTTP — and the unit is a Plug.

---

## What we'll build

Three drills, no Phoenix, no server:

```
Greeter    — a function plug (sets a header)
AuthPlug   — a module plug (halts with 401)
ApiRouter  — a Plug.Router composing them
```

Tested with `Plug.Test` — build a conn, call a plug, inspect the result.

---

## What a Plug is

A plug transforms a `%Plug.Conn{}`. Conn in, conn out.

--

### The conn is the request *and* the response

```elixir
%Plug.Conn{
  method: "GET", request_path: "/hello",
  req_headers: [...],          # what came in
  status: nil, resp_body: nil  # what you build up
}
```

A web request is just a struct. A plug takes it and returns it.

--

### The contract

```elixir
call(conn, opts) -> conn
```

That's the whole thing. Everything in Phoenix is built from functions
of this shape, stacked on top of each other.

---

## Function vs module plugs

Two flavours, same contract.

--

### Function plug — `call/2` only

```elixir
defmodule Greeter do
  import Plug.Conn
  def init(opts), do: opts
  def call(conn, _opts), do: put_resp_header(conn, "x-greeting", "hello")
end
```

`put_resp_header/3` takes a conn and returns a conn. Use a function plug
for something small.

--

### Module plug — `init/1` + `call/2`

```elixir
def init(opts), do: opts        # runs ONCE, when the pipeline is built
def call(conn, opts) do         # runs PER request
  case get_req_header(conn, "x-token") do
    ["secret"] -> conn
    _ -> conn |> send_resp(401, "unauthorized") |> halt()
  end
end
```

`init/1` prepares options once. `call/2` does the per-request work.

---

## halt and the pipeline

A pipeline runs plugs in order, threading the conn through.

--

### halt/1 skips the rest

```elixir
conn |> send_resp(401, "unauthorized") |> halt()
```

`halt/1` marks the conn halted so later plugs are skipped — this is how
auth rejects a request. It does **not** stop your function: you still
return the halted conn.

--

### send_resp without halt = bug

```
plug AuthPlug   # sends 401 but forgets halt
plug :dispatch  # ...still runs, overwrites the response
```

Forgetting `halt/1` is the classic plug mistake.

---

## Plug.Router

A plug made of plugs.

--

### match + dispatch + routes

```elixir
defmodule ApiRouter do
  use Plug.Router
  plug :match
  plug :dispatch

  get "/hello", do: send_resp(conn, 200, "hello")

  get "/secret" do
    conn = AuthPlug.call(conn, AuthPlug.init([]))
    if conn.halted, do: conn, else: send_resp(conn, 200, "top secret")
  end
end
```

Inside a route block, `conn` is in scope and you return a conn.

--

### This is Phoenix's shape

A Phoenix endpoint is a plug. A Phoenix router is a plug. Bandit (the
1.8 default server) calls your endpoint plug once per request. Learn the
contract here and Phoenix stops being magic.

---

## Test with Plug.Test

```elixir
import Plug.Test
conn = conn(:get, "/")
Greeter.call(conn, Greeter.init([]))
```

No port binding. A conn is data, so you feed one in and assert on what
comes back. CI-safe.

---

## Next: lesson 22 — mix phx.new

Run the generator, take the tour, find the plugs you just learned about
hiding in the endpoint and router.

```
make slides-dev LESSON=22-phoenix-tour
```
