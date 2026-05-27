# Lesson 07: Collections

By the end of this lesson, you'll know when to reach for lists, tuples, maps, and keyword
lists — Elixir's four core collection types.

## Key ideas

- **Lists `[1, 2, 3]`** — sequential, head/tail access. Built as linked cells, so prepending
  is O(1) but indexed lookup walks the list. Lists are what `Enum` is for: any time you want
  to "process every element," reach for a list. You've been using them all of lesson 05 and
  06.
- **Tuples `{:ok, 42}`** — fixed-size, positional, packed contiguously in memory. Random
  access is O(1), but tuples don't grow well: changing a tuple's size copies it. Best for
  small, fixed records and especially for *return values* — `{:ok, result}` and
  `{:error, reason}` are the most common shape you'll see in Elixir code.
- **Maps `%{name: "Aki"}` / `%{"k" => "v"}`** — key-value, by-name lookup. Two ways to write
  a key: the atom-keyed shorthand `%{name: "Aki"}` is sugar for `%{name: "Aki"}` (atoms only),
  and the general `%{"name" => "Aki"}` works for *any* key type. `Map.get/2`, `Map.put/3`, and
  `Map.update/4` are the bread-and-butter operations. Maps are the default whenever you want
  to look something up by name.
- **Keyword lists `[name: "Aki", age: 30]`** — sugar over `[{:name, "Aki"}, {:age, 30}]`, so
  literally a list of two-tuples whose first element is an atom. They preserve insertion
  order and allow duplicate keys, which is why functions like
  `String.split("a-b", "-", trim: true)` use them for *options*. `Keyword.get/3` is the
  lookup tool.

> 💡 **First time seeing this?** The `%{name: "Aki"}` shorthand and the `[name: "Aki"]`
> keyword-list syntax look almost identical — one wrapped in `%{}` and one in `[]`. They are
> very different data structures. A map is a hash table; a keyword list is a linked list of
> two-tuples. Use a map when you need fast lookup by name; use a keyword list when you're
> passing options to a function.

## Try it in IEx

Open `iex` from the repo root:

```
iex> [1, 2, 3] ++ [4]
[1, 2, 3, 4]
iex> hd([1, 2, 3])
1
iex> tl([1, 2, 3])
[2, 3]
iex> {status, value} = {:ok, 42}
{:ok, 42}
iex> status
:ok
iex> user = %{name: "Aki", age: 30}
%{age: 30, name: "Aki"}
iex> user.name
"Aki"
iex> Map.get(user, :name)
"Aki"
iex> Map.put(user, :city, "Helsinki")
%{age: 30, city: "Helsinki", name: "Aki"}
iex> Map.update(%{count: 1}, :count, 1, &(&1 + 1))
%{count: 2}
iex> opts = [trim: true, parts: 2]
[trim: true, parts: 2]
iex> Keyword.get(opts, :trim)
true
iex> Keyword.get(opts, :missing, :default)
:default
```

Each block is one collection type. Read top-to-bottom and watch how the operations differ.

> 💡 **First time seeing this?** Maps print their keys in *sorted* order in the shell, not
> the order you inserted them. That's just `inspect/1`'s choice — the map itself is
> unordered. Keyword lists, by contrast, *do* preserve insertion order, which is one reason
> they're used for function options.

## How to work this lesson

- Read this README all the way through.
- Skim `slides/slides.md` (or `make slides-dev LESSON=07-collections` from the repo root).
- Open `iex` and play. Build a small map, update a key, look it up. Try a keyword list as
  the third argument of `String.split/3`.
- `cd exercises && mix test --include pending` — make the failing tests pass by editing the
  files in `exercises/lib/`.
- Stuck? Open `HINTS.md` and read one hint at a time.
- Compare against `solutions/` only after you've finished (or Hint 3 still hasn't unstuck
  you).

## Common mistakes

- **Reaching for a list when you want O(1) lookup.** Lists are great for "walk every
  element," but `Enum.find(list, &(&1.id == 42))` walks the whole list every time. If you're
  looking things up by name or id, use a map (or build one with
  `Enum.reduce(list, %{}, ...)` once and look up many times).
- **Using `[]` as the empty map.** They look similar in printed output (`[]` vs `%{}`), but
  they're different types. `[] == %{}` is `false`. An empty keyword list is `[]`; an empty
  map is `%{}`.
- **Confusing `%{name: "x"}` with `%{"name" => "x"}`.** The first has the *atom* `:name` as
  its key; the second has the *string* `"name"`. They don't match each other and they don't
  look up each other's values. If a function returns string-keyed data (from JSON, for
  example), `data.name` won't work — you need `data["name"]`.

## Going further

- When would `MapSet` (mentioned but not introduced here) be a better choice than `Map`?
  Hint: when you only care whether a value is *present*, not what it maps to.
- Look up `Map.merge/3` — the three-arg version with a conflict resolver. When is the
  resolver useful, and what's its function signature?

## Links

- [HexDocs — Map](https://hexdocs.pm/elixir/Map.html)
- [HexDocs — Keyword](https://hexdocs.pm/elixir/Keyword.html)
