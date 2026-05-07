# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Type

GNU Stow-managed dotfiles for 3 workstations: 2× Omarchy (Arch + Hyprland), 1× macOS Air. **No build system, no tests, no CI.** Each top-level directory is a stow package mirroring `$HOME` structure.

`stow/.stowrc` sets `--target=$HOME` and ignores `.git`, `README.*`, `AGENTS.md`. The repo's authoritative knowledge base is `AGENTS.md` at the root, plus per-package AGENTS.md files (currently `omarchy-hyprland/.config/hypr/AGENTS.md`) — read these for full context before non-trivial edits.

## Stow Workflow

```bash
stow -n -v <pkg>     # ALWAYS dry-run first on a new package
stow <pkg>           # Link package to $HOME
stow -D <pkg>        # Unlink
stow -R <pkg>        # Restow (unlink + relink)
stow --adopt <pkg>   # Pull live files INTO repo, then link
```

Standard layout: `pkg/.config/app/file → ~/.config/app/file`. Home dotfiles: `pkg/.<file> → ~/.<file>`. Non-standard packages (vimium, vpn) place files at the package root.

**`lazyvim/` needs a non-standard invocation** because of the intentional extra `nvim/` nesting:

```bash
stow -d ~/Work/projects/quomptrade/configfiles/lazyvim nvim
```

`scripts/bootstrap.sh` special-cases this in its `run_stow()` function — manual stows must override `-d` themselves.

## Bootstrap

`scripts/bootstrap.sh <profile>` is the single source of truth for "what's installed where" across the 3 boxes. The `<PROFILE>_PKGS` arrays in that script define the per-host package set:

| Profile | Packages | Used on |
|---------|----------|---------|
| `ubuntu` | 17 — headless core, uses `bash-ubuntu`, no GUI/Wayland deps, no `ghostty`/`vimium`/`starship` | Remote dev box (uburemote) |
| `omarchy` | 29 — full set incl. `omarchy-*` and Wayland stack (no `starship` per dormancy) | Omarchy workstations (omarchy-tp) |
| `macair` | 21 — cross-platform core + `wezterm` | macOS Air |

```bash
./scripts/bootstrap.sh <profile> --list      # show what would be stowed
./scripts/bootstrap.sh <profile> --dry-run   # preview without changes
./scripts/bootstrap.sh <profile>             # actually stow
```

`scripts/` itself is **not a stow package** — it holds utility scripts run directly. Same goes for `dumpyard/` (archived configs).

## Critical Anti-Patterns

- **Never edit `~/.local/share/omarchy/default/`** — Omarchy updates overwrite it. User overrides go in `~/.config/<app>/` (i.e. this repo's package).
- **Treat `tmux/.config/tmux/tmux.conf` as Omarchy-managed** — it's byte-identical to Omarchy's shipped `~/.local/share/omarchy/config/tmux/tmux.conf`. Add user customizations to `tmux/.config/tmux/tmux.user.conf` instead (sourced from `tmux.conf` at the bottom). The upstream `omarchy-refresh-tmux` command is shimmed/blocked by `omarchy-overrides/` — see `KEYBINDINGS.md` §6.
- **Never stow `dumpyard/`** — archived configs (i3, AstroNvim, old zsh/bash, retired oh-my-tmux conf.local), not meant for linking.
- **Never commit** `lazy-lock.json`, `credentials.txt`, `antigravity-accounts.json`, `.credentials.json` (most are gitignored; verify).

## Omarchy 3-Layer Source Hierarchy

For configs with `source`/`include` directives (hyprland, alacritty, ghostty, kitty), precedence runs:

1. `~/.local/share/omarchy/default/` — Omarchy defaults, do not edit
2. `~/.config/omarchy/current/theme/` — managed by theme system
3. `~/.config/<app>/` — user overrides (this repo)

Source order in user `hyprland.conf` matters; do not reorder.

## Conventions

- **Commit messages**: `[package|package] description` — e.g. `[lazyvim|ssh] comment out ai plugins`, `[hypr] monitor reconfiguration for work`.
- **Hyprland bindings**: use `bindd` (with description field), not `bind`.
- **Lua (lazyvim)**: 2 spaces, 120 cols, `stylua` formatter.
- **Shell (scripts/, setup/)**: `#!/usr/bin/env bash`, `snake_case` funcs, quote vars.
- **Waybar**: JSONC with 2-space indent, `//` comments.

## Machine-Specific Files

These differ per workstation and require care when editing:

- `omarchy-hyprland/.config/hypr/monitors.conf` — display layout
- `setup/.config/cocoEd.sh` — uses `hostname` to switch Mac vs Linux paths (extend for new machines). The fish counterpart `cocoEd-fish.sh` lacks hostname detection.
- `ssh/.ssh/config` — IPs/hostnames (ported live → repo on Omarchy in commit `c8aed1b`; Mac Air sync requires manual merge against this baseline)
- **`bash-omarchy` vs `bash-ubuntu`** — mutually exclusive `~/.bashrc` packages. `bash-omarchy` covers Arch + macOS (sources `~/.local/share/omarchy/default/bash/rc`, guarded so it's harmless elsewhere). `bash-ubuntu` is for the Ubuntu remote (`/etc/skel`-derived prompt, same toolchain init block). Only stow one per host.

## Notable Quirks

- Starship config is the flat file `~/.config/starship.toml`, not nested under `starship/`.
- btop: if added to a new machine, set `save_config_on_exit = false` (otherwise it auto-saves and dirties git on every exit).
- LazyVim has `omarchy-theme-hotreload.lua` reloading colorschemes via `User LazyReload`.
- `KEYBINDINGS.md` (repo root) is the authoritative keybind hierarchy doc; `omarchy-overrides/.config/bin/keybind-audit` regenerates the cross-program audit on demand.
