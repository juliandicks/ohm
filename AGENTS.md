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
- Version info: `source ./init.zsh && ohm_version`
- Syntax check a script: `zsh -n path/to/file.zsh`

