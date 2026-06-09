# PROJECT KNOWLEDGE BASE

GNU Stow-managed dotfiles for 3 workstations: 2× Omarchy (Arch + Hyprland), 1× macOS Air.
Each top-level directory is a stow package mirroring `$HOME` structure. No build system, no tests, no CI.

## Quick Start

```bash
stow stow                              # one-time: seed ~/.stowrc with --target=$HOME
./scripts/bootstrap.sh <profile>       # stow the right packages for this machine
./scripts/bootstrap.sh <profile> --dry-run  # preview first
```

Three profiles defined in `scripts/bootstrap.sh` (it's the source of truth for what's installed where):

| Profile | Packages | Used on |
|---------|----------|---------|
| `ubuntu` | 15 — headless core (no GUI/Wayland) | Remote dev box (uburemote) |
| `omarchy` | 27 — full set incl. Wayland stack | Omarchy ThinkPad (omarchy-tp) |
| `macair` | 19 — cross-platform + `wezterm` + `zsh` | macOS Air |

`scripts/` and `dumpyard/` are NOT stow packages.

## Stow Conventions

Standard layout: `pkg/.config/app/file  →  ~/.config/app/file`
Home dotfiles:   `pkg/.file           →  ~/.file`
Non-standard:    `vimium/` and `vpn/` place files at the package root.

**Always dry-run first**: `stow -n -v <pkg>` before linking.

**`lazyvim` needs a special invocation** due to intentional extra `nvim/` nesting:
```
stow -d <repo>/lazyvim nvim
```

## Omarchy 3-Layer Hierarchy

Configs with `source`/`include` (hyprland, alacritty, ghostty, kitty) use this precedence:

1. `~/.local/share/omarchy/default/` — **DO NOT EDIT** (overwritten on update)
2. `~/.config/omarchy/current/theme/` — managed by theme system
3. `~/.config/<app>/` — user overrides (this repo)

Source order in `omarchy-hyprland/.config/hypr/hyprland.conf` matters — do not reorder.

## Anti-Patterns

- **DO NOT** edit `~/.local/share/omarchy/default/` — updates clobber it
- **DO NOT** modify `tmux/.config/tmux/tmux.conf` — it's Omarchy-vendored. Add customizations to `tmux/.config/tmux/tmux.user.conf` instead (sourced from `tmux.conf`). The upstream `omarchy-refresh-tmux` is shimmed/blocked by `omarchy-overrides/`
- **DO NOT** stow `dumpyard/` — archived configs (i3, AstroNvim, old shell configs), not for linking
- **DO NOT** commit: `credentials.txt`, `lazy-lock.json`, `antigravity-accounts.json`, `.credentials.json` (most are gitignored)
- **NEVER** stow without dry-run (`stow -n -v`) first

## Shell Packages (Mutually Exclusive)

| Package | Hosts |
|---------|-------|
| `bash-omarchy` | Omarchy (Arch) + macOS when using bash (sources `~/.local/share/omarchy/default/bash/rc`, guarded) |
| `bash-ubuntu` | Ubuntu remote (`/etc/skel`-derived, same toolchain init) |
| `zsh` | macOS oh-my-zsh |

Pick **one** per host. xpra helpers (`xrun`/`xrejoin`/`xls`/`xstop`) live in the client packages (`bash-omarchy`, `zsh`), not in `bash-ubuntu` (uburemote is the xpra server).

## Config Quirks

- **btop**: `save_config_on_exit = false` — edits via the UI won't persist; edit `btop/.config/btop/btop.conf` directly
- **Hyprland**: use `bindd` (with description), not `bind`
- **Keybindings**: `KEYBINDINGS.md` is the authoritative hierarchy doc; `omarchy-overrides/.config/bin/keybind-audit` regenerates the cross-program audit
- **Remote GUI**: xpra on `:100` — helpers `xrun`/`xrejoin`/`xls`/`xstop` in `bash-omarchy/.bashrc` (also `zsh`)
- **waybar VPN scripts**: `waybar/.config/waybar/scripts/` has 4 VPN toggle scripts (`vpn-toggle.sh`, `vpn-multi-toggle.sh`, `openvpn.sh`, `openvpn3.sh`)

## File Formats

| Format | Packages | Style |
|--------|----------|-------|
| Lua | lazyvim | 2 spaces, 120 cols, `stylua` formatter |
| .conf | hyprland, omarchy-hyprland | `#` comments, wiki links |
| TOML | alacritty | Standard TOML |
| JSONC | waybar | 2 spaces, `//` comments |
| Shell | scripts, setup | `#!/usr/bin/env bash`, `snake_case` funcs, quote vars |

## Commit Convention

```
[package|package] description
```

Examples: `[lazyvim|ssh] comment out ai plugins`, `[waybar] update vpn toggle script`
