# Lesson 07
## Collections

Lists, tuples, maps, keyword lists — and when to reach for which.

---

## Lists & tuples

Both look "sequence-y," very different under the hood.

`[1, 2, 3]` is a *linked list* — head and tail. `{:ok, 42}` is a fixed-size
*tuple* — packed contiguously. Different operations, different costs.

--

### Lists

```
iex> [1, 2, 3] ++ [4]
[1, 2, 3, 4]
iex> hd([1, 2, 3])
1
iex> tl([1, 2, 3])
[2, 3]
```

Prepend is O(1) (`[0 | [1, 2, 3]]`). Indexed lookup walks. Lists are what
`Enum` is for — "process every element."

--

### Tuples

```
iex> {status, value} = {:ok, 42}
{:ok, 42}
iex> status
:ok
iex> elem({:a, :b, :c}, 1)
:b
```

Fixed-size. Random access is O(1). Best for small, fixed records — and
especially for return values like `{:ok, result}` / `{:error, reason}`.

--

### When to use which

| Need                                   | Reach for     |
|----------------------------------------|---------------|
| Walk every element with `Enum.*`       | List          |
| Two or three slots, fixed shape        | Tuple         |
| `{:ok, ...}` / `{:error, ...}` return  | Tuple         |
| Variable-length data                   | List          |

---

## Maps

Key-value lookup. The Elixir hash table.

Two ways to write a key: atom shorthand `%{name: "Aki"}` (atoms only), or
the general `%{"name" => "Aki"}` (any key type).

--

### Basics

```
iex> user = %{name: "Aki", age: 30}
%{age: 30, name: "Aki"}
iex> user.name
"Aki"
iex> Map.get(user, :name)
"Aki"
iex> Map.put(user, :city, "Helsinki")
%{age: 30, city: "Helsinki", name: "Aki"}
```

Dot access (`user.name`) is for atom keys only. `Map.get/2` works for any
key and won't crash on a missing one — it returns `nil`.

--

### Map.update/4 — drill 1 preview

```
iex> Map.update(%{count: 1}, :count, 1, &(&1 + 1))
%{count: 2}
iex> Map.update(%{}, :count, 1, &(&1 + 1))
%{count: 1}
```

Four args: map, key, default-if-missing, updater-if-present. This is the
shape behind `Freq.count/1`.

--

### Atom keys vs string keys

```
iex> %{name: "x"} == %{"name" => "x"}
false
iex> %{name: "x"}.name
"x"
iex> %{"name" => "x"}["name"]
"x"
```

`name:` and `"name"` are different keys. JSON-decoded data is usually
string-keyed — `data.name` won't work, use `data["name"]`.

---

## Keyword lists

Sugar over a list of two-tuples. Used for function options.

`[name: "Aki", age: 30]` is exactly `[{:name, "Aki"}, {:age, 30}]`. Order is
preserved, duplicates are allowed.

--

### Basics

```
iex> opts = [trim: true, parts: 2]
[trim: true, parts: 2]
iex> Keyword.get(opts, :trim)
true
iex> Keyword.get(opts, :missing, :default)
:default
```

`Keyword.get/3` is the lookup tool — with a default for missing keys, just
like `Map.get/3`.

--

### Where you actually see them

```
iex> String.split("a-b-c", "-", trim: true, parts: 2)
["a", "b-c"]
```

The trailing `trim: true, parts: 2` is sugar for a keyword list as the
final argument. This pattern is *everywhere* in Elixir — Mix tasks, Phoenix
controllers, GenServer options.

---

## When to use which

| Need                              | Reach for     |
|-----------------------------------|---------------|
| Process every element             | List          |
| Fixed-size return / record        | Tuple         |
| Lookup by name, mutable           | Map           |
| Function options, ordered, dup-ok | Keyword list  |

`[]` is not `%{}` — different types, different operations. Pick by
*access pattern*, not by what looks closest.

--

### Quick decision tree

- "I want to walk it" → list
- "I want a 2-element bundle to return" → tuple
- "I want to look something up by name" → map
- "I want to pass options to a function" → keyword list

---

## Next: lesson 08 — strings and binaries

Strings are special. Binaries underlie them. Codepoints, graphemes, and
why `byte_size/1` and `String.length/1` disagree.

```
make slides-dev LESSON=08-strings-and-binaries
```
