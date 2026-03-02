# Ωhm — Development Gameplan

A roadmap for improving the structure, maintainability, and usability of the Ohm terminal UI toolkit.

---

## 📊 Current State Assessment

### Strengths ✅
- Solid core functionality in `turbo_zsh` libraries
- Clever module loading system (`uses()`)
- Good separation between core libs, menu system, and user config
- Fun demos that showcase capabilities
- Consistent load-guard pattern (`(( $+functions[*_loaded] ))`)

### Areas for Improvement ⚠️
- Mixed file extensions (`.zsh`, `.sh`) with inconsistent shebang usage
- No centralized documentation for all functions
- Missing test coverage
- No versioning or changelog
- User config mixed with core functionality
- Some code duplication between files

---

## 🎯 Phase 1: Foundation & Consistency (1-2 weeks)

### 1.1 Standardize File Naming
**Goal:** Consistent naming conventions across the project.

```
Current → Proposed
───────────────────────────────────────
menu_zsh/m.sh          → menu_zsh/menu.zsh
menu_zsh/init.sh       → menu_zsh/init.zsh
menu_zsh/about.sh      → menu_zsh/about.zsh
menu_zsh/samples/*.sh  → menu_zsh/demos/*.zsh
```

**Action Items:**
- [ ] Rename all `.sh` files to `.zsh` in Zsh-specific directories
- [ ] Update all `source` and reference paths
- [ ] Ensure all files have `#!/bin/zsh` shebang
- [ ] Create `demos/` folder (rename from `samples/`)

### 1.2 Add Load Guards Everywhere
**Goal:** Prevent double-loading of any module.

```zsh
# Standard pattern for ALL library files:
(( $+functions[<libname>_loaded] )) && return
<libname>_loaded() { :; }
```

**Action Items:**
- [ ] Audit all files for load guards
- [ ] Add missing guards to: `init_lib.zsh`, `window_lib.zsh`, etc.

### 1.3 Create Central Version File

```zsh
# version.zsh
export OHM_VERSION="0.1.0"
export OHM_VERSION_DATE="2026-01-30"
```

**Action Items:**
- [ ] Create `version.zsh`
- [ ] Source in `init.zsh`
- [ ] Add `ohm_version` command to display version info

---

## 🏗️ Phase 2: Structure & Organization (2-3 weeks)

### 2.1 Reorganize Directory Structure

```
ohm/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── version.zsh
│
├── bin/                    # 🆕 Executable scripts/commands
│   ├── m                   # Menu launcher (symlink or wrapper)
│   ├── ohm-info           # System/version info
│   └── ohm-demo           # Demo launcher
│
├── lib/                    # 🆕 Rename from turbo_zsh/
│   ├── core/              # Foundation libraries
│   │   ├── system.zsh     # Module loader (uses)
│   │   ├── crt.zsh        # Console/screen
│   │   └── keys.zsh       # Keyboard
│   ├── ui/                # UI components
│   │   ├── alerts.zsh
│   │   ├── dialogs.zsh    # 🆕 Extract from crt
│   │   ├── windows.zsh
│   │   └── spinner.zsh
│   └── util/              # Utilities
│       ├── string.zsh
│       └── math.zsh
│
├── menu/                   # Rename from menu_zsh/
│   ├── engine.zsh         # Core menu logic
│   ├── themes/            # 🆕 Menu color themes
│   └── templates/         # Menu file templates
│
├── demos/                  # 🆕 Consolidated demos
│   ├── life.zsh
│   ├── fire.zsh
│   ├── gallery/           # ASCII art samples
│   └── README.md
│
├── user/                   # User configurations (gitignored)
│   └── .gitkeep
│
├── examples/               # 🆕 Example scripts for users
│   ├── simple-menu.mnu
│   ├── custom-dialog.zsh
│   └── spinner-demo.zsh
│
└── tests/                  # 🆕 Test suite
    ├── run-tests.zsh
    ├── test-crt.zsh
    └── test-string.zsh
```

### 2.2 Create Backward Compatibility Layer

During transition, maintain old paths:

```zsh
# turbo_zsh/system_lib.zsh (deprecated, keep for compatibility)
echo "Warning: turbo_zsh is deprecated, use lib/ instead" >&2
source ${0:A:h}/../lib/core/system.zsh
```

### 2.3 Separate User Config from Repo

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

### 3.2 Inline Documentation

Standardize function documentation:

```zsh
# Function: DrawDialogBox
# Description: Draws a Norton Commander-style dialog box with a title bar.
# Parameters:
#   $1 - x: Left position
#   $2 - y: Top position  
#   $3 - w: Width
#   $4 - h: Height
#   $5 - title: Dialog title
#   $6 - bgColor: (optional) Background color, default Black
# Returns: 0 on success, 1 if dimensions too small
# Example: DrawDialogBox 10 5 40 10 "My Dialog" Blue
DrawDialogBox() {
  ...
}
```

### 3.3 Auto-Generate Documentation

Create a script to extract documentation from source:

```zsh
# scripts/generate-docs.zsh
# Parses function comments and generates markdown
```

---

## 🧪 Phase 4: Testing & Quality (2-3 weeks)

### 4.1 Create Test Framework

Simple Zsh-native test framework:

```zsh
# tests/framework.zsh
test_assert_equals() {
  local expected=$1 actual=$2 msg=$3
  if [[ "$expected" == "$actual" ]]; then
    echo "✓ $msg"
  else
    echo "✗ $msg: expected '$expected', got '$actual'"
    return 1
  fi
}
```

### 4.2 Unit Tests for Libraries

```zsh
# tests/test-string.zsh
source ../lib/util/string.zsh

test_PadLeft() {
  test_assert_equals "  abc" "$(PadLeft abc 5)" "PadLeft basic"
  test_assert_equals "abc"   "$(PadLeft abcdef 3)" "PadLeft truncate"
}

test_PadRight() {
  test_assert_equals "abc  " "$(PadRight abc 5)" "PadRight basic"
}
```

### 4.3 Visual/Integration Tests

Interactive test runner for visual components:

```zsh
# tests/visual-test.zsh
# Displays components and asks for manual verification
```

### 4.4 CI Integration

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
        run: zsh tests/run-tests.zsh
```

---

## 🎨 Phase 5: Features & Usability (Ongoing)

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

| Task | Impact | Effort | Priority |
|------|--------|--------|----------|
| Standardize file naming | Medium | Low | 🔴 High |
| Create main README | High | Low | 🔴 High |
| Add version file | Low | Low | 🟡 Medium |
| Reorganize directories | High | High | 🟡 Medium |
| Create test framework | High | Medium | 🟡 Medium |
| Theme system | Medium | Medium | 🟢 Low |
| Plugin system | Medium | High | 🟢 Low |
| Auto-generate docs | Low | Medium | 🟢 Low |

---

## 🚀 Quick Wins (Do This Week)

1. **✅ Create comprehensive README.md** — Done!
2. **Add `.gitignore` entries** for user configs
3. **Create `version.zsh`** with semantic versioning
4. **Add `CHANGELOG.md`** to track changes
5. **Rename `samples/` to `demos/`** for clarity
6. **Add missing load guards** to all libraries

---

## 📅 Suggested Timeline

| Week | Focus |
|------|-------|
| 1 | Quick wins, file standardization |
| 2-3 | Directory reorganization |
| 4-5 | Documentation |
| 6-7 | Testing framework |
| 8+ | New features (themes, components) |

---

## 🤝 Contributing Guidelines (Future)

Create `CONTRIBUTING.md` with:
- Code style guide (naming, comments, structure)
- PR process
- Testing requirements
- Documentation requirements

---

*Last updated: January 30, 2026*
