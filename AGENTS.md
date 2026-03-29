# AGENTS.md - Coding Agent Guidelines

## Overview

This is a **dotfiles/configuration repository** for syncing configs across multiple Omarchy
(Arch Linux + Hyprland) workstations. It uses **GNU Stow** for symlink management.

- **No build system, tests, or CI pipeline** - this is configuration-only
- Configs are linked to `$HOME` via stow
- Two workstations are maintained with this repo

## Repository Structure

```
configfiles/
├── <package>/                 # Stow package (e.g., ghostty, hyprland, waybar)
│   └── .config/
│       └── <app>/
│           └── config-files
├── <package>/                 # Alternative: home directory dotfiles
│   └── .vimrc                 # Files starting with . go directly in $HOME
├── stow/
│   └── .stowrc                # Stow configuration (targets $HOME)
├── scripts/
│   └── deps_install.sh        # Dependency installation script
├── setup/
│   └── .config/               # Shell environment setup (cocoEd.sh)
├── dumpyard/                  # Archived/unused configs (not stowed)
└── lazyvim/
    └── nvim/.config/nvim/     # Neovim/LazyVim configuration
```

### Stow Package Convention

Each stow package mirrors the home directory structure:
- `ghostty/.config/ghostty/config` → `~/.config/ghostty/config`
- `vim/.vimrc` → `~/.vimrc`
- `ssh/.ssh/config` → `~/.ssh/config`

## Stow Commands

```bash
# From the configfiles directory:

# Link a package to $HOME
stow <package>

# Unlink a package
stow -D <package>

# Preview what would be linked (dry-run)
stow -n -v <package>

# Restow (unlink then relink, useful after changes)
stow -R <package>
```

The `.stowrc` configures:
- Target: `$HOME`
- Ignores: `.git`, `README.*`

## File Types & Formatting

### Lua (LazyVim/Neovim)

Per `lazyvim/nvim/.config/nvim/stylua.toml`:
- **Indent**: 2 spaces
- **Line width**: 120 characters
- **Format**: Use `stylua` for formatting

```lua
return {
  {
    "plugin/name",
    opts = {
      setting = "value",
    },
  },
}
```

### Shell Scripts

- **Shebang**: `#!/usr/bin/env bash` (preferred) or `#!/bin/sh`
- **Functions**: `snake_case`
- **Variables**: `UPPER_CASE` for exports, `lower_case` for locals
- **Quoting**: Always quote variables `"$var"`

```bash
#!/usr/bin/env bash

notify() {
  local message="$1"
  notify-send -a "Script" "$message"
}
```

### Hyprland Configuration

- **Comments**: `#` prefix, include wiki links for reference
- **Bindings**: Use `bindd` for documented bindings with descriptions
- **Sources**: Source Omarchy defaults first, then custom overrides

```conf
# Learn how to configure: https://wiki.hyprland.org/Configuring/

# Source Omarchy defaults (don't edit these!)
source = ~/.local/share/omarchy/default/hypr/bindings.conf

# Your custom overrides
source = ~/.config/hypr/bindings.conf

# Custom binding with description
bindd = SUPER SHIFT, RETURN, Browser, exec, omarchy-launch-browser
```

### JSONC (Waybar, etc.)

- Standard JSON formatting with `//` comments allowed
- 2-space indentation

```jsonc
{
  "layer": "top",
  "modules-left": [
    "hyprland/workspaces"
  ],
  // Custom module
  "custom/vpn": {
    "exec": "~/.config/waybar/scripts/vpn-toggle.sh"
  }
}
```

### TOML (Starship, Alacritty, etc.)

- Standard TOML formatting
- Group related settings under headers

## Git Commit Convention

Follow the existing commit message pattern:

```
[package|package] description
```

Examples from history:
- `[lazyvim|ssh] comment out ai plugins due to keymap interactions`
- `[tmux|hyprland|waybar] configuration updates`
- `[waybar] update vpn toggle script`

For single package changes:
- `[hyprland] update bindings`

## Omarchy-Specific Guidelines

### Source Hierarchy

Omarchy uses a layered config system:
1. **Omarchy defaults**: `~/.local/share/omarchy/default/` - DO NOT EDIT
2. **User customizations**: `~/.config/<app>/` - Your overrides go here

### Hyprland Pattern

```conf
# In ~/.config/hypr/hyprland.conf:

# 1. Source Omarchy defaults first
source = ~/.local/share/omarchy/default/hypr/looknfeel.conf

# 2. Then source your custom overrides
source = ~/.config/hypr/looknfeel.conf
```

### Theme Integration

- Omarchy themes are in `~/.config/omarchy/themes/`
- Current theme symlinked at `~/.config/omarchy/current/theme/`
- Configs can source theme files: `include ~/.config/omarchy/current/theme/kitty.conf`

## Important Notes

### Do NOT Commit

- Secrets, credentials, API keys
- Machine-specific paths that differ between workstations
- Large binary files or caches
- `lazy-lock.json` (gitignored, machine-specific plugin versions)

### Machine-Specific Configs

Some configs may need machine-specific values (monitors, paths). Options:
1. Use conditional logic in configs where supported
2. Keep machine-specific portions in separate untracked files
3. Use environment variables for differing values

### Verifying Symlinks

```bash
# Check if a config is properly linked
ls -la ~/.config/hypr

# Should show:
# hypr -> ../Work/projects/configfiles/omarchy-hyprland/.config/hypr
```

### Adding New Packages

1. Create package directory: `mkdir -p newpkg/.config/newapp`
2. Add config files mirroring home structure
3. Test with dry-run: `stow -n -v newpkg`
4. Link: `stow newpkg`
5. Commit: `git add newpkg && git commit -m "[newpkg] add initial config"`
