# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Type

GNU Stow-managed dotfiles for 3 workstations: 2× Omarchy (Arch + Hyprland), 1× macOS Air. **No build system, no tests, no CI.** Each top-level directory is a stow package mirroring `$HOME` structure.

`stow/.stowrc` sets `--target=$HOME` and ignores `.git`, `README.*`, `AGENTS.md`. The repo's authoritative knowledge base is `AGENTS.md` at the root, plus per-package AGENTS.md files (currently `lazyvim/nvim/.config/nvim/AGENTS.md`) — read these for full context before non-trivial edits. `KEYBINDINGS.md` at the root is the authoritative cross-program keybinding hierarchy (Hyprland → terminal → tmux → Neovim → TUI letters); consult it before touching any chord-bearing config.

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
| `ubuntu` | 15 — headless core, uses `bash-ubuntu`, no GUI/Wayland deps, no `ghostty`/`vimium` | Remote dev box (uburemote) |
| `omarchy` | 27 — full set incl. `omarchy-*` and Wayland stack | Omarchy workstations (omarchy-tp) |
| `macair` | 19 — cross-platform core + `wezterm` + `zsh` | macOS Air |

```bash
./scripts/bootstrap.sh <profile> --list      # show what would be stowed
./scripts/bootstrap.sh <profile> --dry-run   # preview without changes
./scripts/bootstrap.sh <profile>             # actually stow
```

On a fresh box, run `stow stow` once manually before `bootstrap.sh` — that seeds `~/.stowrc` with the right `--target` and ignore patterns. `scripts/deps_install.sh` is the companion runtime-deps installer (apt+snap fallback, also handles xpra server bits for uburemote).

`scripts/` itself is **not a stow package** — it holds utility scripts run directly. Same goes for `dumpyard/` (archived configs).

## Critical Anti-Patterns

- **Never edit `/usr/share/omarchy/default/`** — Omarchy 4 ships this as a root-owned pacman package; updates overwrite it. User overrides go in `~/.config/<app>/` (i.e. this repo's package). `~/.local/share/omarchy` is now just a compat **symlink** to `/usr/share/omarchy`, so old docs/scripts referencing it still resolve.
- **Never run `stow opencode` (or `bootstrap.sh`) on this box until the package layout is fixed** — `~/.config/opencode` is a hand-made symlink to the *package root*, so `stow -n -v opencode` shows it would `UNLINK` that working link and litter `$HOME` with `~/node_modules`, `~/opencode.json`, `~/package.json`, `~/opencode.jsonc.bak`. `opencode` is in **all three** profile arrays in `scripts/bootstrap.sh`. See Notable Quirks.
- **Treat `tmux/.config/tmux/tmux.conf` as Omarchy-managed** — it's byte-identical to Omarchy's shipped `/usr/share/omarchy/config/tmux/tmux.conf`. Add user customizations to `tmux/.config/tmux/tmux.user.conf` instead (sourced from `tmux.conf` at the bottom). The upstream `omarchy-refresh-tmux` command is shimmed/blocked by `omarchy-overrides/` — see `KEYBINDINGS.md` §6.
- **Never stow `dumpyard/`** — archived configs (i3, AstroNvim, old zsh/bash, retired oh-my-tmux conf.local), not meant for linking.
- **Never commit** `lazy-lock.json`, `credentials.txt`, `antigravity-accounts.json`, `.credentials.json` (most are gitignored; verify).

## Omarchy 4 Layer Hierarchy (host runs `4.0.0.alpha`, "quattro")

Precedence for layered configs:

1. `/usr/share/omarchy/default/` — Omarchy defaults, root-owned, do not edit
2. `~/.local/state/omarchy/current/theme/` — managed by the theme system (**moved** from `~/.config/omarchy/current/`)
3. `~/.config/<app>/` — user overrides (this repo)

`~/.local/state/omarchy/` also holds `toggles/`, `migrations/`, and other generated state — treat it as machine state, not config to track.

### Hyprland is now configured in Lua, not `.conf`

Omarchy 4 switched Hyprland's config provider. Confirm with `hyprctl systeminfo | grep -i configprovider` → `configProvider: lua`.

Entry point is `~/.config/hypr/hyprland.lua`, which runs in this order (**do not reorder**):

```lua
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")
require("default.hypr.omarchy")   -- Omarchy defaults
require("hypr.monitors")          -- your overrides, loaded after defaults
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")
require("default.hypr.toggles")
```

`bootstrap.lua` sets `package.path` to `~/.local/state/?.lua;~/.config/?.lua;$OMARCHY_PATH/?.lua`, which is why `require("hypr.monitors")` resolves to `~/.config/hypr/monitors.lua`.

Only Hyprland moved to Lua — **alacritty, ghostty, and kitty still use plain `source`/`include`** and are unaffected.

Hyprland Lua API used in this repo:

| Old `.conf` | Omarchy 4 Lua |
|---|---|
| `bindd = SUPER SHIFT, R, SSH, exec, cmd` | `o.bind("SUPER + SHIFT + R", "SSH", "cmd")` |
| (unbind a default) | `hl.unbind("SUPER + SPACE")` |
| `monitor = DP-1,2560x1440@60,0x0,1` | `hl.monitor({ output = "DP-1", mode = "2560x1440@60", position = "0x0", scale = 1, transform = 1 })` |
| `env = GDK_SCALE,1` | `hl.env("GDK_SCALE", "1")` |
| `windowrule = workspace 5, class:qemu` | `o.window("qemu", { workspace = "5" })` |

Kill-switches `omarchy_default_bindings = false` and `omarchy_preinstalled_bindings = false` must be set in `hyprland.lua` **before** `require("default.hypr.omarchy")`.

`omarchy-hyprland/.config/hypr/.luarc.json` points lua-ls at `/usr/share/hypr/stubs` and declares the `hl` / `o` globals — that's what gives completion and clean diagnostics when editing these files.

## Conventions

- **Commit messages**: `[package|package] description` — e.g. `[lazyvim|ssh] comment out ai plugins`, `[hypr] monitor reconfiguration for work`.
- **Hyprland bindings**: `o.bind("MOD + KEY", "Description", "command")` — always pass the description (it feeds `omarchy menu keybindings --print`). To replace a default, `hl.unbind(...)` first, then bind. The old `bindd =` `.conf` syntax is dead on this host.
- **Lua (lazyvim)**: 2 spaces, 120 cols, `stylua` formatter.
- **Lua (omarchy-hyprland)**: 2 spaces, follows Omarchy's shipped template comments; keep the commented-out examples as inline documentation.
- **Shell (scripts/, setup/)**: `#!/usr/bin/env bash`, `snake_case` funcs, quote vars.

## Machine-Specific Files

These differ per workstation and require care when editing:

- `omarchy-hyprland/.config/hypr/monitors.lua` — display layout (the `.conf` sibling is legacy and no longer read)
- `setup/.config/cocoEd.sh` — uses `hostname` to switch Mac vs Linux paths (extend for new machines). The retired fish counterpart now lives at `dumpyard/cocoEd-fish.sh`.
- `ssh/.ssh/config` — IPs/hostnames (ported live → repo on Omarchy in commit `c8aed1b`; Mac Air sync requires manual merge against this baseline)
- **`bash-omarchy` vs `bash-ubuntu` vs `zsh`** — mutually exclusive shell packages. `bash-omarchy` covers Arch + macOS-via-bash (sources `~/.local/share/omarchy/default/bash/rc` — still correct under Omarchy 4, since that path is a compat symlink to `/usr/share/omarchy`; guarded so it's harmless elsewhere). `bash-ubuntu` is for the Ubuntu remote (`/etc/skel`-derived prompt, same toolchain init block). `zsh` is the macOS-via-zsh package (oh-my-zsh + Mac Homebrew paths). Pick one per host. xpra helpers (`xrun`/`xrejoin`/`xls`/`xstop`) and the `quompt` alias live in `bash-omarchy` and `zsh` — the client packages — but not in `bash-ubuntu`, since uburemote *is* the xpra server.

## Omarchy 4 Migration (completed 2026-08-22)

The quattro upgrade landed on 2026-08-21 and the repo was brought in sync the next day. What changed:

### Hyprland is Lua-only

`omarchy-hyprland/.config/hypr/` holds **five `.lua` files** (`hyprland`, `monitors`, `input`, `bindings`, `looknfeel`, `autostart`) plus `.luarc.json`. All the `source`-based `.conf` files were deleted — they are recoverable from git history if ever needed.

**Only genuine deviations from Omarchy's defaults belong in these files.** 23 of the original 27 `bindd` lines were dropped during the port because Omarchy 4 now ships them verbatim — same chord, same description, same URL. Re-adding one would double-bind it. The four that remain are documented inline in `bindings.lua`.

Before adding a binding, check whether Omarchy already ships it:

```bash
grep -n 'o\.bind' /usr/share/omarchy/default/hypr/bindings/*.lua
```

Beware: some of those lines are written `o.bind( "KEY"` with a space, so a naive `o\.bind\("` grep silently misses them.

To override a default, `hl.unbind(...)` first, then bind — see `bindings.lua` for the pattern. `hyprctl binds` is the ground truth for what is actually live.

Still `.conf`, unaffected by the Lua move (separate daemons with their own parsers): `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf`.

**`monitors.lua` matches monitors by `desc:`, not `DP-N`** — port numbers get reassigned across dock/replug cycles while the descriptor is stable. It also pins workspaces 1/2/3 to left BenQ / middle BenQ / laptop and routes chromium and the Slack webapp to their workspaces. Both BenQ panels run at **75Hz**; the Omarchy-generated template had silently dropped them to 60.

### waybar → quickshell

Omarchy 4 replaced waybar with **quickshell** (pacman `quickshell-git`), running as `quickshell -n -p /usr/share/omarchy/shell`, launched by `omarchy-launch-shell` from Omarchy's default `autostart.lua`.

- Bar config is the **`omarchy-shell/`** package → `~/.config/omarchy/{shell.json,shell.toml}`, driven by `omarchy-bar`, `omarchy-toggle-bar`, `omarchy-shell-config`; reload with `omarchy-refresh-shell`.
- **`shell.json` is rewritten in place by those tools** — same hazard as the btop quirk, except here it writes *through the symlink into this repo*. That is intentional (changes get tracked), but expect `git status` churn after using the bar's settings UI. It is mode `0600`; preserve that.
- `waybar/` and `omarchy-themes/` were **retired to `dumpyard/`** — waybar is uninstalled, and the dayfox theme is in the retired per-app format (Omarchy 4 themes are `colors.toml` + `shell.lock.toml` + `neovim.lua`).
- The 4 VPN toggle scripts were salvaged to **`omarchy-overrides/.config/bin/`**, already on `PATH`. They work as CLI toggles; only their waybar-JSON status mode (the `*)` case) has no consumer now.

### `opencode/` package layout is still broken

`~/.config/opencode` is a hand-made symlink to the **package root** (`configfiles/opencode`), not the stow-standard `opencode/.config/opencode`. So:

- Live config is the **untracked** `opencode/{opencode.json,tui.json,plugins/,skills/}` at the package root.
- The three git-tracked files under `opencode/.config/opencode/` are shadowed and effectively dead.
- `stow opencode` would unlink the working setup and pollute `$HOME` — see Critical Anti-Patterns. **`bootstrap.sh` is therefore unsafe to run wholesale**; stow packages individually by name until this is reconciled.

## Notable Quirks

- btop: `save_config_on_exit = False` is set in the tracked config to stop btop from rewriting the file on exit (older btop versions also silently strip newer fields they don't understand — e.g. v1.3.0 drops `gpu0` from `shown_boxes` if the host has no detected GPU). **Don't change settings in btop's UI expecting them to persist** — edit `btop/.config/btop/btop.conf` directly.
- LazyVim has `omarchy-theme-hotreload.lua` reloading colorschemes via `User LazyReload`.
- `KEYBINDINGS.md` (repo root) is the authoritative keybind hierarchy doc; `omarchy-overrides/.config/bin/keybind-audit` regenerates the cross-program audit on demand.
- Remote GUI from uburemote uses **xpra** (not VNC/x2go/NoMachine). Aliases `xrun`/`xrejoin`/`xls`/`xstop` in `bash-omarchy/.bashrc` target display `:100` on the `quompt` host. SSH X11 forwarding is opt-in on that Host block only — see `ssh/.ssh/config`. Server deps install via `scripts/deps_install.sh`; clients install `xpra` + (macOS) XQuartz manually.
