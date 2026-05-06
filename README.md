# MY_DOT_FILES

- This repository has my **configuration files.**

- My workstation this primarily works on: Omarchy Linux.
  I also work on an macbook air and a remote ubuntu m/c

- As I use neovim as my primary text-editor/IDE, the idea behind this repository was to facilitate a quick setup on any workstation I may have to work on. It is assumed that existance of required external programs is a common understanding; programs such as LSP servers, any font family(some asthetic plugins may need special fonts) or other utilities such as ack & silversearcher.

- Following are some useful external tools.
  @todo: add more useful tools here like btop, opencode etc.
  - [fzf](https://github.com/junegunn/fzf)
  - [ccls](https://github.com/MaskRay/ccls)
  - [clangd](https://clangd.llvm.org/)
  - [pyls](https://github.com/palantir/python-language-server)
  - [gitPython](https://gitpython.readthedocs.io/en/stable/)

  > [!NOTE]
  > This repo has been re-formatted, so it could be used with gnu-stow to setup the dotfiles

## Cross-Platform Compatibility

Audit of which stow packages port cleanly across the 3 workstations (2× Omarchy, 1× macOS Air).

### Cross-platform (works on Mac + Omarchy + Ubuntu)

| Package    | Notes                                                                          |
| ---------- | ------------------------------------------------------------------------------ |
| bash       | `~/.bashrc` for interactive shell — leaves `~/.profile` and `~/.bash_profile` alone (OS defaults stay) |
| btop       | Set `save_config_on_exit = false` on new install to avoid git noise            |
| ccls       | C/C++ LSP config                                                               |
| clangd     | C/C++ LSP config                                                               |
| claudecode | settings.json + portable statusline (uses `$HOME`)                             |
| fish       |                                                                                |
| ghostty    | Terminal — Omarchy theme integration applies if Omarchy is in use              |
| gitconfig  | `includeIf` switches to work email on path match (see `gitconfig/.gitconfig`)  |
| lazydocker |                                                                                |
| lazygit    |                                                                                |
| lazyvim    | Note the intentional extra `nvim/` nesting in path                             |
| mise       | Tool versions (`config.toml`)                                                  |
| opencode   |                                                                                |
| ripgrep-all | rga config (`config.jsonc`); auto-gen schema not tracked                      |
| setup      | `cocoEd.sh` (bash) has hostname-switch; `cocoEd-fish.sh` lacks it              |
| ssh        | Machine-specific IPs/hostnames; current baseline ported from Omarchy live      |
| starship   | Flat file at `~/.config/starship.toml` (not under `starship/.config/...`)      |
| stow       | Just `.stowrc`                                                                 |
| tmux       | `tmux.conf` is Omarchy-vendored — edit `tmux.user.conf` for user customizations |
| vim        |                                                                                |
| vimium     | Browser extension JSON                                                         |

### Omarchy / Linux only

| Package           | Notes                                                                  |
| ----------------- | ---------------------------------------------------------------------- |
| alacritty         | Terminal (Omarchy theme integration)                                   |
| fastfetch         | References `omarchy-*` commands                                        |
| omarchy-hyprland  | Hyprland WM overrides (3-layer Omarchy hierarchy)                      |
| omarchy-overrides | Shims `omarchy-refresh-tmux` to protect repo-managed tmux config       |
| omarchy-themes    | Vendored community Omarchy themes (currently `dayfox`)                 |
| rofi              | X11 app launcher                                                       |
| vpn               | OpenVPN configs                                                        |
| wallpapers        | Backgrounds wired into Omarchy theme system                            |
| waybar            | Wayland status bar                                                     |
| zathura           | PDF viewer                                                             |

### macOS only

| Package | Notes                          |
| ------- | ------------------------------ |
| Brewfile | Homebrew package manifest     |
| wezterm | Terminal (used Mac-only today) |

### Not stowed (kept for reference)

| Path     | Purpose                                                                                                                            |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| dumpyard | Archived/retired configs: i3, i3status, dunst (X11 era); AstroNvim, vscode-neovim, old `nvim/` (pre-LazyVim); oh-my-tmux `conf.local`; crush, karabiner, neofetch, rectangle, sioyek, ticker (tried-and-discarded) |
| scripts  | Utility scripts run directly, not symlinked                                                                                        |

## Bootstrapping a new machine

`scripts/bootstrap.sh` is the one-shot installer. Pick a profile based on the host:

```bash
./scripts/bootstrap.sh ubuntu --list      # show what would be stowed
./scripts/bootstrap.sh ubuntu --dry-run   # preview without changes
./scripts/bootstrap.sh ubuntu             # actually stow
```

| Profile | What it installs | Used on |
| ------- | ---------------- | ------- |
| `ubuntu` | 18 packages — cross-platform headless core (no GUI/Wayland deps; no `ghostty`/`vimium`) | Remote dev box (uburemote) |
| `omarchy` | 29 packages — full set including `omarchy-*` and Wayland stack (no `starship` per dormancy) | Omarchy workstations (omarchy-tp) |
| `macair` | 21 packages — cross-platform core + `wezterm` | macOS Air (macair) |

Each profile's package list is in `scripts/bootstrap.sh`'s `<PROFILE>_PKGS` arrays — that file is the source of truth for "what's installed where" across the 3 workstations.

**First-time setup on a fresh box:**
1. Install `git`, `stow` (and `bash` if not default).
2. Clone this repo to `~/Work/projects/quomptrade/configfiles` (or anywhere, but the path is referenced from `setup/`'s scripts).
3. Run `stow stow` once manually (seeds `~/.stowrc` with the right `--target` + ignore patterns).
4. Run `./scripts/bootstrap.sh <profile>`.

Conflicts during stow (e.g. live real file where the repo wants to symlink) are reported but not auto-resolved — investigate per-package.

## Keymap audit (cross-program)

`omarchy-overrides/.config/bin/keybind-audit` aggregates keybinding inventories across the whole stack — Hyprland (`hyprctl binds`), Ghostty (config keybinds), tmux (`list-keys` if a server is up; static parse otherwise), Neovim (`nvim --headless` map dump) — into a single markdown report. Run it any time the stack changes to verify there are no chord collisions:

```bash
~/.config/bin/keybind-audit > /tmp/audit.md
```

The full leader hierarchy (Hyprland SUPER → Ghostty → tmux C-Space → Neovim Space → TUI letters) and the conflict matrix live in `KEYBINDINGS.md`.

## Omarchy command shimming via `environment.d`

Some Omarchy `omarchy-*` commands (notably `omarchy-refresh-tmux`) overwrite repo-managed config files when invoked. The `omarchy-overrides/` package shims those commands by:

1. Placing a wrapper at `~/.config/bin/<cmd>` that prints a notification and exits 1
2. Prepending `~/.config/bin` to `$PATH` for systemd-user services via `~/.config/environment.d/00-omarchy-overrides.conf`

This makes the wrapper shadow the real binary for both interactive shells AND Hyprland-launched menu/walker invocations. To deliberately bypass the shim and run the upstream binary, invoke by absolute path:

```bash
command ~/.local/share/omarchy/bin/omarchy-refresh-tmux
```

Verify the shim still works after an Omarchy update:

```bash
which omarchy-refresh-tmux        # expect: ~/.config/bin/omarchy-refresh-tmux
omarchy-refresh-tmux              # expect: BLOCKED stderr + exit 1
```

See `KEYBINDINGS.md` §6 for the full rationale.
