# AGENTS.md

## Project Identity
- Name: `ohm` (Omega/Ohm)
- Type: Zsh-based terminal UI toolkit plus personal shell utilities.
- Core purpose: provide retro-style terminal UI primitives (colors, dialogs, key handling, menus, spinners) and scripts built on top of them.

## Key Entrypoints
- `init.zsh`: main initialization file to source from shell startup.
- `m`: launcher for interactive menu system.
- `services`, `sysinfo`, `javainfo`, `setup`, `update`: executable utility scripts.

## Directory Map
- `turbo_zsh/`: core UI libraries (`crt_lib.zsh`, `keys_lib.zsh`, `spinner_lib.zsh`, etc.).
- `menu_zsh/`: menu engine and menu definitions (`m.sh`, `m.mnu`).
- `user/`: user-specific env/menu overrides (optional, machine/user specific).
- `README.md`: usage and API overview.
- `GAMEPLAN.md`: architecture/refactor roadmap.

## Practical Notes For Agents
- Shell is `zsh`; write scripts and examples for Zsh semantics.
- Prefer preserving existing retro terminal UX conventions when modifying UI output.
- This repo currently embeds `menu_zsh` and `turbo_zsh` with their own `.git` dirs; treat them as in-repo components unless asked to split.
- `rg` may not be installed in this environment; fallback to `find`/`grep` when needed.

## Safe Workflow
- Before edits: inspect `README.md`, `init.zsh`, and affected script/library files.
- After edits: run targeted script checks where possible (for Zsh scripts, at least `zsh -n <file>` on changed files).
- Avoid destructive git operations unless explicitly requested.

## Common Commands
- Start toolkit in shell: `source ./init.zsh`
- Open menu: `./m`
- Version info: `source ./init.zsh && OhmVersion`
- Syntax check a script: `zsh -n path/to/file.zsh`

## Function Documentation Standard (ZDOC v1)
- Public functions in `turbo_zsh/*.zsh` must include `#@` docblocks immediately above each function.
- Required tags: `#@fn`, `#@brief`, `#@args`, `#@ret`.
- Optional tags: `#@example`, `#@notes`, `#@since`, `#@deprecated`.
- Keep tags single-line and grep-friendly for manual generation.
- Internal underscore-prefixed helpers may omit docblocks.
- Full reference: `turbo_zsh/DEVELOPMENT.md`.

## Module Documentation Standard (ZDOC v1)
- Each `turbo_zsh/*.zsh` module should declare a top-of-file `#@module` header block.
- Required module tags: `#@module`, `#@brief`, `#@public`.
- Optional module tags: `#@depends`, `#@notes`, `#@since`, `#@deprecated`.
- Module headers should appear after shebang/shellcheck lines and before code.

## Function Style & Visibility Checks
- Public function names must use PascalCase (for example `DrawDialogBox`, `PadRight`).
- Public functions must be documented with `#@fn` blocks.
- Private/internal functions must be prefixed with `_` (underscore), including helper utilities.
- Underscore-prefixed functions are considered internal and may omit public docs.

## File Naming Conventions
- **Executable scripts**: No file extension, must have shebang (`#!/bin/zsh`) at top of file.
  - Examples: `m`, `sysinfo`, `tests`, `extract_zdoc`
  - Used for: demos, tests, utilities, standalone scripts
- **Sourced libraries**: Must have `.zsh` extension, no shebang required.
  - Examples: `crt_lib.zsh`, `app_lib.zsh`, `init.zsh`, `fire.zsh`
  - Used for: function libraries, init files, code meant to be sourced
- Rationale: Clear distinction between executables (run directly) and libraries (sourced into shell).
