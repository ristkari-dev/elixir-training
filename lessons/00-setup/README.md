# Lesson 00: Setup

By the end of this lesson, you'll have Elixir running on your machine, you'll have typed your first lines of Elixir into iex, and you'll have created and run your first Mix project. No prior programming experience is assumed — just the patience to read carefully and follow steps in order.

## What programming is, and what Elixir is

Programming is writing instructions for a computer in a language the computer can follow. The instructions are plain text in a file. You hand that file to a program (a "language runtime") that reads your instructions and does what they say. The rest of programming is just layers on top of that one idea.

Elixir is one of those languages — a friendly, fault-tolerant language that runs on the BEAM virtual machine, the same VM that has powered Ericsson's telephone switches since the 1980s. Today people build all sorts of things with Elixir: Phoenix-powered web apps, real-time chat systems, and famously, Discord, which uses Elixir to handle millions of concurrent connections to a single chat room. Elixir gives you a small, readable language plus the BEAM's ability to run hundreds of thousands of lightweight processes side by side.

This course exists to take you from "I've never written code" to a deployed Phoenix web app you can show to a friend. We'll get there in roughly 40 small lessons. After this one, every lesson has the same shape: short slides, a small exercise, and a solution you can compare against.

## What you'll need

- A computer running macOS or Linux. (Windows learners: see the WSL2 pointer below.)
- Roughly 5 GB of free disk space (asdf + OTP + Elixir + Xcode CLT or build essentials).
- An internet connection.
- A couple of hours of focused time.

## A note before we start

This lesson is deliberately long. Read it from top to bottom, follow the steps for your operating system, and don't skip ahead. If you get stuck, see the Troubleshooting section at the end.

> 💡 **First time seeing this?** A "terminal" is a text window where you type commands instead of clicking. On macOS, open the **Terminal** app (Cmd-Space, type "Terminal", press Enter). On Ubuntu, press Ctrl-Alt-T. You'll be living in this window for the next hour, so it's worth getting used to.

## macOS path

### 1. Install Homebrew

Homebrew is a package manager — a tool that installs other tools. Go to <https://brew.sh> and copy the one-liner at the top of the page. Paste it into your terminal and press Enter. It will ask for your password (the same one you use to log into your Mac).

When it finishes, Homebrew prints two lines starting with `==>` telling you how to add Homebrew to your shell. Copy and paste those two lines into your terminal exactly as printed.

### 2. Install asdf via Homebrew

asdf is a version manager. It lets you install multiple versions of Erlang and Elixir side by side, and pin which version each project uses. Run:

```
brew install asdf
```

Homebrew now ships asdf v0.16+ (the Go rewrite). Unlike the classic shell-script version, there is no shell-loader script to source — instead you add asdf's "shims" directory to your `PATH`. Add this line to the bottom of `~/.zshrc`:

```
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

> 💡 **First time seeing this?** `~/.zshrc` is a configuration file your shell reads when it starts. The `~` means "your home folder". You can edit the file with any text editor — `nano ~/.zshrc` works from the terminal. The line you just added prepends asdf's shims folder to `PATH`, which is how every new terminal finds the `elixir`, `mix`, and `iex` commands asdf installs.

Close the terminal window and open a new one. From now on, `asdf` should work.

### 3. Install the Erlang and Elixir asdf plugins

asdf needs a "plugin" for each language it manages. Add the two we need:

```
asdf plugin add erlang
asdf plugin add elixir
```

### 4. Install Xcode Command Line Tools

Building Erlang from source needs a C compiler. On macOS, that comes from Apple's Command Line Tools. Run:

```
xcode-select --install
```

A dialog will pop up. Click **Install**. This download can take **20 minutes or more** — grab a coffee.

### 5. Install Erlang and Elixir using the versions pinned in this repo

If you've already cloned this repo, `cd` into it. If not, create a temporary directory with a `.tool-versions` file matching the versions we use:

```
mkdir -p ~/elixir-setup && cd ~/elixir-setup
cat > .tool-versions <<'EOF'
elixir 1.19.5-otp-28
erlang 29.0.1
EOF
```

Then:

```
asdf install
```

Erlang compiles from source — budget 20 to 40 minutes for the first install. Elixir installs in seconds once Erlang is done.

### 6. Verify the install

```
elixir --version
```

You should see something like:

```
Erlang/OTP 29 [erts-17.0.1] ...
Elixir 1.19.5 (compiled with Erlang/OTP 28)
```

If you see that, skip ahead to **Your first Elixir program**.

## Linux path

### 1. Install build dependencies

Erlang compiles from source, so we need a C compiler and a few development libraries.

**Ubuntu / Debian:**

```
sudo apt update
sudo apt install -y build-essential autoconf m4 libncurses5-dev libssl-dev automake unzip curl
```

**Fedora / RHEL:**

```
sudo dnf install -y gcc make autoconf m4 ncurses-devel openssl-devel automake unzip curl
```

**Arch Linux:**

```
sudo pacman -S --needed base-devel ncurses openssl autoconf automake unzip curl
```

`unzip` and `curl` aren't needed by Erlang itself, but the asdf-erlang and asdf-elixir plugins use them to fetch precompiled artifacts and reference data.

### 2. Install asdf v0.16+ from the GitHub binary release

As of v0.16, asdf is distributed as a single Go binary — no more `git clone` of a shell-script repo. Download the latest release (v0.19.0 at the time of writing; check <https://github.com/asdf-vm/asdf/releases/latest> for newer) and drop the `asdf` binary into a folder on your `PATH`.

Pick the archive that matches your CPU: `linux-amd64` for most desktops, laptops, and cloud VMs; `linux-arm64` for Raspberry Pi 4/5, AWS Graviton, and other 64-bit ARM machines. Check with `uname -m` if you're unsure — `x86_64` means amd64, `aarch64` means arm64.

```
mkdir -p ~/.local/bin
curl -L https://github.com/asdf-vm/asdf/releases/download/v0.19.0/asdf-v0.19.0-linux-amd64.tar.gz | tar xz -C ~/.local/bin
```

Then add this line to your shell config — `~/.bashrc` if you use bash, `~/.zshrc` if you use zsh:

```
export PATH="$HOME/.local/bin:${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
```

> 💡 **First time seeing this?** `~/.bashrc` (or `~/.zshrc`) is a small file that runs every time you open a new terminal. The line you just added puts the `asdf` binary and asdf's shims folder on your `PATH`, which is how new terminals find `asdf`, `elixir`, `mix`, and `iex`. After saving, close the terminal window and open a new one — your changes only take effect in fresh windows.

### 3. Install the Erlang and Elixir asdf plugins

```
asdf plugin add erlang
asdf plugin add elixir
```

### 4. Install Erlang and Elixir

Drop a `.tool-versions` file with the pinned versions, then run `asdf install`:

```
cat > .tool-versions <<'EOF'
elixir 1.19.5-otp-28
erlang 29.0.1
EOF
asdf install
```

Same warning as macOS: budget 20 to 40 minutes for the first build.

### 5. Verify the install

```
elixir --version
```

You should see Elixir 1.19.5 reported alongside Erlang/OTP 29.

## Windows learners — use WSL2

Elixir runs on Windows directly, but the developer experience is rougher (some tooling assumes a Unix shell). The easiest path is the Windows Subsystem for Linux, version 2. Follow Microsoft's install guide at <https://learn.microsoft.com/windows/wsl/install>. Install WSL2 with Ubuntu, open the Ubuntu terminal, and follow the **Linux path** above. Everything you read in the rest of this course assumes a Unix-like environment, and WSL2 gives you that.

## Your first Elixir program (in iex)

`iex` is Elixir's interactive shell — a place where you can type expressions and see them evaluated immediately. Open a terminal and type:

```
iex
```

You'll see a banner and a prompt. Now type `1 + 1` and press Enter:

```
iex> 1 + 1
2
```

Congratulations, you've run Elixir code. Let's print something:

```
iex> IO.puts("Hello, Elixir!")
Hello, Elixir!
:ok
```

`IO.puts` writes the text to the screen. The `:ok` is the return value — Elixir prints the result of every expression. We'll learn more about what `:ok` means in lesson 01.

To exit iex, press **Ctrl-C** twice. (A menu appears; the second Ctrl-C confirms.) Alternatively, press **Ctrl-G**, then type `q` and press Enter for a graceful exit.

## Your first Elixir file (with Mix)

`iex` is great for poking at things, but real programs live in files. Elixir's project tool is called **Mix**, and it generates a project skeleton for you. Pick a folder where you keep code:

```
mkdir -p ~/code
cd ~/code
```

> 💡 **First time seeing this?** `cd` means "change directory" — it's how you move between folders in the terminal. `mkdir -p ~/code` creates a `code` folder inside your home folder (the `-p` flag means "don't complain if it already exists").

Now generate a project called `hello`:

```
mix new hello
```

Mix prints the files it created. The tree looks like this:

```
hello/
├── README.md
├── lib/
│   └── hello.ex
├── mix.exs
├── test/
│   ├── hello_test.exs
│   └── test_helper.exs
└── .formatter.exs
```

`cd hello` and open `lib/hello.ex` in any text editor. Mix has written a tiny module for you:

```elixir
defmodule Hello do
  @moduledoc """
  Documentation for `Hello`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Hello.hello()
      :world

  """
  def hello do
    :world
  end
end
```

Don't worry about the syntax yet — that's lesson 01 onward. For now, run the tests:

```
mix test
```

You should see something like:

```
Compiling 1 file (.ex)
Generated hello app
..
Finished in 0.02 seconds
1 doctest, 1 test, 0 failures
```

Two green dots, zero failures. You just compiled and tested an Elixir project. This is the shape every lesson in this course uses: a Mix project inside `exercises/` and another inside `solutions/`.

## Install a code editor — VS Code with ElixirLS

You can write Elixir in any text editor, but a good editor with language support catches typos as you type and shows you documentation inline. The most popular setup for beginners is Visual Studio Code with the ElixirLS extension.

- Download VS Code from <https://code.visualstudio.com> and install it.
- Open the Extensions sidebar (Cmd/Ctrl-Shift-X), search for **elixir**, and install the **ElixirLS: Elixir support and debugger** extension published by **JakeBecker**.
- Open the `hello/` directory you just created: **File → Open Folder...** and pick it.
- Alternative editors all work: vim or neovim with `elixir-tools.nvim`, Zed (install the Elixir extension), or Emacs with `elixir-mode`. Pick whichever you're comfortable with.

## Troubleshooting

### Problem: `asdf: command not found`

### Fix

Your shell startup file hasn't been sourced. Close the terminal, open a new one, and try again. If it still fails, verify the source line is in `~/.zshrc` (macOS) or `~/.bashrc` (Linux) and that you saved the file.

### Problem: Erlang build fails with `wxWidgets not found`

### Fix

wxWidgets powers the optional Observer GUI tool. Either install it (`brew install wxwidgets` on macOS, `sudo apt install libwxgtk3.0-gtk3-dev` on Debian/Ubuntu) and re-run `asdf install`, or skip it. Erlang will build without Observer; the rest of the language is unaffected.

### Problem: Erlang build fails with `OpenSSL not found`

### Fix

On Linux, install the OpenSSL headers: `sudo apt install libssl-dev` (Debian/Ubuntu) or `sudo dnf install openssl-devel` (Fedora/RHEL). On macOS, install OpenSSL through Homebrew and point Erlang at it:

```
brew install openssl@3
export KERL_CONFIGURE_OPTIONS="--with-ssl=$(brew --prefix openssl@3)"
asdf install
```

### Problem: Apple Silicon — `bad CPU type in executable`

### Fix

Some old asdf plugin scripts shipped Intel-only binaries. Install Rosetta:

```
softwareupdate --install-rosetta --agree-to-license
```

Bumping asdf and the Erlang plugin to current versions usually removes the need entirely.

### Problem: `command not found: elixir` after install

### Fix

asdf needs to "reshim" — regenerate the shim scripts that put `elixir`, `mix`, and `iex` on your `PATH`:

```
asdf reshim
```

If that doesn't help, run `asdf current elixir`. If it says "no version set", run `asdf global elixir 1.19.5-otp-28`.

### Problem: Slow Erlang build (more than 30 minutes)

### Fix

That's normal on the first install. The build compiles all of OTP from source. Subsequent installs are cached. Let it run; if it were stuck, you'd see an error rather than a long wait.

## What we did, and what's next

You installed Elixir using asdf, ran your first expressions in iex, scaffolded a Mix project with `mix new`, ran `mix test`, and set up a code editor. That's a lot for one sitting. Take a break — go for a walk, refill your coffee — before lesson 01.

When you're ready, start lesson 01 by running:

```
make slides-dev LESSON=01-values-and-types
```

That opens lesson 01's slide deck in your browser. Lesson 01 introduces the building blocks of Elixir values: integers, atoms, strings, and the rest. See you there.
