# AGENTS.md — ohm Terminal UI Toolkit

## Project Identity

- **Name:** `ohm` (Omega/ohm)
- **Type:** Zsh-based terminal UI toolkit and personal shell utilities
- **Purpose:** Retro-style terminal UI primitives (colors, dialogs, key handling, menus, spinners) and scripts built on top of them

## Key Entrypoints

- `bin/ohm` — public CLI entrypoint exposed on `PATH`; execs the root `ohm` dispatcher
- `bin/ohm-menu` — deprecated shim for `ohm menu`
- `ohm` — CLI dispatcher. Built-ins: `doctor`, `version`, `help`. Everything else is `libexec/ohm-<name>`
- `libexec/ohm-*` — the commands behind the CLI: `menu`, `config`, `plugins`, `services`, `sysinfo`, `javainfo`, `cpu-bench`, `cpu-graph`, `update`
- `ohm_menu_lib.zsh` — menu providers for `ohm menu`: `OhmMenuMise` (`mise tasks ls --json`), `OhmMenuUser` (`user/m.mnu`). The UI itself is `turbo_zsh/menu_lib.zsh`
- `bin/services`, `bin/sysinfo`, `bin/javainfo` — deprecated shims that forward to `ohm <command>`; remove after the deprecation window
- `init.zsh` — interactive initialization; source from `.zshrc`. Self-contained (sources `init_env.zsh` itself)
- `init_env.zsh` — bootstrap: sets `OHM_PATH`/`OHM_USER_PATH`, loads turbo_zsh's `uses`. Idempotent
- `setup`, `setup.zsh` — installer; repo-local, not on `PATH`
- `user.example/` — starter files that `ohm config init` copies into `user/`

Preferred direction:
- `ohm` is the main public CLI surface; `bin/` stays a small supported set instead of adding the repo root to `PATH`.
- `./setup` stays repo-local, not a globally relied-on `PATH` command.
- Public planning and feature tracking live in Linear rather than a repo-local roadmap file.

### Adding a command

1. Create an executable `libexec/ohm-<name>` (lowercase, digits and `-` only; the dispatcher rejects anything else).
2. Line 2 is `# Summary: <one line>`; `ohm help` lists commands by that line.
3. Bootstrap with `source "${OHM_PATH:?run this as 'ohm <name>'}/init_env.zsh"`, then `uses ...`. Do not rely on `~/.zshenv`.
4. Support `-h`/`--help` and make it work on any terminal. **`--help` must only print usage and never do work**: `ohm doctor` runs `ohm help <name>` for every command (plugin commands too) in a clean environment.
5. Print the usage as `ohm <name> ...`.

## Directory Map

```
ohm/
├── ohm                   # CLI dispatcher + doctor/version
├── init.zsh              # Interactive entry point (.zshrc)
├── init_env.zsh          # Bootstrap (OHM_PATH, uses)
├── ohm_lib.zsh           # ohm helpers: config, host id, EnvUserHost
├── bin/                  # Public entrypoints on PATH (ohm, ohm-menu, shims)
├── libexec/              # ohm-<command> executables behind the CLI
├── ohm_menu_lib.zsh      # Menu providers (mise tasks, personal m.mnu)
├── user.example/         # Templates for `ohm config init`
├── tests/                # ohm's tests: zsh tests/tests (menu, CLI, config, doctor)
├── turbo_zsh/            # Core UI libraries (separate repo)
│   ├── init_env.zsh      # Module loading (uses), TURBO_API_VERSION
│   ├── system_lib.zsh    # Platform detection, PATH helpers
│   ├── crt_lib.zsh       # Console/screen control
│   ├── keys_lib.zsh      # Keyboard input
│   ├── string_lib.zsh    # String utilities
│   ├── math_lib.zsh      # Math helpers
│   ├── spinner_lib.zsh   # Loading animations
│   ├── config_lib.zsh    # Persistent KEY=value settings (ConfigGet/ConfigSet)
│   ├── menu_lib.zsh      # Popup menu: items, hotkeys, search, preview, hand-off
│   ├── panel_lib.zsh     # Inline framed panels
│   ├── alerts_lib.zsh    # Alert/notification bars
│   ├── app_lib.zsh       # Application event loop
│   ├── test_lib.zsh      # Test framework
│   └── tests/            # Per-module test files + runner
├── menu_zsh/             # Demos only (separate repo); the menu engine now lives in turbo_zsh/menu_lib.zsh
│   └── about, fire.zsh, palette.zsh, unicode_browser.zsh
└── user/                 # User-specific overrides (optional, gitignored)
```

## Shell & Language

- **Shell is Zsh** — write all scripts and examples for Zsh semantics.
- Sourced libraries use `.zsh` extension, no shebang. Examples: `crt_lib.zsh`, `init.zsh`.
- Executable scripts have no file extension (commands in `libexec/` use the `ohm-` prefix) and must start with `#!/bin/zsh`. Examples: `m`, `ohm-sysinfo`, `tests`, `extract_zdoc`.
- Rationale: clear distinction between executables (run directly) and libraries (sourced into shell).

## Shell Loading Model

Every entry point bootstraps itself; nothing requires `~/.zshenv`. (This replaces the earlier model where `~/.zshenv` had to source `init_env.zsh` for every Zsh invocation.)

- **Why:** `USES_PATH` is an array and zsh cannot export arrays, so a child process starts without it. Relying on `~/.zshenv` made every command fail under `zsh -f`, `env -i`, cron and CI, and put ohm's functions into every zsh invocation on the machine.
- `init_env.zsh` sets `OHM_PATH`, `OHM_USER_PATH` and loads `turbo_zsh/init_env.zsh` (`uses`, `TURBO_PATH`). It is idempotent (`AddSearchPathToUses` ignores duplicates), so sourcing it again is free.
- `init.zsh` (from `.zshrc`) sources `init_env.zsh`, loads `ohm_lib.zsh`, exports saved settings (`OhmLoadConfig`), adds `bin/` to `PATH`, then sources `user/init_${USER}` and `user/init_${USER}_$(OhmHostId)`.
- The `ohm` dispatcher bootstraps, runs `OhmLoadConfig` and `exec`s the command with `OHM_PATH`, `OHM_USER_PATH` and `TURBO_SPINNER` exported. Each command sources `init_env.zsh` itself.
- Turbo's own tests and demos also self-bootstrap via `turbo_zsh/init_env.zsh`.
- `~/.zshenv` hook: optional (`./setup --zshenv`), only for your own scripts that call `uses` without sourcing `init.zsh`.
- Host-specific `user/` files are keyed on `OhmHostId`: `$OHM_HOST`, then the `host` key in `user/config`, then the short hostname. `ohm config init` pins the current name because macOS can rename a machine.

## Product Conventions

- Treat `user/` as the supported user override layer; it is gitignored and intended for personal/global and host-specific customization.
- Persist settings with `OhmConfigSet`/`OhmConfigGet` (over turbo's `ConfigSet`/`ConfigGet`, file `user/config`, `KEY=value`); never hand-edit files or `source` a settings file. Settings that must reach child commands are exported by `OhmLoadConfig` (for example `spinner` becomes `TURBO_SPINNER`); an already-set environment variable wins.
- Release-facing work should preserve a clean install/bootstrap story, documented public commands, and a stable `bin/` entrypoint surface.
- Long-term release direction is closer to an Oh My Zsh-style distribution: polished install flow, supported customization model, and public docs/community hygiene.

## Naming Conventions

- **Public functions:** PascalCase — `DrawDialogBox`, `PadRight`, `SpinnerStart`
- **Private/internal functions:** underscore prefix — `_popup`, `_cmd`, `_load_guard`
- **Load guard pattern:** `(( $+functions[*_loaded] ))` at top of each lib

## Documentation Standard (ZDOC v1)

Public functions in `turbo_zsh/*.zsh` require `#@` docblocks:

```zsh
#@fn FunctionName
#@brief One-line description.
#@args 1:arg1 2:arg2
#@ret 0 on success, 1 on failure
FunctionName() { ... }
```

Required tags: `#@fn`, `#@brief`, `#@args`, `#@ret`.
Optional tags: `#@example`, `#@notes`, `#@since`, `#@deprecated`.
Keep tags single-line and grep-friendly.

Each module file should declare a `#@module` header block after shebang/shellcheck lines and before code:
- Required module tags: `#@module`, `#@brief`, `#@public`
- Optional module tags: `#@depends`, `#@notes`, `#@since`, `#@deprecated`

Internal `_underscore` helpers may omit docblocks. Full reference: `turbo_zsh/DEVELOPMENT.md`.

## Common Commands

```zsh
source ./init.zsh                     # Load toolkit into current shell
source ./init.zsh && OhmVersion       # Show version info
ohm menu                              # Popup menu for this directory (--list, --print)
zsh -n path/to/file.zsh              # Syntax-check a script (run after edits)
zsh turbo_zsh/tests/tests             # Run the turbo_zsh unit tests
zsh tests/tests                       # Run ohm's tests (menu, CLI, config, doctor; terminal tests need tmux + jq)
ohm doctor                            # Check install and script integrity
ohm update                            # Pull latest ohm, turbo_zsh, menu_zsh
ohm version                           # Show version
ohm config spinner                    # Interactive spinner picker (saved to user/config)
ohm config init                       # Create missing starter files in user/
ohm help                              # List commands
```

## Workflow Guidelines

- Before edits: read `README.md`, `init.zsh`, and the affected file(s).
- After edits: run `zsh -n <file>` on every changed `.zsh` file.
- After library changes: run the test suite — `zsh turbo_zsh/tests/tests`.
- After script, launcher or setup changes: run `ohm doctor`. It checks syntax, dangling references (sourced paths and `uses` libraries that no longer exist), a clean-shell bootstrap, and the turbo_zsh API contract. It exits non-zero on failure.
- Version contract: `turbo_zsh/` is a separate repo cloned unpinned. When ohm starts depending on new or changed turbo_zsh API (a new library, a changed function), bump `TURBO_API_VERSION` in `turbo_zsh/init_env.zsh` and `OHM_REQUIRES_TURBO` in `version.zsh` together, and note it in the comment above `TURBO_API_VERSION`. `ohm doctor` fails on a mismatch. Commit and push turbo_zsh first so `ohm update` can deliver it.
- Test commands and the `ohm` CLI in a clean environment, not only in your shell: `env -i HOME="$HOME" PATH="$PATH" ZDOTDIR=/var/empty zsh -f bin/ohm help <command>` (`ohm doctor` does this for every command).
- Preserve retro terminal UX conventions when modifying UI output.
- Avoid destructive git operations unless explicitly requested.
- `turbo_zsh/`, `menu_zsh/`, `user/` and `visier_dev/` are separate git repos, gitignored by ohm. Commit changes inside each one separately; treat them as in-repo components unless asked to split.
- Prefer `rg` for file and text search; fall back to `find`/`grep` only if `rg` is unavailable.

## Test Framework Usage

```zsh
uses test_lib.zsh

TestSection "[my_lib]"
AssertTrue IsFunctionDefined MyFunc "MyFunc() is defined"
AssertStringEquals "$actual" "$expected" "values match"
AssertContains "$actual" "substring" "output contains substring"
AssertStatus "$?" 0 "command succeeded"
PrintTestSummary
```

## Planning

- Linear is the source of truth for active roadmap items, launch work, and backlog tracking.
- Keep durable technical conventions in this file and user-facing usage in `README.md`.
- Avoid recreating a second roadmap document in the repo unless it captures stable reference material rather than task tracking.

## Plugins

- A plugin is a directory with optional `plugin.zsh` (sourced by `OhmPlugin` at registration; `OHM_PLUGIN_DIR`/`OHM_PLUGIN_NAME` are set), `menu.zsh` (sourced by `ohm menu`), and `libexec/ohm-<name>` commands. Sources: `$OHM_PLUGIN_PATH` (colon separated, exported so child commands inherit it) and `user/plugins/*` (auto-discovered, symlinks fine).
- `OhmPluginDirs`/`OhmPlugin`/`OhmLoadPlugins` live in `ohm_lib.zsh`; the dispatcher (`ohm`) tries core commands first, then plugin commands in plugin order, and exports `OHM_PLUGIN_DIR` for a plugin command. A plugin can never shadow a core command.
- Plugin code is trusted like `.zshrc`; a plugin whose `menu.zsh` fails costs only its own items (a notice names it).
- Tests: `tests/plugin_test`. A private plugin keeps its own tests in its repo (see `visier_dev/tests/`).

## Theme rules

- Never hard-code a colour in library or command code. Use the role lookups from `turbo_zsh/theme_lib.zsh`: `${THEME_ATTR[panel]}` ("97;44"), `${THEME_FG[hotkey]}`, `${THEME_BG[...]}`, and `${THEME_FGN[...]}`/`${THEME_BGN[...]}` (colour names for `SetColor`). They are filled by `ThemeSet`, so there are no forks in drawing code.
- A new colour need is a new **role** with a value in every theme (`theme_lib_test` fails when a theme lacks a role or a text role is unreadable on its background; `theme_ui_test` checks that `mono`, `green` and `amber` emit no stray hue). A foreground-only role (`-` as background) is drawn on whatever it sits on, so give it a "selected row" twin if it can appear on both.
- The `classic` theme must reproduce the original colours exactly.

## Library hygiene

- `turbo_zsh/tests/leak_test` calls every public function in a fresh shell and fails on any new global parameter or function. Public functions use `local` for every variable (including loop counters) and `local REPLY` when they use the internal `_Foo` helpers that return through `REPLY`. A new public function must be added to that test (or skipped there with a reason).
- `uses` exits 2 in a script when a library is missing and returns 2 in an interactive shell, so a typo cannot close a terminal.
- Background helpers (the spinner) must not set traps, must stop when their parent shell exits, and must be disowned (`&!`).

## Menu architecture

- `turbo_zsh/menu_lib.zsh` is a UI library with no ohm knowledge: providers call `MenuAddItem -p path -l label ... -- argv...`, `MenuGroup`, `MenuNotice`; `MenuRun` shows it on the alternate screen (`--print` returns the command line instead of running it). It runs on `app_lib`.
- Items are **argv lists**, stored as shell-quoted words and executed without `eval` in a subshell (so a function that `cd`s cannot move the menu). The only `eval` is a personal-menu command that uses shell operators, because that file is the user's own.
- Everything shown comes from repositories and is untrusted: `_StripControl` runs on every field when it is stored. Never print a stored field without that.
- A new source of items is a function that calls `MenuAddItem` (see `OhmMenuMise`). A provider that *sources repository-controlled code* (a per-project menu file) would need a trust model like mise's first; none exists on purpose.
- Tests: `turbo_zsh/tests/menu_lib_test` (pure logic, rendering geometry at many sizes, real execution), `tests/menu_providers_test` (fake `mise` in `tests/fixtures/bin`), `tests/menu_tui_test` (a real terminal through tmux).

## zsh gotchas found in this codebase

- **Signal traps run between jobs.** A loop made only of builtins (`read -t`) never lets zsh run `WINCH`/`TERM`/`USR1` traps (`HUP` is an exception). `AppRun` runs a command substitution whenever a read times out; keep that when editing the loop. Window size is polled with `stty size` for the same reason.
- **An `EXIT` trap set inside a function runs when that function returns**, not at shell exit. Use `zshexit_functions+=(fn)` (see `app_lib.zsh`).
- **`path`, `fpath`, `mpath`, `argv`, `status`** are special parameters. Do not use them as local variable names (`local path` breaks command lookup).
- **`print -n $key`** prints nothing for `-` or `-n`: use `print -rn -- "$key"`.
- **`${@:1:$#-1}`** does not drop the last argument; use `${@[1,-2]}`.
- **`read -k` reads the terminal, not stdin**; tests inject keys through `KEYS_FD`.
- **A multibyte character is not safe as the pad string** of `${(l:n::str:)}`; pad with spaces and substitute. In a C locale zsh counts bytes, so UI code ensures a UTF-8 `LC_CTYPE` (`_MenuEnsureUtf8`, `_StripControl`).
- **`$(<file)` breaks `zsh -n`** (it tries to open the file); use `$(cat file)` in code that `ohm doctor` syntax-checks.
- An unquoted `*...*` argument is a filename glob; quote patterns passed to helpers.
- Inside double quotes a nested `${(j: :)${(ok)assoc}}` sorts nothing (the inner expansion is a scalar); write `${(@ok)assoc}`.
- `"${=var}"` still splits into several words inside double quotes; do not use it to build one command string.
- BSD `sed` does not expand `\n` in a replacement and `-i` needs an empty suffix argument (`sed -i ''`).
