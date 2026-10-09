# Changelog
*"Resistance is futile"*

All notable changes to ohm will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- **Plugins.** A plugin directory can provide `plugin.zsh` (shell setup), `menu.zsh` (menu items) and `libexec/ohm-<name>` (commands). Register with `OhmPlugin <dir>` or drop a directory/symlink into `user/plugins/`. New `ohm plugins` command; `ohm menu --no-plugins`; `ohm help` lists plugin commands; core commands cannot be shadowed. `ohm doctor` checks each plugin (syntax, and that every command starts in a clean environment).
- **Themes.** Colours are named roles (`turbo_zsh/theme_lib.zsh`) instead of hard-coded numbers, with four built-in themes: `classic` (the original look, byte-for-byte), `mono` (no hue), `green` and `amber` (phosphor). `ohm config theme` lists them with samples and saves a choice; user-defined themes are supported. The menu, panels, dialog boxes, alert bars, the spinner picker and `services` all follow the theme.
- Personal menu items accept `[d]=1` to always ask for confirmation.
- turbo_zsh `leak_test`: calls every public function in a fresh shell and fails on any global parameter or function left behind; it also fails when a public function is neither covered nor explicitly skipped.
- **`ohm menu`**: a popup menu for the directory you are in.** It lists the directory's mise tasks (`db:migrate` becomes *migrate* inside the group *db*; read live from `mise tasks ls --json`, so no configuration) and your own items from `user/m.mnu`. Hotkeys, search (`/`), a details pane (description, command, dependencies), breadcrumbs, live resizing, and tasks run with their real output on the normal screen. Tasks that look destructive (`destroy`, `reset`, `uninstall`, `delete`, `drop`, `purge`, `wipe`, `restore`, `permanently`) ask for confirmation showing the exact command; tasks that take arguments prompt for them. `--print` returns the command line instead of running it, `--list` prints the menu as text, `--dir`, `--all`, `--no-mise`, `--no-user`.
- **Prompt integration:** set `OHM_MENU_KEY` (for example `'^G'`) and the menu opens over your prompt; the chosen command is placed on the command line, not run.
- Security model for the menu: names and descriptions from a repository are untrusted and are stripped of control and escape sequences when stored; tasks run as argument lists without a shell; the menu never runs `mise trust`.
- turbo_zsh: `menu_lib.zsh` (the menu UI), `panel_lib.zsh` (inline framed panels), `StripControl`, `AltScreenOn/Off`, `KBD_PGUP/PGDN/HOME/END`; `app_lib` can run on the alternate screen and hand the terminal to a child program (`AppSuspend`/`AppResume`).
- ohm's own test suite (`zsh tests/tests`): provider tests against a fake `mise`, CLI tests, real-terminal tests driven through tmux (browsing, search, confirmation, `--print`, resize, the prompt widget), and end-to-end tests of `ohm config` and `ohm doctor`.
- **Git-style command layout:** `ohm <command>` runs `libexec/ohm-<command>`. `ohm help` lists commands from their `# Summary:` lines and `ohm help <command>` shows a command's options. Commands: `config`, `services`, `sysinfo`, `javainfo`, `cpu-bench`, `cpu-graph`, `update`.
- `ohm config init` creates missing starter files in `user/` from the new `user.example/` templates (never overwrites) and pins this machine's name; `ohm config get|set|path` read and write `user/config`.
- `ohm config spinner` now **saves** the choice; it is applied to every ohm command and to new shells (via `TURBO_SPINNER`).
- `ohm doctor` integrity checks, exiting non-zero on failure: script syntax, dangling references (sourced paths and `uses` libraries that no longer exist), a clean-shell bootstrap, every command starting in a clean environment, the turbo_zsh API contract, and renamed-host detection for `user/`.
- `TURBO_API_VERSION` (turbo_zsh) and `OHM_REQUIRES_TURBO` (`version.zsh`): compatibility contract between the separately cloned repos.
- turbo_zsh: `config_lib.zsh` (`ConfigGet`/`ConfigSet`: parsed, never sourced, atomic writes), `SpinnerIsValid`, tests for `config_lib` and `spinner_lib`, a `KEYS_FD` input override for testing key reads.
- `ohm update`, `./setup --zshenv`
- GitHub Actions CI (unit tests and `ohm doctor` on Linux and macOS)

### Changed

- `uses` now returns 2 instead of exiting when run in an interactive shell (a typo can no longer close your terminal); scripts still exit 2. Its message goes to stderr and it no longer leaks its loop variables.
- The spinner (`SpinnerStart`/`SpinnerStop`) no longer sets `INT`/`TERM` traps (it replaced an application's own), no longer leaks `INTERVAL`/`SPINNER_LENGTH` or defines a global `RunSpinner`, prints no `[1] pid` job messages, and stops by itself when the shell that started it exits. `SpinnerReadKey` uses the shared key reader.
- **No `~/.zshenv` hook needed.** `init.zsh`, the `ohm` dispatcher and every command bootstrap themselves (`init_env.zsh` is idempotent). The hook is now opt-in. Previously commands failed under `zsh -f`, `env -i`, cron and CI because zsh cannot export the `USES_PATH` array.
- `sysinfo`, `javainfo` and `services` draw their panels with the shared `panel_lib` instead of three hand-copied renderers. The output is visually identical except that the `sysinfo` title is now exactly centred (it moved 2 columns).
- `bin/ohm-menu`, `bin/services`, `bin/sysinfo` and `bin/javainfo` are deprecated shims that forward to `ohm <command>` and print a notice; use `ohm services`, `ohm sysinfo`, `ohm javainfo`.
- Host-specific `user/` files are keyed on `$OHM_HOST`, then the `host` setting, then the short hostname (macOS can rename machines when the network changes).
- `ohm services --help` works without a per-machine env file; a missing env file now says to run `ohm config init`.
- `setup` exits non-zero when dependency install or `ohm doctor` fails, and no longer sources `init.zsh`
- `init.zsh` adds `bin/` to `PATH` instead of the repo root
- Roadmap tracking moved from `GAMEPLAN.md` to Linear

### Fixed

- A spinner kept running forever if its shell was interrupted; it now ends with its parent.
- Public turbo_zsh functions leaked variables into the caller's shell: `j` (all four box-drawing functions), `char` (`HighlightString`) and `REPLY` (the key readers, `StripControl`, panel and menu functions).
- `ohm doctor` reported a failure on a fresh install because `init_env.zsh` mentions the optional `user/` directory.
- **`app_lib` never ran its cleanup at exit.** It set an `EXIT` trap inside `AppInit`, which zsh runs when *that function returns*, so the exit handler (and the terminal restore) fired immediately and never at script end. It now uses a `zshexit` hook, runs the exit handler last on the restored screen, and restores terminal modes.
- **`app_lib` ignored signals and resizes.** zsh does not run signal traps while a loop consists only of builtins (`read`), so `SIGTERM`, `SIGINT` from outside and window resizes were missed. The loop now runs a command substitution when idle, which also polls the window size. Signals stop the loop (they used to clean up and keep running).
- turbo_zsh `ReadKey`/`ReadLastKeyPress` are fed through one shared reader; keys can be injected through `KEYS_FD` for tests.
- **Enter was ignored** in key handling: a terminal delivers Enter as a newline, which `$(ReadKey)` stripped, so callers saw an empty string. This made `ohm config spinner` impossible to confirm and dropped Enter for every `app_lib` application. `ReadKey` and `ReadLastKeyPress` now return `KBD_CR`.
- Pressing `-` (or any key `print` would parse as an option) returned nothing from `ReadKey`.
- turbo_zsh `AssertTrue` passed its message to the command under test (`${@:1:$#-1}` does not drop the last argument in zsh), so assertions could pass vacuously.
- `ohm javainfo --help` failed on terminals narrower than 80 columns because the width check ran before option parsing.
- turbo_zsh's generated API manual was out of date (it predated `app_lib`); regenerated.
- Missing load guards in some library files

### Removed

- The legacy menu engine (`m` in the repo root, `menu_zsh/m`, `menu_zsh/m.mnu`). `bin/ohm-menu` forwards to `ohm menu`.
- Root `spinner` stub (use `ohm config spinner`) and root `update` script (use `ohm update`)
- Stale `sysinfo` and `javainfo` copies in menu_zsh (maintained versions live in `libexec/`)

### Known issues

- Menu items cannot yet be provided by a per-project file (for example `.ohm/menu.zsh`): that would run repository-controlled code and needs a trust model first.
- `menu_zsh/about` still uses colour constants that no longer exist.

---

## [0.1.0] - 2026-01-30

### Added

- Initial release
- **turbo_zsh** — Core UI library
  - `crt_lib.zsh` — Console/screen control with ANSI colors
  - `keys_lib.zsh` — Keyboard input handling
  - `string_lib.zsh` — String manipulation utilities
  - `math_lib.zsh` — Math helper functions
  - `spinner_lib.zsh` — 20+ animated loading spinners
  - `alerts_lib.zsh` — Colorful notification bars
  - `system_lib.zsh` — Module loading system
- **menu_zsh** — Interactive menu system
- **Demos**
  - Hierarchical menus with hotkey support
  - Norton Commander-style dialog boxes
  - Window management
- User-specific configuration support
  - Conway's Game of Life
  - Fire animation
  - Color palette viewer
  - Unicode browser
  - ASCII art galleries
- Multi-host configuration support
