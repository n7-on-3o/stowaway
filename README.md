# 🪟 Niri Dotfiles

A **Wayland** desktop environment built on the **Niri** scrollable compositor. This setup uses **Material Design 3** color theory to dynamically theme the entire system based on the current wallpaper.

## 🚀 Core Components

* **Compositor:** [Niri](https://github.com/YaLTeR/niri) (Scrollable tiling window manager)
* **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/) (GPU-accelerated, Matugen-synced)
* **Editor:** [Micro](https://micro-editor.github.io/) (With auto-reloading Matugen colorschemes)
* **Bar:** [Waybar](https://github.com/Alexays/Waybar) (Vertical layout with interactive hover drawers)
* **Theming:** [Matugen](https://github.com/InioS/matugen) (Wallpaper-based color generation)
* **Wallpaper:** [SWWW](https://github.com/L_P_N_X/swww) (Animated wallpaper transitions)

## 🎨 Theming Logic

The system uses a custom `theme-switch` script to ensure 100% color consistency:

1.  **Wallpaper Selection:** Picks a random image from `~/Pictures/Wallpapers`.
2.  **Color Generation:** `matugen` parses the image and generates a Dark Mode palette.
3.  **Template Injection:** * **Kitty:** Updates `~/.config/kitty/colors.conf`.
    * **Micro:** Generates `~/.config/micro/colorschemes/matugen.yaml`.
    * **Waybar:** Updates CSS variables for the glass panels.
4.  **Live Reload:**
    * Kitty and Waybar watch their config files and update instantly.
    * Micro uses `set reload auto` to swap syntax colors on the fly.

## 🛠️ Installation & Setup

### Matugen Templates
Templates must be located in `~/.config/matugen/templates/`. The system requires:
* `kitty-colors.conf`
* `micro-colors.yaml` (Using the `colors.<role>.default.hex` scheme)

### Keybindings (Niri)
| Key | Action |
| :--- | :--- |
| `Mod + Return`        | Open Kitty Terminal |
| `Mod + Slash`         | **Theme Switch** (New wallpaper + colors) |
| `Mod + Alt + {1,2,3}` | Screen snip (with Swappy OCR/Edit) |

## 🧩 Visual Specs
* **Window Gaps / Radius:** 12px (Glass style)
* **Transparency:** 40% Background Opacity on Terminal and UI elements.
* **Blur:** Handled via Niri window rules for a frosted glass effect.

## 📦 Dependencies

### Core Tools
* `matugen`: Material You color generator.
* `niri`: The scrollable compositor.
* `kitty`: GPU-accelerated terminal.
* `micro`: Terminal-based text editor.
* `swww`: Efficient Waypaper daemon for transitions.
* `waybar`: Highly customizable status bar.

### Utilities
* `jq`: Command-line JSON processor.
* `swappy`: Snapshot editor.
* `grim` / `slurp`: Screen region selection.
* `wl-clipboard`: Clipboard management for OCR.
* `nerd-fonts-jetbrains-mono`: Primary UI and code font.
