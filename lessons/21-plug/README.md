# Lesson 21: Plug

Phoenix is an OTP application that speaks HTTP — and the unit of "speaking HTTP" is a **Plug**. Before you run `mix phx.new` in the next lesson, you'll build the thing Phoenix is made of: a function plug, a module plug, and a router that composes them into a request pipeline. No Phoenix yet, no server to start — just the contract.

## What you should be able to do

After this lesson you should be able to:

- Explain what a `%Plug.Conn{}` is and that every plug takes a conn and returns a conn.
- Write a **function plug** (`call/2`) and a **module plug** (`init/1` + `call/2`), and say what each callback is for.
- Compose plugs into a pipeline with `Plug.Router`, and stop the pipeline early with `halt/1`.

## Key ideas

A web request, in the BEAM world, is a struct: `%Plug.Conn{}`. It carries the request (method, path, headers, body) and the response you're building up (status, response headers, body). A **plug** is just a transformation: it takes a conn and returns a conn. That's the whole contract. Phoenix is built entirely from plugs stacked on top of each other.

- **Two flavours of plug.** A *function plug* is any function with the shape `call(conn, opts) -> conn`. A *module plug* is a module with two functions: `init/1`, which runs **once, when the pipeline is built** (at compile time in a `Plug.Router` or endpoint), to prepare options, and `call/2`, which runs **per request** with the conn and those prepared options. Use a function plug for something tiny; use a module plug when there's setup worth doing once.
- **You build the response on the conn.** `put_resp_header/3`, `send_resp/3`, `get_req_header/2` (from `Plug.Conn`) all take a conn and hand you back a conn. You thread it through with the pipe operator.
- **`halt/1` stops the pipeline.** A pipeline runs plugs in order, each receiving the previous one's conn. Calling `halt(conn)` marks the conn halted so later plugs are skipped — this is how authentication rejects a request without the rest of the stack ever running. **`halt/1` does not `return` or stop your function** — you still have to hand the halted conn back.
- **`Plug.Router` is a plug made of plugs.** `use Plug.Router` plus `plug :match` and `plug :dispatch` gives you `get "/path" do … end` route blocks. Inside a route block the conn is available as `conn`, and you end by returning a conn (usually via `send_resp/3`).
- **This is exactly Phoenix's shape.** A Phoenix endpoint is a plug; a Phoenix router is a plug; your controllers run inside that pipeline. The web server — **Bandit**, the default in Phoenix 1.8 — simply calls your endpoint plug once per incoming request. Learn the plug contract here and Phoenix stops being magic.

> 💡 **First time seeing this?** "Plug" is two things with one name: the *specification* (the `call/2` contract) and the *library* (`{:plug, "~> 1.16"}`) that ships `Plug.Conn`, `Plug.Test`, `Plug.Router`, and friends. When people say "write a plug," they mean "write something that satisfies the contract."

## Try it in IEx

`Plug.Test` lets you build a conn and call a plug directly — no port, no server:

```
cd solutions && iex -S mix
iex> import Plug.Test
iex> conn = conn(:get, "/")
iex> Greeter.call(conn, Greeter.init([])) |> Plug.Conn.get_resp_header("x-greeting")
["hello"]
```

That's the same machinery the tests use. A conn is just data, so you can feed one to a plug and inspect what comes back.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or run `make slides-dev LESSON=21-plug` from the repo root to view).
3. Open `exercises/` and run `mix test --include pending`. Make the tests pass. There are three drills, build them in order:
   - **`Greeter`** — a function plug that sets the `x-greeting` response header.
   - **`AuthPlug`** — a module plug that halts with `401` unless the `x-token` header is `"secret"`.
   - **`ApiRouter`** — a `Plug.Router` serving `/hello` publicly and guarding `/secret` with `AuthPlug`.
4. Stuck? Read `HINTS.md` one hint at a time.
5. Compare against `solutions/` only after you have a working answer.

## Common mistakes

- **Forgetting `halt/1`.** Without it, a conn that "failed auth" keeps flowing and later plugs still run. `send_resp` alone does not stop the pipeline — pair it with `halt/1`.
- **Returning something that isn't a conn from `call/2`.** Every plug must return a conn. Returning `:ok`, a tuple, or `nil` breaks the next plug in the chain.
- **Expecting `init/1` to run per request.** It runs **once, when the pipeline is built** (at compile time in a `Plug.Router` or endpoint), not on every request. Don't put per-request work (reading headers, touching the database) in `init/1` — that belongs in `call/2`.

## Going further

- Make `AuthPlug` configurable: have `init/1` accept the expected token (`init(token: "secret")`) and `call/2` read it from `opts`. That's exactly why module plugs have an `init/1`.
- Add a `plug Greeter` line to `ApiRouter` (before `:match`) and watch every response gain the header — that's pipeline composition.

## Links

- [HexDocs — Plug](https://hexdocs.pm/plug/readme.html)
- [HexDocs — Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html)
