# Hyprland Configuration (Omarchy)

## Overview

Hyprland window manager config using Omarchy's 3-layer source hierarchy. User overrides only — defaults are sourced from Omarchy system.

## Source Hierarchy (CRITICAL)

```
Layer 1: ~/.local/share/omarchy/default/hypr/   ← DO NOT EDIT (Omarchy updates overwrite)
  ├── autostart.conf
  ├── bindings/{media,clipboard,tiling-v2,utilities}.conf
  ├── envs.conf, looknfeel.conf, input.conf, windows.conf

Layer 2: ~/.config/omarchy/current/theme/        ← Managed by Omarchy theme system
  └── hyprland.conf

Layer 3: ~/.config/hypr/                         ← YOUR EDITS GO HERE (this directory)
  ├── hyprland.conf      # Main config — sources layers 1-3
  ├── monitors.conf      # Display setup (machine-specific)
  ├── bindings.conf      # Custom keybindings
  ├── looknfeel.conf     # Visual overrides (gaps, borders, blur)
  ├── input.conf         # Keyboard/mouse/touchpad
  ├── autostart.conf     # Startup applications
  ├── envs.conf          # Environment variables
  ├── hypridle.conf      # Idle/lock timeout
  ├── hyprlock.conf      # Lock screen appearance
  ├── hyprsunset.conf    # Night light / blue filter
  ├── xdph.conf          # XWayland desktop portal (screencopy)
  └── local_bin_scripts/  # Helper scripts (focus.sh, window_switcher.sh)
```

## Where to Look

| Task | File | Notes |
|------|------|-------|
| Add a keybinding | `bindings.conf` | Use `bindd` (with description), not `bind` |
| Change gaps/borders | `looknfeel.conf` | Overrides Omarchy defaults |
| Add startup app | `autostart.conf` | `exec-once = command` |
| Change monitor layout | `monitors.conf` | Machine-specific — differs per workstation |
| Edit lock screen | `hyprlock.conf` | Standalone, not layered |
| Idle/lock timeouts | `hypridle.conf` | Screensaver 2.5min, lock 5min, DPMS off 5.5min |
| Night light | `hyprsunset.conf` | Currently disabled (identity=true) |
| Focus/switching scripts | `local_bin_scripts/` | `focus.sh` (group-aware), `window_switcher.sh` (wofi) |

## Conventions

- **Comments**: `#` prefix, include wiki links: `# https://wiki.hyprland.org/Configuring/`
- **Bindings**: Always `bindd` with description field: `bindd = SUPER SHIFT, RETURN, Browser, exec, cmd`
- **Source order**: Omarchy defaults first, theme second, user overrides last — order matters
- **Old files**: `*.conf_old` / `*.conf.old` — kept for reference, not sourced

## Anti-Patterns

- **DO NOT** edit `~/.local/share/omarchy/default/hypr/` — Omarchy updates overwrite
- **DO NOT** change source order in `hyprland.conf` — breaks layering
- **DO NOT** duplicate Omarchy default bindings — override by redefining the same key combo
- `monitors.conf` is machine-specific — will differ between workstations
- `local_bin_scripts/` contains helper scripts (`focus.sh`, `window_switcher.sh`) — hardcoded `~/.local` paths
- **DO NOT** stow the separate `hyprland/` package alongside this one — both target `~/.config/hypr/`, causing file conflicts
