# AGENTS.md — ohm Terminal UI Toolkit

## Project Identity

- **Name:** `ohm` (Omega/ohm)
- **Type:** Zsh-based terminal UI toolkit and personal shell utilities
- **Purpose:** Retro-style terminal UI primitives (colors, dialogs, key handling, menus, spinners) and scripts built on top of them

## Key Entrypoints

- `bin/ohm` — public CLI entrypoint exposed on `PATH`
- `bin/ohm-menu` — public menu launcher exposed on `PATH`
- `init.zsh` — main initialization file; source from shell startup
- `init_env.zsh` — early environment/bootstrap file; intended to be sourced from `.zshenv` so core `turbo_zsh` helpers are available in every Zsh invocation
- `m` — core menu launcher script kept in the repo root
- `services`, `sysinfo`, `javainfo`, `setup`, `update` — executable utility scripts
- `ohm` — CLI dispatcher (`ohm doctor`, `ohm version`, `ohm config spinner`, etc.)

Preferred direction:
- `ohm` should become the main public CLI surface.
- Generic top-level commands such as `config`, `services`, `sysinfo`, `spinner`, and `update` should move behind `ohm` subcommands over time.
- `./setup` should remain repo-local, not a globally relied-on `PATH` command.
- Prefer a small `bin/` directory with supported public entrypoints instead of adding the repo root to `PATH`.

## Directory Map

```
ohm/
├── init.zsh              # Main entry point
├── turbo_zsh/            # Core UI libraries
│   ├── system_lib.zsh    # Module loading (uses), shared helpers
│   ├── crt_lib.zsh       # Console/screen control
│   ├── keys_lib.zsh      # Keyboard input
│   ├── string_lib.zsh    # String utilities
│   ├── math_lib.zsh      # Math helpers
│   ├── spinner_lib.zsh   # Loading animations
│   ├── alerts_lib.zsh    # Alert/notification bars
│   ├── test_lib.zsh      # Test framework
│   └── tests/            # Per-module test files + runner
├── menu_zsh/             # Menu engine and definitions
│   ├── m.sh              # Menu engine
│   ├── window_lib.zsh    # Window stack management
│   └── samples/          # Demo applications
└── user/                 # User-specific overrides (optional, gitignored)
```

## Shell & Language

- **Shell is Zsh** — write all scripts and examples for Zsh semantics.
- Sourced libraries use `.zsh` extension, no shebang. Examples: `crt_lib.zsh`, `init.zsh`.
- Executable scripts have no file extension and must start with `#!/bin/zsh`. Examples: `m`, `sysinfo`, `tests`, `extract_zdoc`.
- Rationale: clear distinction between executables (run directly) and libraries (sourced into shell).

## Shell Loading Model

- `~/.zshenv` should source `init_env.zsh` so every Zsh invocation, including non-interactive shells and scripts, gets the basic `turbo_zsh` bootstrap functions.
- Interactive/user shell startup should source `init.zsh`.
- `init.zsh` is responsible for loading the user's global and machine-specific initialization from `user/`, including `init_${USER}` and `init_${USER}_${HOST%%.*}`.

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
ohm-menu                              # Open interactive menu
zsh -n path/to/file.zsh              # Syntax-check a script (run after edits)
zsh turbo_zsh/tests/tests             # Run all unit tests
ohm doctor                            # Check terminal capabilities
ohm version                           # Show version
ohm config spinner                    # Interactive spinner picker
```

## Workflow Guidelines

- Before edits: read `README.md`, `init.zsh`, and the affected file(s).
- After edits: run `zsh -n <file>` on every changed `.zsh` file.
- After library changes: run the test suite — `zsh turbo_zsh/tests/tests`.
- Preserve retro terminal UX conventions when modifying UI output.
- Avoid destructive git operations unless explicitly requested.
- `turbo_zsh/` and `menu_zsh/` may contain embedded `.git` dirs; treat them as in-repo components unless asked to split.
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

## Active Work (as of March 2026)

- `config --spinner` script: first pass done, needs bug fixes and persistence (write to user config).
- `config --theme` and `config --all` not yet implemented.
- Command namespace cleanup: move generic top-level commands behind `ohm` subcommands.
- Public `bin/` entrypoint layout is in progress; repo root scripts remain implementation files.
- CI integration not yet set up.
- Visual/integration tests not yet implemented.
- `user/` is gitignored; next follow-up is templating/documenting the user config flow.
