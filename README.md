# Ωhm

> **Resistance is futile** — Retro-inspired terminal UI toolkit for Zsh

```
         __
  ____  / /_  ____ ___
 / __ \/ __ \/ __ `__ \
/ /_/ / / / / / / / / /
\____/_/ /_/_/ /_/ /_/
```

Ohm is a terminal user interface framework that brings back the nostalgic charm of DOS-era applications—think Turbo Pascal, Norton Commander, and Borland IDEs—to modern macOS and Linux terminals. Written entirely in Zsh, it provides colorful menus, dialog boxes, spinners, keyboard handling, and more.

## ✨ Features

- 🎨 **Rich Terminal UI** — ANSI colors, box drawing, dialogs, buttons
- ⌨️ **Keyboard Handling** — Arrow keys, function keys, escape sequences
- 📋 **Menu System** — Configurable hierarchical menus with hotkeys
- 🔄 **Spinners** — Animated loading indicators (20+ styles!)
- 🪟 **Window Management** — Stacked window contexts
- 🎭 **Fun Demos** — Conway's Game of Life, fire effect, ASCII art galleries

## 📦 Project Structure

```
ohm/
├── init.zsh              # Main entry point - source this in your .zshrc
├── init_lib.zsh          # Core initialization utilities
├── banner.zsh            # ASCII art banner
│
├── turbo_zsh/            # 🎯 Core UI Library (Turbo™)
│   ├── system_lib.zsh    # Module loading system (uses)
│   ├── crt_lib.zsh       # Console/screen control (colors, cursor, boxes)
│   ├── keys_lib.zsh      # Keyboard input handling
│   ├── string_lib.zsh    # String manipulation utilities
│   ├── math_lib.zsh      # Math helper functions
│   ├── spinner_lib.zsh   # Loading animations
│   └── alerts_lib.zsh    # Alert/notification bars
│
├── menu_zsh/             # 📋 Menu System
│   ├── m.sh              # Menu engine
│   ├── m.default.mnu     # Default menu configuration
│   ├── window_lib.zsh    # Window stack management
│   └── samples/          # Demo applications
│       ├── life.sh       # Conway's Game of Life
│       └── *.sh          # ASCII art galleries
│
├── user/                 # 👤 User-specific configurations
│   ├── m.mnu             # Custom menu definitions
│   └── init_*            # Per-user/host initialization
│
└── visier_dev/           # 🏢 Visier-specific developer tools
```

## 🚀 Quick Start

### Installation

```zsh
# Clone the repository
git clone <repo-url> ~/ohm
cd ~/ohm

# Install dependencies and create local config templates
./setup

# Add to your .zshrc
echo 'source ~/ohm/init.zsh' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

### Verify Install

```zsh
ohm doctor
```

If you need to regenerate user config files:

```zsh
ohm config init
```

### Launch the Menu

```zsh
m   # Opens the interactive menu system
```

### Use Libraries in Your Scripts

```zsh
#!/bin/zsh
source ~/ohm/init.zsh

uses crt_lib.zsh
uses alerts_lib.zsh

# Now you have access to all turbo_zsh functions!
info_bar "Hello from Ohm!"
SetColor Yellow Blue
ClrScr
WriteXY 10 5 "Welcome to the future of terminal UIs"
```

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
info_bar "This is informational"      # Blue bar with ℹ️
warning_bar "This is a warning"       # Yellow bar with ⚠️
error_bar "This is an error"          # Red bar
security_bar "Security alert!"        # Red bar with 🚓
sudo_prompt                           # Warn before sudo commands
```

### string_lib.zsh — String Utilities

| Function | Description |
|----------|-------------|
| `LeftStr str n` | Get first n characters |
| `PadLeft str w` | Right-align in width w |
| `PadRight str w` | Left-align in width w |
| `PadMiddle str w` | Center in width w |

## 🎮 Creating Custom Menus

Create a `.mnu` file with menu definitions:

```zsh
#!/bin/zsh
menuTitle="My Menu"

# Define menu items: [l]=label, [k]=hotkey, [c]=command
typeset -A mi_hello=([l]="Say [H]ello" [k]=h [c]="_popup echo 'Hello!'")
typeset -A mi_world=([l]="[W]orld"     [k]=w [c]="_cmd echo 'World'")

# Top menu bar
typeset -a topMenu=(mi_M)

# Current menu items
typeset -a menu=(mi_hello mi_world)
```

Run with:
```zsh
MENU_FILE=~/my.mnu m
```

## 🎨 Demos & Samples

```zsh
# Conway's Game of Life
./menu_zsh/samples/life.sh

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
