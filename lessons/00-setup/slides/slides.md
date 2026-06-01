# Lesson 00: Setup

## Getting Elixir running on your machine

---

## What we'll do today

- Install Elixir on your machine
- Run your first program in IEx
- Create and run your first Mix project

---

## What Elixir is

Elixir is a friendly, fault-tolerant programming language.

It runs on the BEAM virtual machine — the same VM that powers
WhatsApp, Discord, and a chunk of Pinterest.

---

## The install plan

- **asdf** — version manager (lets us pin Elixir/Erlang versions)
- **Erlang/OTP** — the VM
- **Elixir** — the language
- **An editor** — VS Code with ElixirLS

---

## macOS — Homebrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install asdf
```

Add to `~/.zshrc`:

```
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

Close the terminal, open a new one.

---

## macOS — asdf plugins + install

```
asdf plugin add erlang
asdf plugin add elixir
asdf install
```

First Erlang build: **20+ minutes** (compiles from source). Grab coffee.

---

## Linux — distro packages + asdf

Debian/Ubuntu:
```
sudo apt install -y build-essential autoconf m4 \
  libncurses5-dev libssl-dev automake unzip curl
```

(Fedora: `dnf install` · Arch: `pacman -S base-devel ...`)

Install asdf v0.16+ binary (pick `linux-amd64` or `linux-arm64`):
```
mkdir -p ~/.local/bin
curl -L https://github.com/asdf-vm/asdf/releases/download/v0.19.0/asdf-v0.19.0-linux-amd64.tar.gz \
  | tar xz -C ~/.local/bin
export PATH="$HOME/.local/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

---

## Linux — Erlang + Elixir

```
asdf plugin add erlang
asdf plugin add elixir
asdf install
```

Same warning as macOS — first build is slow.

---

## Verify

```
$ elixir --version
Erlang/OTP 29 [erts-17.0.1] ...

Elixir 1.19.5 (compiled with Erlang/OTP 28)
```

---

## Let's run Elixir

First program — in IEx.

--

### Open IEx

```
$ iex
Erlang/OTP 29 ...

Interactive Elixir (1.19.5) - press Ctrl+C to exit
iex>
```

--

### Math works

```
iex> 1 + 1
2
```

--

### Print something

```
iex> IO.puts("Hello, Elixir!")
Hello, Elixir!
:ok
```

--

### Exit

Press **Ctrl-C**, then **Ctrl-C** again at the BREAK menu.

Or **Ctrl-G**, then `q`, then Enter.

---

## Now let's write a file

First Mix project.

--

### Create the project

```
$ mix new hello
* creating README.md
* creating lib/hello.ex
* creating mix.exs
* creating test/hello_test.exs
...
```

--

### Look inside

```
hello/
├── README.md
├── lib/hello.ex
├── mix.exs
└── test/
    ├── hello_test.exs
    └── test_helper.exs
```

--

### Run the tests

```
$ cd hello && mix test
..
Finished in 0.02 seconds
1 doctest, 1 test, 0 failures
```

---

## Editor: VS Code + ElixirLS

- Download VS Code: <https://code.visualstudio.com>
- Install the **ElixirLS** extension (by JakeBecker)
- Alternative editors work too — vim/neovim/Zed/Emacs

---

## You've written Elixir!

From here on we build on this.

Take a break, then move to **lesson 01**:

```
make slides-dev LESSON=01-values-and-types
```
