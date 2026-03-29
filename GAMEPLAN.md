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
- User config mixed with core functionality

---

## 🏗️ Phase 2: Structure & Organization

### 2.1 Separate User Config from Repo

**Action Items:**
- [ ] Add `user/` to `.gitignore`
- [ ] Create `user.example/` with template files
- [ ] Add setup script to copy examples to user/
- [ ] Document user customization in README

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
| Consolidate shared functions | Medium | Low | 🟡 Medium | 🔄 In progress |
| CI integration | Medium | Low | 🟡 Medium | Not started |
| Visual/integration tests | Medium | Medium | 🟡 Medium | Not started |
| Config script (`config --spinner`) | Medium | Low | 🟡 Medium | 🔄 Review & bug fixes |
| Theme system | Medium | Medium | 🟢 Low | Not started |
| Plugin system | Medium | High | 🟢 Low | Not started |

---

## 🚀 Quick Wins

1. **✅ Create comprehensive README.md** — Done!
2. **Add `.gitignore` entries** for user configs
3. **✅ Create `version.zsh`** with semantic versioning
4. **Add `CHANGELOG.md`** to track changes
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
| 2-3  | Documentation, naming conventions |
| 4-5  | Testing, CI integration |
| 6+   | New features (themes, components) |

---

## 🤝 Contributing Guidelines (Future)

Create `CONTRIBUTING.md` with:
- Code style guide (naming, comments, structure)
- PR process
- Testing requirements
- Documentation requirements

---

*Last updated: March 17, 2026*
