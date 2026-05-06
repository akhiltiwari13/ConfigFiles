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
| opencode   |                                                                                |
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
