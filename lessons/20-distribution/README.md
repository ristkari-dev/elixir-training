# Lesson 20: Distribution (nodes & :rpc)

By the end of this lesson, you'll understand how Elixir processes talk across machines. The drills run on a single node; a follow-the-steps demo shows two nodes talking — that part needs two terminals, not CI.

## Key ideas

- **Nodes.** A running BEAM instance is a *node*. Start a named one with `iex --sname alice`. `Node.self/0` returns the current node's name (`:nonode@nohost` if unnamed); `Node.alive?/0` says whether distribution is on.
- **Connecting nodes.** `Node.connect(:"bob@host")` links two nodes. `Node.list/0` shows who's connected. Nodes must share a *cookie* (`--cookie secret`) to connect — it's a shared secret, not a username.
- **`:rpc.call/4`.** Run a function on another node: `:rpc.call(:"bob@host", IO, :inspect, ["hi"])`. The function runs *there*; the result comes back *here*. Calling it against your own node works too — that's what the drill uses.
- **Global names.** `:global.register_name/2` registers a process under a name visible cluster-wide, so any node can find it.
- **`libcluster`** (mentioned, not used here) automates node discovery and connection in production clusters, so you don't hand-wire `Node.connect`.

> 💡 **First time seeing this?** "Distribution" means multiple BEAM instances — possibly on different machines — forming one cluster that passes messages as if they were local. The same `send`/`receive` you learned in lesson 13 works across the network once nodes are connected.

## Try it in IEx

```
iex> Node.self()
:nonode@nohost
iex> Node.alive?()
false
```

A plain `iex` is not distributed — it has no name and `alive?` is `false`. Naming it (next section) turns distribution on.

## The two-node demo (follow along)

This part is manual — open two terminals. CI can't run it.

1. **Terminal 1:** `iex --sname alice --cookie mycourse`
2. **Terminal 2:** `iex --sname bob --cookie mycourse`
3. In **bob**, check the node name: `Node.self()` → something like `:"bob@yourhost"`.
4. In **alice**, connect using bob's exact name: `Node.connect(:"bob@yourhost")` → `true`.
5. In **alice**: `Node.list()` → `[:"bob@yourhost"]`.
6. In **alice**: `:rpc.call(:"bob@yourhost", IO, :inspect, ["hi from alice"])`.
   - The string prints in **bob's** terminal (the function ran there).
   - The return value comes back in **alice**.

Use your *actual* short hostname — `Node.self()` in either terminal shows the exact format to copy.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=20-distribution` from the repo root).
- One Mix drill, `Localnode`, tests single-node behaviour (`info/0` and `echo_via_rpc/1`).
- Do the two-node demo above by hand — it's the payoff, but it can't be a test.
- Stuck? Open `HINTS.md` one hint at a time.

## Common mistakes

- Different cookies → nodes silently won't connect (`Node.connect` returns `false` with no error). Both terminals need the same `--cookie`.
- Mixing `--sname` (short names, same host) and `--name` (full names, across hosts). Pick one for both nodes.
- Expecting `Node.alive?/0` to be `true` in a plain `iex` with no `--sname`. It's `false` until you name the node.

## Going further

- Read the `libcluster` README — what node-discovery strategies (gossip, Kubernetes, DNS) does it offer?
- What's the security implication of a shared cookie? (Hint: the cookie grants full code execution on every connected node — treat it like a root password.)

## Links

- [HexDocs — Node](https://hexdocs.pm/elixir/Node.html)
- [Erlang — `:rpc`](https://www.erlang.org/doc/man/rpc.html)
