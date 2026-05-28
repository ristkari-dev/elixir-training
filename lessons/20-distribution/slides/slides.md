# Lesson 20
## Distribution — nodes & :rpc

The same message passing, across machines.

---

## Nodes

A running BEAM instance is a *node*.

--

### Name it, and it's alive

```
$ iex --sname alice
iex> Node.self()
:"alice@yourhost"
iex> Node.alive?()
true
```

Plain `iex` is `:nonode@nohost`, `alive?` is `false`. The `--sname`
flag turns distribution on.

---

## Connecting & cookies

```elixir
Node.connect(:"bob@yourhost")   # => true
Node.list()                     # => [:"bob@yourhost"]
```

--

### The cookie is a shared secret

```
$ iex --sname alice --cookie mycourse
$ iex --sname bob   --cookie mycourse
```

Different cookies → connect silently fails. Same cookie → full trust
(and full code execution) between nodes.

---

## :rpc.call

Run a function *over there*, get the result *back here*.

```elixir
:rpc.call(:"bob@host", IO, :inspect, ["hi"])
```

- `IO.inspect("hi")` runs on **bob** (prints in bob's terminal).
- The return value comes back to the caller.

Targeting `Node.self()` works too — that's what the drill uses.

---

## The 2-node demo (manual)

This one needs two terminals — CI can't run it.

--

### Two terminals, one cluster

```
T1> iex --sname alice --cookie mycourse
T2> iex --sname bob   --cookie mycourse

alice> Node.connect(:"bob@yourhost")   # true
alice> :rpc.call(:"bob@yourhost", IO, :inspect, ["hi"])
```

`"hi"` prints in **bob's** window. The message crossed the network.

---

## Phase 2 done

You can spawn processes, supervise them, ship an OTP app, reach for
ETS, and talk across nodes. That's the concurrency foundation.

--

### Next: Phase 3 — Phoenix

Time to put a web server in front of it all.

```
make slides-dev LESSON=21-plug
```
