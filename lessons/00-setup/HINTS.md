# Lesson 00 — Hints

The README walks through setup top-to-bottom. This file is the lookup table you reach for when something's broken: find your symptom, follow the steps.

## When asdf install fails (macOS)

1. **`xcrun: error: invalid active developer path`.**
   Xcode Command Line Tools missing or broken by a macOS upgrade. Run `xcode-select --install`. If previously installed: `sudo xcode-select --reset`. If still broken, grab the installer from <https://developer.apple.com/download/all/>.

2. **`configure: error: No curses library functions found`.**
   `brew install ncurses`, re-run `asdf install`. If still failing, set `export KERL_CONFIGURE_OPTIONS="--with-ncurses=$(brew --prefix ncurses)"` first.

3. **Build appears to hang for 30+ minutes with no output.**
   Usually normal — Erlang's first build is slow. Check Activity Monitor: if `cc1`, `make`, or `erlc` are using CPU, leave it alone. If CPU is at zero for 10 minutes, Ctrl-C and re-run.

4. **`wxWidgets not found`.**
   Either install it (`brew install wxwidgets`) and re-run, or skip with `export KERL_CONFIGURE_OPTIONS="--without-wx"`. Skipping is fine for this course.

5. **Apple Silicon: `bad CPU type in executable`.**
   Install Rosetta: `softwareupdate --install-rosetta --agree-to-license`. If still broken, `asdf plugin remove erlang` and re-add to pick up the latest plugin code.

## When asdf install fails (Linux)

1. **`configure: error: OpenSSL... not found`.**
   Debian/Ubuntu: `sudo apt install libssl-dev`. Fedora/RHEL: `sudo dnf install openssl-devel`. Arch: `sudo pacman -S openssl`. Re-run.

2. **`No curses library functions found`.**
   Debian/Ubuntu: `sudo apt install libncurses5-dev`. Fedora/RHEL: `sudo dnf install ncurses-devel`. Arch: `sudo pacman -S ncurses`.

3. **`cc: command not found` or `make: command not found`.**
   You skipped build-essentials. Debian/Ubuntu: `sudo apt install build-essential autoconf m4 automake`. Fedora/RHEL: `sudo dnf install gcc make autoconf m4 automake`. Arch: `sudo pacman -S base-devel`.

4. **`curl: command not found` or `tar: command not found` when downloading asdf.**
   `sudo apt install curl tar` / `sudo dnf install curl tar` / `sudo pacman -S curl tar`. Re-run the download from README step 2.

5. **Build succeeds but `asdf current erlang` shows "no version set".**
   Run `asdf install erlang 27.2`, then `asdf global erlang 27.2`, then `asdf reshim`.

## When IEx won't start

1. **`iex: command not found`.**
   Run `asdf reshim`. If still missing, check the shims PATH export is in your shell config: `export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"` (macOS `~/.zshrc`; Linux `~/.bashrc` or `~/.zshrc`, with `$HOME/.local/bin` prepended too if asdf was installed there). Close the terminal and open a new one — shell config only re-runs in fresh windows.

2. **`iex` starts but spews red text about `:erlang.start/0`.**
   Erlang isn't installed for the current shim. Run `asdf current` and check both Erlang and Elixir show concrete versions. If one shows "no version set", run `asdf global erlang 27.2` and `asdf global elixir 1.18.2-otp-27`.

3. **`iex` starts but Ctrl-C does nothing visible.**
   That's the IEx break menu — press Ctrl-C again to abort, or type `a` and Enter. Alternatively, Ctrl-G then `q` then Enter.

4. **`iex` complains about locale (`could not set locale`).**
   On Linux: `sudo locale-gen en_US.UTF-8` then `export LC_ALL=en_US.UTF-8`. Add the `export` line to `~/.bashrc` so it persists.
