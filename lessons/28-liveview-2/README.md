# Lesson 28: LiveView 2 (streams + PubSub)

By the end of this lesson, the issue board is real-time across tabs: add or toggle an issue in one tab and it appears in every tab viewing that project's board — no reload. The list is rendered as a LiveView **stream**, and changes travel between tabs over **Phoenix.PubSub**. This closes Phase 3.

## What you should be able to do

After this lesson you should be able to:

- Render a collection as a LiveView stream (`stream/3`, `phx-update="stream"`, `stream_insert/3`) instead of holding the whole list in an assign.
- Broadcast and receive updates with `Phoenix.PubSub` — subscribe in `mount`, broadcast on a change, handle it in `handle_info/2`.
- Explain why `broadcast_from(self())` beats `broadcast` for updating your own tab.

## Key ideas

**Streams — why.** The lesson-27 board kept the whole issue list in `assign(:issues, ...)` and re-rendered it on every change. A **stream** stops holding and re-diffing the whole collection: the server sends per-item operations (insert, update, delete) and the client patches just those DOM nodes. The container gets `phx-update="stream"` and a DOM id; rows iterate `@streams.issues` as `{dom_id, issue}` with `id={dom_id}`. Note the DOM id is `issues-<id>` — the stream name prefixes it.

> 💡 **First time seeing this?** With a stream, the LiveView no longer keeps the list in its state at all. You get `@streams.issues` for rendering, and you change it with `stream_insert/3` — not by re-assigning a list.

**PubSub — multi-tab.** `Tracker.PubSub` is already running (it's in the supervision tree). `mount` subscribes — when `connected?/1` — to a per-project topic `"board:<id>"`. On a change, the LiveView updates its **own** stream and calls `Phoenix.PubSub.broadcast_from(Tracker.PubSub, self(), topic, {:issue, issue})`. `broadcast_from` sends to every *other* subscriber (not itself). A `handle_info({:issue, issue}, socket)` clause receives those broadcasts and `stream_insert`s them.

**Why `broadcast_from(self())` and not `broadcast`.** If you broadcast to everyone including yourself and only update via `handle_info`, your own update becomes an async message to yourself — a beat of lag, and flaky tests (the assertion races the self-message). Update your own tab directly and tell the *others* via the broadcast: your tab is instant, the code is testable, and there's no double-insert.

## The drills

`mount`/`render`/subscribe and the `Issues` context are provided. Implement the real-time wiring in `lib/tracker_web/live/project_board_live.ex`:

1. In `handle_event("add_issue", ...)` and `handle_event("toggle", ...)`: `broadcast_from` the changed issue to the topic **and** `stream_insert` it locally.
2. In `handle_info({:issue, issue}, ...)`: `stream_insert` the broadcast payload.

Run `mix test --include pending` (Postgres up) to see the three failing tests; make them pass.

## How to work this lesson

1. Read this README.
2. Skim `slides/slides.md` (or `make slides-dev LESSON=28-liveview-2` from the repo root).
3. From the repo root, `docker compose up -d postgres` (auth tests need the DB).
4. In `exercises/`, run `mix test --include pending` — three drill tests fail. Make them pass.
5. Stuck? Read `HINTS.md` one hint at a time.
6. Compare against `solutions/` only after you have a working answer.

## Common mistakes

- **Postgres isn't running.** Auth tests fail to connect — `docker compose up -d postgres` first.
- **Using `broadcast` instead of `broadcast_from(self())`.** You'll receive your own broadcast and double-insert your own item.
- **Targeting `#issue-<id>` in a test.** The stream dom id is `#issues-<id>` (the stream name prefixes it).
- **Forgetting `phx-update="stream"`** on the container — rows won't patch.

## Going further

- Many apps broadcast from the **context** (`Issues.create_issue` publishes) so every writer notifies subscribers, not just this LiveView. Where would you move the broadcast, and what would `handle_info` look like then?

## Links

- [LiveView — streams](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#stream/4)
- [Phoenix.PubSub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html)
- [Phoenix.LiveViewTest](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)
