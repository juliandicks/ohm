# Ωhm

> **Resistance is futile** — Retro-inspired terminal UI toolkit for Zsh

```
         __
  ____  / /_  ____ ___
 / __ \/ __ \/ __ `__ \
/ /_/ / / / / / / / / /
\____/_/ /_/_/ /_/ /_/
```

ohm is a terminal user interface framework that brings back the nostalgic charm of DOS-era applications—think Turbo Pascal, Norton Commander, and Borland IDEs—to modern macOS and Linux terminals. Written entirely in Zsh, it provides colorful menus, dialog boxes, spinners, keyboard handling, and more.

## ✨ Features

- 🎨 **Rich Terminal UI** — ANSI colors, box drawing, dialogs, buttons
- ⌨️ **Keyboard Handling** — Arrow keys, function keys, escape sequences
- 📋 **Popup Menu** — `ohm menu` shows the tasks of the directory you are in (mise) plus your own items, with hotkeys, search, a details pane and confirmation for risky tasks
- 🧩 **Plugins** — drop in a directory to add commands, menu items and shell setup
- 🎨 **Themes** — `classic`, `mono`, `green` (phosphor) and `amber`; one command to switch
- 🔄 **Spinners** — Animated loading indicators (20+ styles!)
- 🎭 **Fun Demos** — Fire effect, color palette, Unicode browser

## 📦 Project Structure

```
ohm/
├── bin/                  # Public entrypoints added to PATH
│   ├── ohm               # The CLI
│   └── ohm-menu, services, sysinfo, javainfo   # Deprecated shims for `ohm <command>`
│
├── libexec/              # Commands behind the CLI: `ohm foo` runs libexec/ohm-foo
│   ├── ohm-menu          # Popup menu: mise tasks + your own items
│   ├── ohm-config        # Spinner picker, themes, starter user files, settings
│   ├── ohm-plugins       # List registered plugins
│   ├── ohm-services      # Service port checker
│   ├── ohm-sysinfo       # System summary panel
│   ├── ohm-javainfo      # Java environment panel
│   ├── ohm-cpu-bench     # CPU benchmark
│   ├── ohm-cpu-graph     # Live CPU graph
│   └── ohm-update        # Pull ohm, turbo_zsh and menu_zsh
│
├── ohm                   # CLI dispatcher and `doctor`/`version`
├── init.zsh              # Interactive entry point - source this in your .zshrc
├── init_env.zsh          # Bootstrap (OHM_PATH, `uses`); sourced by init.zsh and every command
├── ohm_lib.zsh           # ohm helpers (OhmPrefix, config, host id, EnvUserHost)
├── ohm_menu_lib.zsh      # Menu providers: mise tasks, your personal m.mnu
├── version.zsh           # Version info and update check
├── setup, setup.zsh      # Installer (repo-local, not on PATH)
├── user.example/         # Starter files that `ohm config init` copies into user/
├── tests/                # ohm's own tests (zsh tests/tests)
├── ohm_banner            # ASCII art banner
│
├── turbo_zsh/            # 🎯 Core UI Library (Turbo™) — separate repo, cloned by setup
│   ├── init_env.zsh      # Module loading (uses), TURBO_API_VERSION
│   ├── system_lib.zsh    # Platform detection and PATH helpers
│   ├── crt_lib.zsh       # Console/screen control (colors, cursor, boxes)
│   ├── keys_lib.zsh      # Keyboard input handling
│   ├── string_lib.zsh    # String manipulation utilities
│   ├── math_lib.zsh      # Math helper functions
│   ├── spinner_lib.zsh   # Loading animations
│   ├── config_lib.zsh    # Persistent KEY=value settings files
│   ├── menu_lib.zsh      # Hierarchical popup menu (items, hotkeys, search, preview)
│   ├── panel_lib.zsh     # Inline framed panels (sysinfo, services, javainfo)
│   ├── theme_lib.zsh     # Colour roles and themes
│   ├── alerts_lib.zsh    # Alert/notification bars
│   ├── app_lib.zsh       # Application event loop (keys, redraw, clean exit)
│   ├── test_lib.zsh      # Test framework
│   ├── tests/            # Per-module tests + runner
│   └── demos/            # Library demos
│
├── menu_zsh/             # 🎭 Demos — separate repo, cloned by setup
│   ├── about             # About panel
│   └── fire.zsh, palette.zsh, unicode_browser.zsh   # Demos
│
├── user/                 # 👤 Personal config (gitignored, optional; `ohm config init` creates it)
│   ├── config                 # Saved settings (spinner, theme, host), KEY=value
│   ├── plugins/               # Drop a plugin directory (or a symlink to one) here
│   ├── init_<user>[_<host>]   # Sourced by init.zsh
│   ├── env_<user>_<host>      # SERVICE_LIST / SERVICE_CONTEXTS for `ohm services`
│   └── m.mnu                  # Menu definition
│
└── visier_dev/           # 🏢 Visier-specific developer tools (gitignored, private)
```

`turbo_zsh/` and `menu_zsh/` are separate git repositories that `./setup` clones next to the ohm checkout. `ohm doctor` checks that their API level matches what ohm expects.

## 🚀 Quick Start

Requirements: `zsh` and `git`.

### Installation

```zsh
# Clone the repository
git clone https://github.com/juliandicks/ohm.git ~/ohm
cd ~/ohm

# Install dependencies
./setup

# Add to your .zshrc
echo 'source ~/ohm/init.zsh' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

`init.zsh` adds `~/ohm/bin` to `PATH`, not the repo root, so `ohm` is the only command you need on `PATH`. It is self-contained: it sets up `OHM_PATH` and the `uses` library loader itself, so no `~/.zshenv` hook is required.

### Verify Install

```zsh
ohm doctor
```

`ohm doctor` exits non-zero if it finds a failure (syntax errors, dangling references, a turbo_zsh version mismatch, a broken bootstrap).

### Personal Configuration

Personal configuration lives in `user/` (optional, gitignored). Create starter files with:

```zsh
ohm config init      # creates only what is missing; never overwrites
```

`init.zsh` sources `user/init_${USER}` and `user/init_${USER}_<host>`; `ohm services` reads `user/env_${USER}_<host>`.

`<host>` is the name in `user/config` (`host=`) if set, otherwise the short hostname. macOS can rename a machine when the network changes, which would silently detach the host-specific files, so `ohm config init` pins the current name. `ohm doctor` warns when `user/` has files for other hosts but none for this one; fix a renamed machine with `ohm config set host <old name>`.

### Launch the Menu

```zsh
cd ~/code/some-project
ohm menu          # tasks of this directory + your own items
```

The menu is built for **the directory you are in**:

- **mise tasks** (needs [mise](https://mise.jdx.dev) and `jq`): `mise tasks ls` is read live, so there is nothing to configure and the menu is always current. A task named `db:migrate` becomes the item *migrate* in the group *db*. From a subdirectory you see the tasks mise merges from parent configs.
- **Your own items** from `user/m.mnu` (see below), shown in every directory.

| Key | Action |
|-----|--------|
| `↑` `↓` `PgUp` `PgDn` `Home` `End` | Move |
| `Enter`, `→`, or the **highlighted letter** | Open a group / run an item |
| `←`, `Backspace`, `Esc` | Back (quits at the top level) |
| `/` | Search every item by name, description or command |
| `q` | Quit |

A task runs on the normal screen with its real output (so `Ctrl-C` interrupts the task, not the menu) and the menu comes back afterwards. Names and descriptions that look destructive (`destroy`, `reset`, `uninstall`, `delete`, `drop`, `purge`, `wipe`, `restore`, `permanently`) ask for confirmation first, showing the exact command. A task that takes arguments prompts for them.

```zsh
ohm menu --list         # print the menu as a text tree (no terminal needed)
ohm menu --print        # choose, but print the command line instead of running it
ohm menu --dir ~/code/x # use another directory
ohm menu --all          # include mise tasks from the whole monorepo
ohm menu --no-user      # only mise tasks   (--no-mise: only your own items, --no-plugins: no plugin items)
```

**Open it from the prompt.** Bind a key in `user/init_<user>`:

```zsh
export OHM_MENU_KEY='^G'      # Ctrl-G
```

The menu opens over your prompt; the command you choose is *placed on the command line* (not run), so you can edit it and it lands in your history. `Esc` leaves the prompt untouched. If you prefer a short command, add `alias m='ohm menu'`.

**Safety.** Task names and descriptions come from the repository, so they are treated as untrusted: control characters are removed before anything is drawn, and tasks run as an argument list, never through a shell string. The menu never runs `mise trust` for you; for an untrusted config it shows a notice telling you to review it first.

### Commands

| Command | Description |
|---------|-------------|
| `ohm doctor` | Validate install, configuration and script integrity |
| `ohm menu [--print\|--list]` | Popup menu of this directory's tasks and your own items |
| `ohm update` | Pull the latest ohm, turbo_zsh and menu_zsh |
| `ohm version` | Print version information and check for updates |
| `ohm config spinner` | Pick the default spinner (saved to `user/config`) |
| `ohm config theme [NAME]` | List the colour themes with samples, or save one |
| `ohm config init` / `get` / `set` / `path` | Starter user files and saved settings |
| `ohm plugins` | List registered plugins and what each provides |
| `ohm services [-c NAME] [-a\|-r\|-s]` | Show which of your configured service ports are listening |
| `ohm sysinfo` | System summary panel |
| `ohm javainfo` | Java environment panel |
| `ohm cpu-graph [-w N] [-t dots\|block\|pie]` | Live CPU usage graph |
| `ohm cpu-bench [-r N] [-t MS] [-q]` | Simple CPU benchmark |

`ohm help` lists every command; `ohm help <command>` shows its options. The old `services`, `sysinfo` and `javainfo` commands still work as deprecated shims.

### Use Libraries in Your Scripts

`source ~/ohm/init.zsh` makes `uses` available. (Only scripts that call `uses` *without* sourcing `init.zsh` need the optional `~/.zshenv` hook; add it with `./setup --zshenv`.)

```zsh
#!/bin/zsh
source ~/ohm/init.zsh

uses crt_lib.zsh
uses alerts_lib.zsh

# Now you have access to all turbo_zsh functions!
InfoBar "Hello from ohm!"
SetColor Yellow Blue
ClrScr
WriteXY 10 5 "Welcome to the future of terminal UIs"
```

## 🛠️ Development

- Developer guide: [turbo_zsh/DEVELOPMENT.md](turbo_zsh/DEVELOPMENT.md)
- Tests: `zsh turbo_zsh/tests/tests` (libraries) and `zsh tests/tests` (ohm: menu, CLI, doctor; the terminal tests need `tmux` and `jq`)
- Function docs use `ZDOC v1` tags for parsing: `#@fn`, `#@brief`, `#@args`, `#@ret`.
- Planning and backlog tracking live in Linear; keep long-lived repo conventions in `AGENTS.md`.

## 📚 API Reference

### crt_lib.zsh — Console/Screen Control

| Function | Description |
|----------|-------------|
| `ClrScr` | Clear the screen |
| `ClrEol` | Clear to end of line |
| `GotoXY x y` | Move cursor to position |
| `WriteXY x y text` | Write text at position |
| `SetFg color` | Set foreground color |
| `SetBg color` | Set background color |
| `SetColor fg bg` | Set both colors |
| `ResetColor` | Reset to default colors |
| `CursorOn` / `CursorOff` | Show/hide cursor |
| `DrawDialogBox x y w h title` | Draw a Norton-style dialog |
| `DrawSingleBox x y w h` | Draw single-line border box |
| `DrawDoubleBox x y w h` | Draw double-line border box |
| `HighlightString fg hi text` | Render `[H]otkey` style text |

**Available Colors:** `Black`, `Red`, `Green`, `Yellow`, `Blue`, `Magenta`, `Cyan`, `White`  
**Bright variants:** `BrightBlack`, `BrightRed`, `BrightGreen`, etc.

### keys_lib.zsh — Keyboard Input

| Function | Description |
|----------|-------------|
| `ReadKey` | Read a single keypress (handles escape sequences) |
| `Readln` | Read a line of input |
| `Waitln` | Wait for Enter key |

**Key Constants:** `KBD_UP_ARROW`, `KBD_DN_ARROW`, `KBD_LT_ARROW`, `KBD_RT_ARROW`, `KBD_F1`–`KBD_F12`, `KBD_CR`, `KBD_TAB`, etc.

### spinner_lib.zsh — Loading Animations

```zsh
# Start a spinner
SpinnerStart "Loading... " SPINNER_3

# Do some work...
sleep 2

# Stop the spinner
SpinnerStop

# Or: wait for any keypress with a spinner
SpinnerReadKey "Press any key to continue "
```

**Spinner Styles:** `SPINNER_FA1`, `SPINNER_HC1`, `SPINNER_3`, `SPINNER_CASCADE`, `SPINNER_SNAKE`, and many more!

### alerts_lib.zsh — Notification Bars

```zsh
InfoBar "This is informational"       # Blue bar with ℹ️
WarningBar "This is a warning"        # Yellow bar with ⚠️
ErrorBar "This is an error"           # Red bar
SecurityBar "Security alert!"         # Red bar with 🚓
SudoPrompt                            # Warn before sudo commands
```

### string_lib.zsh — String Utilities

| Function | Description |
|----------|-------------|
| `LeftStr str n` | Get first n characters |
| `PadLeft str w` | Right-align in width w |
| `PadRight str w` | Left-align in width w |
| `PadMiddle str w` | Center in width w |

## 🧩 Plugins

A plugin is a directory with any of these files (all optional):

| File | Provides |
|------|----------|
| `plugin.zsh` | Shell setup, sourced when the plugin is registered (aliases, exports). Must be safe to run twice |
| `menu.zsh` | Menu items: sourced by `ohm menu`; call `MenuAddItem`, `MenuGroup`, `MenuNotice` |
| `libexec/ohm-<name>` | Extra commands: `ohm <name>` (a core command always wins a name clash) |

Register one in your init file with `OhmPlugin ~/path/to/plugin`, or drop the directory (or a symlink to it) into `user/plugins/`. `ohm plugins` shows what is registered and `ohm doctor` checks every plugin: that its files parse and that its commands start in a clean environment. Plugin commands must make `--help` do nothing but print usage, because the doctor runs it.

```zsh
# menu.zsh: items are plain commands run in the right directory
MenuGroup -p Deploy -l Deploy -k d
MenuAddItem -p Deploy -l "Staging" -c "$HOME/code/app" -d "Deploy to staging" -- ./deploy staging
MenuAddItem -p Deploy -l "Production" -c "$HOME/code/app" -D -- ./deploy production   # -D: always confirm
```

Plugin code runs with your privileges, like your `.zshrc`: only register plugins you trust.

## 🎨 Themes

Colours are *roles* (`bar`, `panel`, `selected`, `hotkey`, `danger`, ...), not hard-coded numbers, so the whole UI re-colours at once:

```zsh
ohm config theme          # list the themes with a colour sample each
ohm config theme green    # save one (applies to every ohm command and new shells)
```

`classic` is the original blue Norton look; `mono` uses black and white only; `green` and `amber` are single-hue phosphor styles. Define your own as a file `user/themes/<name>.zsh` (roles you leave out come from `classic`), then `ohm config theme <name>`:

```zsh
# user/themes/ocean.zsh: a role is "Foreground Background" ("-" for none); use typeset -gA
typeset -gA TURBO_THEME_ocean=(
  panel "BrightCyan Black"
  bar   "Black Cyan"
)
```

It has to be a file (not your shell's init file) so that every ohm command sees it. Library code asks for `${THEME_ATTR[panel]}` and friends from `turbo_zsh/theme_lib.zsh`.

## 🎮 Creating Custom Menus

Your own items live in `user/m.mnu` (`ohm config init` creates a starter). It is a zsh file, sourced like your `.zshrc`; each item is an associative array:

```zsh
# [l] label ([X] marks the hotkey letter)   [k] hotkey   [c] command
typeset -A mi_sysinfo=([l]="[S]ystem info" [k]=s [c]="_popup ohm sysinfo")
typeset -A mi_build=(  [l]="[B]uild"       [k]=b [c]="_cmd make -C $HOME/code/app build")

# Simple form: the items to show are listed in `menu`
typeset -a topMenu=()
typeset -a menu=(mi_sysinfo mi_build)
```

To group items, list entries named `mnu_*` in `topMenu`; each one points at a loader function that fills `menu` and returns 255:

```zsh
typeset -A mnu_Tools=([l]="[T]ools" [k]=t [c]="_cmd loadToolsMenu")
loadToolsMenu() { menuTitle="Tools"; menu=(mi_sysinfo mi_build); return 255; }
typeset -a topMenu=(mnu_Tools)
```

Add `[d]=1` to an item to make it always ask before running. Commands are run as a word list (variables such as `$HOME` expand when the file is loaded; a bare `~` does not). `_cmd` and `_popup` prefixes are accepted for compatibility and mean the same thing. The command may also be a shell function defined in the file. A command that needs shell syntax (`&&`, `|`, `;`) runs through `eval`, which is fine because the file is yours.

Use another file with `MENU_FILE=~/my.mnu ohm menu`.

## 🎨 Demos & Samples

```zsh
# Fire animation
./menu_zsh/fire.zsh

# Color palette demo
./menu_zsh/palette.zsh

# Unicode character browser
./menu_zsh/unicode_browser.zsh
```

## 🛠️ Requirements

- **Zsh** 5.0+ (tested on 5.8+)
- **macOS** or **Linux** with a modern terminal emulator
- Terminal with:
  - ANSI color support (256 colors / truecolor recommended)
  - Unicode support (for box drawing and spinners)

## 📝 License

See [turbo_zsh/LICENSE](turbo_zsh/LICENSE) and [menu_zsh/LICENSE](menu_zsh/LICENSE).

## 🙏 Inspiration

- **Turbo Pascal / Turbo Vision** — Borland's legendary IDE and UI framework
- **Norton Commander** — The iconic file manager
- **DOS-era aesthetics** — Because terminals don't have to be boring!

---

*"Why? Because DOS did get one thing right: terminal interfaces don't have to be boring."*
