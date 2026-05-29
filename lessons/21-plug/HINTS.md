# Hints for Lesson 21: Plug

Read one hint at a time. Try the exercise again before reading the next.
Build the three drills in order — each is a little more involved than the last.

## Drill 1: Greeter (a function plug)

### Hint 1

A function plug is just `call(conn, opts)` returning a conn. You need to
add a response header to the conn you were given and return the result.
`init/1` is already correct — leave it.

### Hint 2

The function from `Plug.Conn` is `put_resp_header/3`. It takes the conn,
a header name, and a value, and returns the updated conn.

### Hint 3

```elixir
def call(conn, _opts), do: put_resp_header(conn, "x-greeting", "hello")
```

## Drill 2: AuthPlug (a module plug)

### Hint 1

Look at the request's `x-token` header. If it's the right value, hand the
conn straight back. Otherwise send a `401` response **and** halt so no
later plug runs. A `case` over the header value is the cleanest shape.

### Hint 2

Three functions from `Plug.Conn`: `get_req_header/2` returns a **list** of
values for a header (e.g. `["secret"]` or `[]`), `send_resp/3` sets the
status and body, and `halt/1` marks the conn halted. Pipe `send_resp` into
`halt`.

### Hint 3

```elixir
def call(conn, _opts) do
  case get_req_header(conn, "x-token") do
    ["secret"] -> conn
    _ -> conn |> send_resp(401, "unauthorized") |> halt()
  end
end
```

## Drill 3: ApiRouter (a Plug.Router pipeline)

### Hint 1

`use Plug.Router` with `plug :match` and `plug :dispatch` is already wired.
You fill in the two route blocks. Inside a `get` block the conn is
available as `conn`, and you must return a conn. `/hello` is public;
`/secret` should run `AuthPlug` first and only serve the body if the conn
wasn't halted.

### Hint 2

For `/hello`, just `send_resp(conn, 200, "hello")`. For `/secret`, call the
plug yourself — `AuthPlug.call(conn, AuthPlug.init([]))` — then branch on
`conn.halted`: if halted, return that conn; otherwise `send_resp(conn, 200, "top secret")`.

### Hint 3

```elixir
get "/hello", do: send_resp(conn, 200, "hello")

get "/secret" do
  conn = AuthPlug.call(conn, AuthPlug.init([]))
  if conn.halted, do: conn, else: send_resp(conn, 200, "top secret")
end
```
