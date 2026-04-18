# Ωhm — Development Gameplan

A roadmap for improving the structure, maintainability, and usability of the ohm terminal UI toolkit.

---

## 📊 Current State Assessment

### Strengths ✅
- Solid core functionality in `turbo_zsh` libraries
- Clever module loading system (`uses()`)
- Good separation between core libs, menu system, and user config
- Fun demos that showcase capabilities
- Consistent load-guard pattern (`(( $+functions[*_loaded] ))`)

### Areas for Improvement ⚠️
- ~~Mixed file extensions (`.zsh`, `.sh`) with inconsistent shebang usage~~ ✅ Fixed
- ~~No centralized documentation for all functions~~ ✅ ZDOC v1 + API_MANUAL.md
- ~~Missing test coverage~~ ✅ test_lib.zsh + per-module tests
- ~~No versioning or changelog~~ ✅ version.zsh exists
- ~~Some code duplication between files~~ ✅ Consolidated into system_lib.zsh
- User config is gitignored, but the example/template flow is still incomplete

---

## 🏗️ Phase 2: Structure & Organization

### 2.1 Separate User Config from Repo

**Action Items:**
- [x] Add `user/` to `.gitignore`
- [ ] Create `user.example/` with template files
- [ ] Add setup script to copy examples to user/
- [ ] Document user customization in README

### 2.2 Command Surface Cleanup

Reduce namespace collisions from generic top-level script names by making `ohm` the primary public CLI.

**Action Items:**
- [ ] Move feature commands behind `ohm` subcommands:
  - `config` -> `ohm config`
  - `services` -> `ohm services`
  - `sysinfo` -> `ohm sysinfo`
  - `spinner` -> `ohm spinner` or fold into `ohm config spinner`
  - `update` -> `ohm update`
- [ ] Keep `./setup` as a repo-local installer, but do not rely on `setup` being on `PATH`
- [ ] Audit other public entrypoints and decide which remain supported versus repo-local only
- [ ] Add compatibility shims or a deprecation window for renamed commands

---

## 📖 Phase 3: Documentation (1-2 weeks)

### 3.1 API Documentation

Create `docs/` directory with:

```
docs/
├── api/
│   ├── crt.md           # Full function reference
│   ├── keys.md
│   ├── alerts.md
│   ├── spinner.md
│   └── string.md
├── guides/
│   ├── getting-started.md
│   ├── creating-menus.md
│   ├── custom-dialogs.md
│   └── themes.md
└── examples/
    └── *.md
```

### 3.2 Inline Documentation ✅

Using ZDOC v1 format (see `turbo_zsh/DEVELOPMENT.md`):

```zsh
#@fn DrawDialogBox
#@brief Draws a Norton Commander-style dialog box with a title bar.
#@args 1:x 2:y 3:w 4:h 5:title 6:bgColor(optional)
#@ret status:0|1
DrawDialogBox() {
  ...
}
```

### 3.3 Auto-Generate Documentation ✅

```zsh
# turbo_zsh/scripts/extract_zdoc — Parses #@ docblocks and generates API_MANUAL.md
```

---

## 🧪 Phase 4: Testing & Quality (2-3 weeks)

### 4.1 Create Test Framework ✅

Zsh-native test framework in `turbo_zsh/test_lib.zsh`:

```zsh
uses test_lib.zsh

TestSection "[my_lib]"
AssertTrue IsFunctionDefined MyFunc "MyFunc() is defined"
AssertStringEquals "$actual" "$expected" "description"
AssertContains "$actual" "substring" "description"
AssertStatus "$?" 0 "description"
PrintTestSummary
```

### 4.2 Unit Tests for Libraries ✅

Per-module test files in `turbo_zsh/tests/`:
- `alerts_lib_test`, `app_lib_test`, `crt_lib_test`
- `keys_lib_test`, `math_lib_test`, `string_lib_test`, `system_lib_test`
- `tests` — runner that executes all test files

### 4.3 Visual/Integration Tests

Interactive test runner for visual components — not yet implemented.

### 4.4 CI Integration

Not yet implemented.

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: zsh turbo_zsh/tests/tests
```

---

## 🎨 Phase 5: Features & Usability (Ongoing)

### 5.0 Config Script — `config`

Interactive TUI for configuring ohm settings. Uses crt_lib, keys_lib, spinner_lib, string_lib.

**Status:** 🔄 First pass done (`config --spinner`), needs review and bug fixes.

**Implemented:**
- [x] `config --spinner` — scrollable spinner picker with live animated preview
- [x] Wired into `ohm config spinner`
- [x] `SpinnerSetDefault` in spinner_lib.zsh

**TODO:**
- [ ] Review and fix bugs in `config` script
- [ ] Persist spinner choice (write to user config file, load on init)
- [ ] `config --theme` — theme picker (after theme system lands)
- [ ] `config --all` — combined settings screen

### 5.0.1 Services Script — `services`

Context-aware service port checker. Checks user-defined service ports against listening ports.

**Status:** ✅ Done — production quality.

**Implemented:**
- [x] Context-aware resolution: CLI override (`-c`), directory walk via `SERVICE_CONTEXTS`, `SERVICE_LIST` fallback
- [x] Named service arrays with `SERVICES_` prefix convention
- [x] Available as a standalone utility script
- [x] Production polish: theme variables, proper types, consistent naming, `ErrorBar` errors

### 5.1 Theme System

```zsh
# lib/ui/themes.zsh
typeset -A OHM_THEME_DEFAULT=(
  [dialog_bg]=Blue
  [dialog_fg]=BrightWhite
  [button_bg]=BrightWhite
  [button_fg]=Black
  [highlight]=BrightYellow
  [error]=BrightRed
)

typeset -A OHM_THEME_DARK=(
  [dialog_bg]=BrightBlack
  ...
)

SetTheme() {
  local theme_name=$1
  # Apply theme colors globally
}
```

### 5.2 Input Components

New UI components:

```zsh
# Text input field
InputField x y width "prompt" default_value

# Radio buttons
RadioGroup x y options[@] selected_index

# Checkboxes  
CheckboxGroup x y options[@] selected[@]

# List selector
ListBox x y w h items[@] selected_index
```

### 5.3 Progress Indicators

```zsh
# Progress bar
ProgressBar x y width current max "label"

# Percentage display
ProgressPercent x y percent
```

### 5.4 Message Dialogs

```zsh
# Confirmation dialog
Confirm "Are you sure?" && do_something

# Alert dialog
Alert "Operation complete!"

# Input dialog
result=$(InputDialog "Enter name:")
```

### 5.5 Plugin System

Allow users to add custom libraries:

```zsh
# User can create: ~/.ohm/plugins/my-plugin.zsh
# Auto-loaded on startup

# plugins/my-plugin.zsh
ohm_plugin_init() {
  # Register custom commands
}
```

---

## 🔧 Phase 6: Developer Experience (1-2 weeks)

### 6.1 Setup Script

```zsh
# setup.zsh
#!/bin/zsh
# Interactive setup wizard
# - Detects shell config file
# - Adds source line
# - Creates user directory
# - Copies example configs
```

### 6.2 Development Mode

```zsh
# Enable verbose logging
export OHM_DEBUG=1

# Function tracing
export OHM_TRACE=1

# Reload all libraries
ohm_reload
```

### 6.3 Helper Commands

```zsh
ohm help              # Show help
ohm version           # Show version
ohm demo [name]       # Run demos
ohm colors            # Show color palette
ohm keys              # Key code debugger
ohm doctor            # Check terminal capabilities
```

### 6.4 Public Entrypoint Layout

Public entrypoints now live in `bin/`; continue moving toward a small supported surface there.

**Target Direction:**
- [x] Add a small `bin/` directory for supported public entrypoints
- [ ] Keep `ohm` as the canonical CLI
- [x] Optionally expose `ohm-menu` as a supported launcher
- [x] Update setup/init flow to add `bin/` instead of the repo root to `PATH`
- [ ] Remove reliance on generic top-level command names being available globally
- [ ] Audit and clean up any remaining assumptions that the repo root itself is on `PATH`

---

## 🚀 Phase 7: Product Launch Readiness

To ship ohm more like Oh My Zsh, the project needs a complete install, customization, documentation, and community surface, not just a working codebase.

### 7.1 Installation & Bootstrap

Create a polished install path for first-time users and unattended installs.

**Action Items:**
- [ ] Add a one-line remote installer (`curl`/`wget`) that clones/downloads ohm and runs setup safely
- [ ] Support unattended install mode for automation and dotfiles bootstrap
- [ ] Support custom install directory via environment variable
- [ ] Backup or migrate existing user config on install
- [ ] Add uninstall and reset flows
- [ ] Make `ohm doctor` cover full install/bootstrap health checks
- [ ] Add install smoke tests for fresh machine scenarios

### 7.2 Default User Experience

Make the out-of-box experience feel intentional, safe, and impressive on first run.

**Action Items:**
- [ ] Create a starter user config template that setup can copy into `user/`
- [ ] Add a first-run welcome flow with recommended defaults
- [ ] Pick and document a default theme/spinner/profile experience
- [ ] Add a clean sample menu and showcase demos that are safe to enable by default
- [ ] Add migration guidance for users updating from older ohm layouts

### 7.3 Customization, Themes & Extensions

Oh My Zsh succeeds partly because the customization model is obvious and extensible.

**Action Items:**
- [ ] Define a stable custom override directory model for user-added scripts/themes/extensions
- [ ] Implement the theme system planned in Phase 5
- [ ] Decide what a first-class ohm extension/plugin looks like and document the contract
- [ ] Bundle a small curated set of high-quality themes/profiles instead of a single default only
- [ ] Add discovery docs for creating custom menus, themes, and local extensions without forking

### 7.4 Documentation & Website

Users need a release-grade learning path, not just source files.

**Action Items:**
- [ ] Build a proper `docs/` tree with install, upgrade, customization, FAQ, and troubleshooting guides
- [ ] Add screenshots/GIFs/asciinema clips that show what ohm looks like in practice
- [ ] Write macOS and Linux install guides, including shell startup file behavior
- [ ] Document public commands, supported terminals, and compatibility expectations
- [ ] Add a release-ready landing page or lightweight docs site with install commands and feature highlights

### 7.5 Packaging & Distribution

Make ohm easy to install, update, and reference from outside the repo.

**Action Items:**
- [ ] Decide canonical install location (`~/.ohm`, `~/ohm`, or configurable default)
- [ ] Publish tagged releases and release notes
- [ ] Add a Homebrew tap/formula or another package-manager-friendly install path
- [ ] Ensure setup works from a tarball/release artifact, not only from a git clone
- [ ] Add stable URLs for install and docs

### 7.6 Quality, Compatibility & Release Engineering

Launch requires confidence across shells, terminals, and update paths.

**Action Items:**
- [ ] Add CI for syntax, unit tests, install tests, and CLI smoke tests
- [ ] Add a compatibility matrix for macOS/Linux and supported Zsh versions
- [ ] Add non-interactive smoke tests for `ohm`, `ohm-menu`, setup, and update flows
- [ ] Add visual/integration tests for terminal UI rendering where feasible
- [ ] Add release checklists and automated pre-release verification
- [ ] Decide how updates are delivered and whether auto-update support is in scope

### 7.7 Trust, Governance & Community

An open-source launch needs contributor and user-facing project hygiene.

**Action Items:**
- [ ] Add a top-level `LICENSE`
- [ ] Add `CONTRIBUTING.md`
- [ ] Add `CODE_OF_CONDUCT.md`
- [ ] Add `SECURITY.md`
- [ ] Add GitHub issue templates and PR templates
- [ ] Enable Discussions or document where community support should happen
- [ ] Define maintainer expectations and release ownership

### 7.8 Launch Program

Treat launch as a staged rollout, not a one-time publish.

**Action Items:**
- [ ] Define launch criteria for beta vs v1.0
- [ ] Run a small external beta with fresh-user install feedback
- [ ] Collect and fix first-run paper cuts before broad announcement
- [ ] Prepare announcement copy, demo assets, and example configurations
- [ ] Create a post-launch backlog for themes, plugins/extensions, and platform improvements

---

## 📋 Priority Matrix

| Task | Impact | Effort | Priority | Status |
|------|--------|--------|----------|--------|
| Standardize file naming | Medium | Low | 🔴 High | ✅ Done |
| Create main README | High | Low | 🔴 High | ✅ Done |
| Add version file | Low | Low | 🟡 Medium | ✅ Done |
| ZDOC inline docs | High | Medium | 🔴 High | ✅ Done |
| Create test framework | High | Medium | 🟡 Medium | ✅ Done |
| Auto-generate docs | Low | Medium | 🟢 Low | ✅ Done |
| PascalCase naming convention | Medium | Medium | 🔴 High | ✅ Done |
| Consolidate shared functions | Medium | Low | 🟡 Medium | ✅ Done |
| Command surface cleanup | High | Medium | 🔴 High | Not started |
| Install/bootstrap productization | High | Medium | 🔴 High | Not started |
| Default user template and first-run UX | High | Medium | 🔴 High | Not started |
| Docs site and launch docs | High | Medium | 🔴 High | Not started |
| Packaging and release distribution | High | Medium | 🔴 High | Not started |
| Governance and community files | High | Low | 🟡 Medium | Not started |
| CI integration | Medium | Low | 🟡 Medium | Not started |
| Visual/integration tests | Medium | Medium | 🟡 Medium | Not started |
| Config script (`config --spinner`) | Medium | Low | 🟡 Medium | 🔄 In progress |
| Context-aware `services` | High | Medium | 🟡 Medium | ✅ Done |
| Public `bin/` entrypoint layout | High | Medium | 🟡 Medium | 🔄 In progress |
| Theme system | Medium | Medium | 🟢 Low | Not started |
| Extension/plugin model | High | High | 🟡 Medium | Not started |
| Plugin system | Medium | High | 🟢 Low | Not started |

---

## 🚀 Quick Wins

1. **✅ Create comprehensive README.md** — Done!
2. **✅ Add `.gitignore` entries** for user configs
3. **✅ Create `version.zsh`** with semantic versioning
4. **✅ Add `CHANGELOG.md`** to track changes
5. **✅ Standardize file naming** — executables: no extension + shebang; sourced: `.zsh`
6. **✅ Add load guards** to all libraries
7. **✅ ZDOC v1 docblocks** on all public functions
8. **✅ PascalCase public functions** in all modules
9. **✅ Consolidate shared functions** — `SourceIfExists`, `AddPath`, `InsertPath` into system_lib.zsh
10. **✅ `global()` helper** — cleaner alternative to `typeset -g`

---

## 📅 Suggested Timeline

| Week | Focus |
|------|-------|
| 1    | Quick wins, file standardization |
| 2-3  | Documentation, naming conventions, command consolidation |
| 4-5  | Public `bin/` layout, install/bootstrap, command deprecations |
| 6-7  | CI, compatibility, release engineering |
| 8-9  | Docs site, screenshots, packaging, governance files |
| 10+  | Beta launch, feedback fixes, themes/extensions, broader release |

---

## 🤝 Contributing Guidelines (Future)

Create `CONTRIBUTING.md` with:
- Code style guide (naming, comments, structure)
- PR process
- Testing requirements
- Documentation requirements

---

*Last updated: April 18, 2026*
