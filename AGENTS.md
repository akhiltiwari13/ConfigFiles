# PROJECT KNOWLEDGE BASE

**Generated:** 2026-03-30 | **Commit:** a7dda01 | **Branch:** main

## Overview

GNU Stow-managed dotfiles for 3 workstations: 2× Omarchy (Arch + Hyprland), 1× macOS Air.
Each top-level directory is a stow package mirroring `$HOME` structure. No build system, no tests, no CI.

## Structure

```
configfiles/
├── <pkg>/.config/<app>/       # Standard: stow links to ~/.config/<app>/
├── <pkg>/.<dotfile>           # Dotfiles: stow links to ~/.<dotfile>
├── lazyvim/nvim/.config/nvim/ # EXCEPTION: extra nesting (see lazyvim AGENTS.md)
├── omarchy-hyprland/          # Omarchy Hyprland overrides (see hypr AGENTS.md)
├── scripts/                   # NOT a stow package — utility scripts
├── setup/                     # Shell env setup (cocoEd.sh) — stows to ~/.config/
├── dumpyard/                  # Archived configs (i3, AstroNvim, zsh) — NOT stowed
├── stow/.stowrc               # Stow config itself — targets $HOME
└── .sisyphus/                 # Work plans (not stowed)
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Add new stow package | `mkdir -p pkg/.config/app && stow pkg` | Always dry-run first: `stow -n -v pkg` |
| Edit Hyprland config | `omarchy-hyprland/.config/hypr/` | 3-layer source hierarchy — see hypr AGENTS.md |
| Edit Neovim/LazyVim | `lazyvim/nvim/.config/nvim/lua/plugins/` | See lazyvim AGENTS.md for plugin conventions |
| Shell environment | `setup/.config/cocoEd.sh`, `cocoEd-fish.sh` | Bash has hostname detection; fish version hardcodes `~/files` |
| Install deps on new machine | `scripts/deps_install.sh` | Uses snap→apt fallback; needs sudo |
| Reference old configs | `dumpyard/` | i3, AstroNvim, bashrc, zshrc, old tmux |

## Stow Package Convention

```bash
# Standard package — links to ~/.config/<app>/
ghostty/.config/ghostty/config  →  ~/.config/ghostty/config

# Home dotfile — links to ~/.<file>
vim/.vimrc  →  ~/.vimrc
ssh/.ssh/config  →  ~/.ssh/config
```

**Non-standard packages** (don't follow `.config/` convention):
- `rectangle/` — `RectangleConfig.json` at root (macOS app)
- `ticker/` — `ticker.yaml` at root
- `vimium/` — `vimium-options.json` at root
- `vpn/` — credentials + ovpn at root

## Stow Commands

```bash
stow <pkg>           # Link package to $HOME
stow -D <pkg>        # Unlink package
stow -n -v <pkg>     # Dry-run (ALWAYS do this first)
stow -R <pkg>        # Restow (unlink + relink)
stow --adopt <pkg>   # Pull live files INTO repo, then link
stow --no-folding <pkg>  # Link individual files, not parent dir
```

## Omarchy Source Hierarchy

Omarchy uses 3-layer config precedence (later overrides earlier):

1. **Omarchy defaults** — `~/.local/share/omarchy/default/` — **DO NOT EDIT**
2. **Theme** — `~/.config/omarchy/current/theme/` — managed by Omarchy
3. **User overrides** — `~/.config/<app>/` — **your edits go here**

Applies to: hyprland, alacritty, ghostty, kitty (any config with `source` or `include` directives).

## File Formats & Conventions

| Format | Packages | Style |
|--------|----------|-------|
| Lua | lazyvim | 2 spaces, 120 cols, `stylua` formatter |
| .conf | hyprland, omarchy-hyprland | `#` comments, wiki links |
| TOML | starship, alacritty | Standard TOML |
| JSONC | waybar | 2 spaces, `//` comments |
| Shell | scripts, setup | `#!/usr/bin/env bash`, `snake_case` funcs, quote vars |

**Hyprland bindings**: Use `bindd` (with description), not `bind`.

## Git Commit Convention

```
[package|package] description
```

Examples: `[lazyvim|ssh] comment out ai plugins`, `[waybar] update vpn toggle script`

## Anti-Patterns (This Project)

- **DO NOT** edit Omarchy defaults at `~/.local/share/omarchy/default/` — updates overwrite them
- **DO NOT** commit secrets: `credentials.txt`, `antigravity-accounts.json`, `.credentials.json`, API keys
- **DO NOT** commit `lazy-lock.json` (gitignored, machine-specific plugin versions)
- **DO NOT** modify `omtmux/.config/tmux/tmux.conf` — file says `DO NOT MODIFY`; edit `tmux.conf.local` instead
- **DO NOT** stow `dumpyard/` — archived configs, not meant for linking
- **NEVER** `stow` without dry-run (`stow -n -v`) first on a new package
- **DO NOT** stow both `hyprland/` and `omarchy-hyprland/` — both target `~/.config/hypr/` and will conflict

## Machine-Specific Values

| File | Value | Issue |
|------|-------|-------|
| `setup/.config/cocoEd.sh` | `hostname` check | Handles Mac vs Linux paths — extend for new machines |
| `ssh/.ssh/config` | IP addresses, hostnames | Machine-specific by nature |
| `vpn/credentials.txt` | Username + password | **Should not be in repo** |

## Notes

- **btop**: If ported, set `save_config_on_exit = false` — otherwise auto-saves dirty git on every exit
- **Starship**: Config is `~/.config/starship.toml` (flat file), NOT `~/.config/starship/starship.toml`
- **lazyvim/nvim**: Extra nesting (`lazyvim/nvim/.config/nvim/`) — the `nvim/` layer is intentional
- **Theme hotreload**: LazyVim has `omarchy-theme-hotreload.lua` that reloads themes via `User LazyReload` autocmd
- Evolution: i3 → Hyprland, AstroNvim → LazyVim, zsh/bash → fish (old configs in `dumpyard/`)
- **hyprland/ vs omarchy-hyprland/**: Separate stow packages both targeting `~/.config/hypr/`. `omarchy-hyprland/` is for Omarchy systems (3-layer); `hyprland/` has standalone bindings. Never stow both.
- **setup/ has two files**: `cocoEd.sh` (bash) and `cocoEd-fish.sh` (fish) — fish version lacks hostname detection (always uses `~/files`)
- **Empty packages**: `fabric/`, and several others (`ccls/`, `clangd/`, `neofetch/`) may be minimal placeholders
- **waybar scripts**: `waybar/.config/waybar/scripts/` contains 4 VPN toggle scripts (`vpn-toggle.sh`, `vpn-multi-toggle.sh`, `openvpn.sh`, `openvpn3.sh`)
