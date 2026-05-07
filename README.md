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

| Package      | Notes                                                                          |
| ------------ | ------------------------------------------------------------------------------ |
| bash-omarchy | `~/.bashrc` for Arch/omarchy + macOS — sources `~/.local/share/omarchy/default/bash/rc` (guarded so it's harmless elsewhere) |
| bash-ubuntu  | `~/.bashrc` for Ubuntu — `/etc/skel`-derived prompt/aliases + same toolchain init block as `bash-omarchy` |
| btop       | Set `save_config_on_exit = false` on new install to avoid git noise            |
| ccls       | C/C++ LSP config                                                               |
| clangd     | C/C++ LSP config                                                               |
| claudecode | settings.json + portable statusline (uses `$HOME`)                             |
| ghostty    | Terminal — Omarchy theme integration applies if Omarchy is in use              |
| gitconfig  | `includeIf` switches to work email on path match (see `gitconfig/.gitconfig`)  |
| lazydocker |                                                                                |
| lazygit    |                                                                                |
| lazyvim    | Note the intentional extra `nvim/` nesting in path                             |
| mise       | Tool versions (`config.toml`)                                                  |
| opencode   |                                                                                |
| ripgrep-all | rga config (`config.jsonc`); auto-gen schema not tracked                      |
| setup      | `cocoEd.sh` (bash) has hostname-switch                                         |
| ssh        | Machine-specific IPs/hostnames; current baseline ported from Omarchy live      |
| stow       | Just `.stowrc`                                                                 |
| tmux       | `tmux.conf` is Omarchy-vendored — edit `tmux.user.conf` for user customizations |
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
| dumpyard | Archived/retired configs: i3, i3status, dunst (X11 era); AstroNvim, vscode-neovim, old `nvim/` (pre-LazyVim); oh-my-tmux `conf.local`; crush, karabiner, neofetch, rectangle, sioyek, ticker (tried-and-discarded); fish, starship, vim, `cocoEd-fish.sh` (retired 2026-05-07) |
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
| `ubuntu` | 15 packages — cross-platform headless core (uses `bash-ubuntu`; no GUI/Wayland deps; no `ghostty`/`vimium`) | Remote dev box (uburemote) |
| `omarchy` | 27 packages — full set including `omarchy-*` and Wayland stack | Omarchy workstations (omarchy-tp) |
| `macair` | 18 packages — cross-platform core + `wezterm` | macOS Air (macair) |

Each profile's package list is in `scripts/bootstrap.sh`'s `<PROFILE>_PKGS` arrays — that file is the source of truth for "what's installed where" across the 3 workstations.

**First-time setup on a fresh box:**
1. Install `git`, `stow` (and `bash` if not default).
2. Clone this repo to `~/Work/projects/quomptrade/configfiles` (or anywhere, but the path is referenced from `setup/`'s scripts).
3. Run `stow stow` once manually (seeds `~/.stowrc` with the right `--target` + ignore patterns).
4. Run `./scripts/bootstrap.sh <profile>`.
5. Generate per-machine SSH keypairs and enroll their public halves with the matching GitHub identities. The repo only ships `~/.ssh/config` — keys themselves are per-machine and live locally:
   ```bash
   ssh-keygen -t ed25519 -C "akhiltiwari.13@gmail.com" -f ~/.ssh/id_ed25519
   ssh-keygen -t ed25519 -C "akhil@kensaltensi.org"     -f ~/.ssh/id_ed25519_kensalt
   ssh-add ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_kensalt
   ```
   Then enroll `~/.ssh/id_ed25519.pub` under the personal GitHub account and `~/.ssh/id_ed25519_kensalt.pub` under the Alkimi-org-linked account. The `Host github` / `Host github-work` aliases in `ssh/.ssh/config` use `IdentitiesOnly yes`, so without the matching local key file ssh has nothing to offer — agent forwarding from another box is *not* a substitute on a persistent dev box (forwarded sockets break across tmux reconnects and unattended jobs). Use `git@github-work:Alkimi-Exchange/...` URLs for work clones, or rely on the `url.insteadOf` rewrite that auto-routes `git@github.com:Alkimi-Exchange/...` URLs through the work alias.

Conflicts during stow (e.g. live real file where the repo wants to symlink) are reported but not auto-resolved — investigate per-package.

## Manual stow sequence (Ubuntu 24.04 desktop)

Step-by-step replication for a fresh Ubuntu 24.04 desktop. The bootstrap script's `ubuntu` profile is scoped for headless remotes (skips `ghostty` + `vimium`); this manual recipe includes them since a desktop has a GUI.

### Prereqs

```bash
sudo apt update
sudo apt install -y git stow bash
```

Plus install the runtime tools as needed: `btop`, `tmux`, `lazygit`, `lazydocker`, `fzf`, `ripgrep`, `ripgrep-all`, `mise`, `neovim` (≥ 0.11), etc. See `scripts/deps_install.sh` for apt+snap variants.

### Clone & seed

```bash
git clone <repo-url> ~/Work/projects/quomptrade/configfiles
cd ~/Work/projects/quomptrade/configfiles
stow stow                        # one-time: seeds ~/.stowrc with --target=$HOME + ignores
```

### Stow each package

Alphabetised. Run with `-n -v` first to dry-run if you want to preview. Conflicts (`WARNING! stowing X would cause conflicts`) usually mean a live real file at the target needs to be removed first — investigate per-package.

```bash
for pkg in bash-omarchy btop ccls clangd claudecode ghostty gitconfig \
           lazydocker lazygit mise opencode ripgrep-all setup ssh \
           tmux vimium; do
  stow -v "$pkg"
done
```

### lazyvim — special invocation (extra `nvim/` nesting)

The `lazyvim/` package has an intentional extra `nvim/` directory level so the real stow command differs from the others:

```bash
stow -d ~/Work/projects/quomptrade/configfiles/lazyvim nvim
```

(`scripts/bootstrap.sh` already special-cases this internally — see the `run_stow()` function.)

### Verify

```bash
ls -la ~/.config/{tmux,nvim,lazygit,lazydocker,git,claudecode,clangd,ccls,mise,ripgrep-all}
ls -la ~/.bashrc ~/.ssh/config
```

Each should be a symlink into `~/Work/projects/quomptrade/configfiles/<pkg>/...`.

### Equivalent automation

```bash
./scripts/bootstrap.sh ubuntu --dry-run
./scripts/bootstrap.sh ubuntu
```

Note: `bootstrap.sh`'s `ubuntu` profile omits `ghostty` and `vimium`. To use it on a desktop, either edit the `UBUNTU_PKGS` array in the script or stow those two manually after the script runs.

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
