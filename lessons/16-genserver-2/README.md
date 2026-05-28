# Lesson 16: GenServer II

By the end of this lesson, you'll handle messages that don't come through `call`/`cast` — periodic ticks and inactivity timeouts — and you'll test GenServers the idiomatic way with `start_supervised!`.

## Key ideas

Recall from lesson 15: `handle_call` and `handle_cast` handle messages *you* send through the client API. But a GenServer can receive other messages too — timer ticks, monitor notifications, raw `send`s. Those go to `handle_info/2`.

- **`handle_info/2`** handles any message that isn't a `call` or `cast` — including messages you schedule for yourself.
- **`Process.send_after/3`** schedules a message to be delivered to a pid after a delay. `Process.send_after(self(), :tick, 100)` sends `:tick` to yourself in 100ms. Combined with `handle_info`, it's how a GenServer does periodic work: handle the tick, do something, reschedule.
- **GenServer timeouts.** Returning `{:noreply, state, timeout}` (or `{:reply, reply, state, timeout}`) tells OTP "if no message arrives within `timeout` ms, send me a `:timeout` message." Handle it in `handle_info(:timeout, state)`. It's an inactivity timer — any message resets it.
- **Testing GenServers with `start_supervised!/1`.** ExUnit starts the server under its own supervisor and tears it down between tests. Each test gets a fresh server, no manual cleanup. This is *the* idiomatic way to test a GenServer.

> 💡 **First time seeing this?** "Self-scheduled message" sounds odd but it's the standard way to do recurring work in a GenServer. The process sends a message to its *own* mailbox on a timer, handles it in `handle_info`, then schedules the next one. No external clock needed.

## Try it in IEx

```
iex> Process.send_after(self(), :tick, 100)
#Reference<...>
iex> receive do msg -> msg end
:tick
```

> 💡 **First time seeing this?** `start_supervised!/1` is an ExUnit helper, not a GenServer function. In a test, `pid = start_supervised!({Ticker, interval: 20})` starts the server and registers it for automatic teardown when the test ends. Use it instead of calling `start_link` directly in tests.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=16-genserver-2` from the repo root).
- `cd exercises && mix test --include pending` — two drills, both tested with `start_supervised!`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished.

## Common mistakes

- Forgetting to reschedule. A `handle_info(:tick, …)` that doesn't call `Process.send_after` again only ticks once.
- Using `Process.sleep` inside a callback. It blocks the whole server — every other message waits behind it. Schedule a message instead.
- Testing timers with exact assertions. Timing is fuzzy; assert a lower bound (`count >= 2`) not an exact count.

## Going further

- What's `handle_continue/2` for? When is it better than doing slow work in `init/1`? (Hint: `init` blocks `start_link`.)
- How would you make the `Ticker` interval changeable at runtime, not just at start?

## Links

- [HexDocs — GenServer.handle_info/2](https://hexdocs.pm/elixir/GenServer.html#c:handle_info/2)
- [HexDocs — ExUnit start_supervised!/2](https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html#start_supervised!/2)
