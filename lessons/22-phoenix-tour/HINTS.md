# Hints for Lesson 22: Phoenix Tour

Read these one at a time. Try the exercise after each hint before reading the next.
The only drill is the `GET /ping` route: make it return the plain text `"pong"`.

## Drill: GET /ping returns "pong"

### Hint 1

The route is already wired in `lib/tracker_web/router.ex`:
`get "/ping", PageController, :ping`. That points at a `ping/2` function in
`TrackerWeb.PageController`. Open that controller — there's a stub `ping`
that raises. Replace it with a real action that takes `(conn, _params)`
and returns a response, just like the `home/2` action above it.

### Hint 2

`home/2` renders an HTML template with `render/2`. You don't want HTML —
you want plain text. Phoenix controllers have `text/2` for exactly this:
`text(conn, "some string")` sends a `200` response with that string as the
body. (`text/2` comes from `Phoenix.Controller`, already imported via
`use TrackerWeb, :controller`.)

### Hint 3

```elixir
def ping(conn, _params), do: text(conn, "pong")
```
