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
| `omarchy` | 32 — full set incl. `omarchy-*` and Wayland stack | Omarchy workstations (omarchy-tp) |
| `macair` | 20 — cross-platform core + `wezterm` + `zsh` | macOS Air |

```bash
./scripts/bootstrap.sh <profile> --list      # show what would be stowed
./scripts/bootstrap.sh <profile> --dry-run   # preview without changes
./scripts/bootstrap.sh <profile>             # actually stow
```

On a fresh box, run `stow stow` once manually before `bootstrap.sh` — that seeds `~/.stowrc` with the right `--target` and ignore patterns. `scripts/deps_install.sh` is the companion runtime-deps installer (apt+snap fallback, also handles xpra server bits for uburemote).

`scripts/` itself is **not a stow package** — it holds utility scripts run directly. Same goes for `dumpyard/` (archived configs) and **`syshardening/`** (see below).

**`syshardening/` is not a stow package either** — its files belong in `/etc/`, which stow cannot reach (`.stowrc` targets `$HOME`). It mirrors `syshardening/etc/**` and installs with `sudo ./syshardening/install.sh` (`--dry-run`, `--uninstall` supported). Every file it installs is a discrete drop-in that *overrides* an Omarchy/distro default rather than editing it; remove one file to undo one change. `syshardening/PLAN.md` is the full root-cause investigation into the recurring system freezes — read it before touching any of those drop-ins.

## Critical Anti-Patterns

- **Never edit `/usr/share/omarchy/default/`** — Omarchy 4 ships this as a root-owned pacman package; updates overwrite it. User overrides go in `~/.config/<app>/` (i.e. this repo's package). `~/.local/share/omarchy` is now just a compat **symlink** to `/usr/share/omarchy`, so old docs/scripts referencing it still resolve.
- **`opencode/` is an empty placeholder** — tracked config was removed in commit `4fb4537` ("to be ported on later"), but `opencode` is still in **all three** profile arrays. `stow opencode` / `bootstrap.sh` no-op on it; `~/.config/opencode` is now a plain unmanaged directory. Don't re-add config without first deciding the layout. See Notable Quirks.
- **Treat `tmux/.config/tmux/tmux.conf` as Omarchy-managed** — it's byte-identical to Omarchy's shipped `/usr/share/omarchy/config/tmux/tmux.conf`. Add user customizations to `tmux/.config/tmux/tmux.user.conf` instead (sourced from `tmux.conf` at the bottom). The upstream `omarchy-refresh-tmux` command is shimmed/blocked by `omarchy-overrides/` — see `KEYBINDINGS.md` §6. **That shim depends on `~/.config/bin` preceding `/usr/share/omarchy/bin` on `PATH`.** It had silently stopped working: the `environment.d` prepend is read by the systemd user manager and never reached interactive shells, so `omarchy-refresh-tmux` resolved to the upstream command and `membuild` was unreachable. `bash-omarchy/.bashrc` now prepends the directory itself. Verify with `command -v omarchy-refresh-tmux` in a **fresh** terminal — it must resolve under `~/.config/bin`.
- **Never stow from a linked git worktree** — only the primary at
  `~/Work/projects/quomptrade/configfiles` may be stowed. `~/.stowrc` and every live
  `$HOME` symlink hold absolute paths into it, so `stow` from a parallel-agent lane
  repoints your desktop at that lane and deleting the lane then breaks bash, Hyprland
  and the terminal. Enforced by `require_primary_worktree()` in `scripts/bootstrap.sh`
  **and** the `PreToolUse` hook `claudecode/.claude/hooks/stow-guard.sh`. See the
  "Parallel worktrees" section of `AGENTS.md`.
- **Never stow `dumpyard/`** — archived configs (i3, AstroNvim, old zsh/bash, retired oh-my-tmux conf.local), not meant for linking.
- **Never commit** `lazy-lock.json`, `credentials.txt`, `antigravity-accounts.json`, `.credentials.json` (most are gitignored; verify). Runtime state is also already ignored: `herdr/.config/herdr/*.{log,sock,...}`, `voxtype/.local/` + Whisper models, and `omarchy-shell`'s Omarchy-generated `~/.config/omarchy` subdirs — see `.gitignore`.
- **Never re-add `lazyvim/nvim/.config/nvim/lua/plugins/theme.lua` to git** — it is an
  absolute, machine-specific symlink into `~/.local/state/omarchy/`, deliberately
  gitignored. See Notable Quirks.

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

Only Hyprland moved to Lua — **alacritty, foot, ghostty, and kitty still use plain `source`/`include`** and are unaffected.

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
- **INI (foot)**: Omarchy-vendored baseline — keep deviations minimal and documented. `include=` needs an absolute or `~/` path; last value wins.
- **TOML (alacritty, herdr, `omarchy-shell`'s `shell.toml`)**: standard TOML. `omarchy-shell`'s `shell.json` is tool-managed (`omarchy-shell-config`), never hand-edited.
- **Shell (scripts/, setup/)**: `#!/usr/bin/env bash`, `snake_case` funcs, quote vars.

## Machine-Specific Files

These differ per workstation and require care when editing:

- `omarchy-hyprland/.config/hypr/monitors.lua` — display layout (the `.conf` sibling is legacy and no longer read)
- `setup/.config/cocoEd.sh` — `#!/bin/sh` alias/env script (`work`/`projects`/`learn`/… dirs). Unified on `~/Work` across all hosts since commit `6908581` (2026-05-18); the old `hostname`-based Mac/Linux path switch is gone. The retired fish counterpart now lives at `dumpyard/cocoEd-fish.sh`.
- `ssh/.ssh/config` — IPs/hostnames (ported live → repo on Omarchy in commit `c8aed1b`; Mac Air sync requires manual merge against this baseline)
- **`bash-omarchy` vs `bash-ubuntu` vs `zsh`** — mutually exclusive shell packages. `bash-omarchy` covers Arch + macOS-via-bash (sources `~/.local/share/omarchy/default/bash/rc` — still correct under Omarchy 4, since that path is a compat symlink to `/usr/share/omarchy`; guarded so it's harmless elsewhere). `bash-ubuntu` is for the Ubuntu remote (`/etc/skel`-derived prompt, same toolchain init block). `zsh` is the macOS-via-zsh package (oh-my-zsh + Mac Homebrew paths). Pick one per host. xpra helpers (`xrun`/`xrejoin`/`xls`/`xstop`) and the `quompt` alias live in `bash-omarchy` and `zsh` — the client packages — but not in `bash-ubuntu`, since uburemote *is* the xpra server.

## Omarchy 4 Migration (completed 2026-08-22)

The quattro upgrade landed on 2026-08-21 and the repo was brought in sync the next day. What changed:

### Hyprland is Lua-only

`omarchy-hyprland/.config/hypr/` holds **six `.lua` files** (`hyprland`, `monitors`, `input`, `bindings`, `looknfeel`, `autostart`) plus `.luarc.json`. All the `source`-based `.conf` files were deleted — they are recoverable from git history if ever needed.

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

- **The `omarchy-shell/` package covers all of `~/.config/omarchy`, not just the bar** (since commit `7fea592`, 2026-08-30). Seven curated files are linked **per file**: `shell.json`, `shell.toml`, `branding/{about,screensaver}.txt`, `extensions/{menu.sh,omarchy-menu.jsonc}`, `hooks/post-update.d/setup-agent.hook`. Everything else in that directory is Omarchy-generated state (`defaults/`, `backgrounds/`, `themed/`, `*.sample`, `*.bak.*`) and is gitignored. Bar config is driven by `omarchy-bar`, `omarchy-toggle-bar`, `omarchy-shell-config`; reload with `omarchy-refresh-shell`.
- **Never let `~/.config/omarchy` become a single symlink.** Per-file linking keeps it a real directory so Omarchy keeps writing its state there instead of into this repo. If a future copy/adopt drags the whole tree in, back it out.
- **`shell.json` is rewritten in place by the bar tools** — same hazard as the btop quirk, except here it writes *through the symlink into this repo*. That is intentional (changes get tracked), but expect `git status` churn after using the bar's settings UI. It is mode `0600`; preserve that.
- **`omarchy refresh shell` breaks these symlinks** — it backs up and replaces the file, leaving a real file plus `shell.json.bak.<epoch>` in `~/.config/omarchy`. This is exactly how the box ended up unstowed before 2026-08-30. After any `omarchy refresh`, re-link with `stow -n -v --adopt omarchy-shell` (dry-run) then `stow --adopt omarchy-shell`, and check `git diff` to see whether the refresh reverted your settings.
- `waybar/` and `omarchy-themes/` were **retired to `dumpyard/`** — waybar is uninstalled, and the dayfox theme is in the retired per-app format (Omarchy 4 themes are `colors.toml` + `shell.lock.toml` + `neovim.lua`).
- The 4 VPN toggle scripts were salvaged to **`omarchy-overrides/.config/bin/`**, already on `PATH`. They work as CLI toggles; only their waybar-JSON status mode (the `*)` case) has no consumer now.

### `opencode/` package is empty, pending a re-port

The old hand-made `~/.config/opencode` → package-root symlink and its tracked
config were removed in commit `4fb4537` ("to be ported on later"). Current state:

- `git ls-files opencode/` returns **nothing** — the package is an empty
  placeholder still listed in all three profile arrays.
- `~/.config/opencode` is now a plain directory holding live, **unmanaged**
  config (`opencode.jsonc`, `tui.json`, `plugins/`, `node_modules/`).
- `stow opencode` and `bootstrap.sh <profile>` both no-op on it. The earlier
  "running bootstrap unlinks the working opencode setup" hazard no longer applies.
- Any re-port must first pick a layout — stow-standard `opencode/.config/opencode/`
  or the old package-root symlink — and update `.gitignore` accordingly.

## Notable Quirks

- btop: `save_config_on_exit = False` is set in the tracked config to stop btop from rewriting the file on exit (older btop versions also silently strip newer fields they don't understand — e.g. v1.3.0 drops `gpu0` from `shown_boxes` if the host has no detected GPU). **Don't change settings in btop's UI expecting them to persist** — edit `btop/.config/btop/btop.conf` directly.
- **Neovim's colorscheme is owned by Omarchy, not this repo.**
  `lazyvim/nvim/.config/nvim/lua/plugins/theme.lua` must be an **absolute symlink** to
  `~/.local/state/omarchy/current/theme/neovim.lua`. `omarchy theme set` restages that
  target; lazy.nvim's reloader polls every 2s with `fs_stat` (which follows symlinks)
  and fires `User LazyReload`, which `omarchy-theme-hotreload.lua` turns into a live
  colorscheme swap plus a re-source of `plugin/after/transparency.lua`.
  - The file is **gitignored** — it is machine state, and a relative link would resolve
    against the repo rather than `$HOME` (`~/.config/nvim/lua` is one stow symlink to
    the package dir, so the physical file lives in `lazyvim/`).
  - Recreate it on a fresh Omarchy box with `scripts/link_omarchy_nvim_theme.sh`;
    `scripts/bootstrap.sh omarchy` runs it automatically after stowing. It is a no-op
    on hosts without `~/.local/state/omarchy`.
  - Replacing it with a regular file silently breaks theme switching *and* is invisible
    to Omarchy's own repair migrations (`1781158082.sh`, `1785002349.sh`), which both
    start with `[[ -L $theme_link ]] || exit 0`.
  - `nvim --headless` disables lazy's change detection entirely, so hot-reload cannot
    be verified headlessly — only cold start can.
- `KEYBINDINGS.md` (repo root) is the authoritative keybind hierarchy doc; `omarchy-overrides/.config/bin/keybind-audit` regenerates the cross-program audit on demand.
- **`foot/`** — foot is the default terminal on omarchy-tp since 2026-09-01, selected by
  `foot/.config/xdg-terminals.list` (`foot.desktop`), which is what `xdg-terminal-exec`
  reads for `SUPER + RETURN` and the tmux launchers in `bindings.lua`. Switching terminals
  via the Omarchy menu now surfaces as a repo diff.
  - `foot/.config/foot/foot.ini` began as a byte-for-byte copy of Omarchy's shipped
    `/usr/share/omarchy/config/foot/foot.ini` and deviates by **exactly one line**, the
    `font=`. That makes `diff -u /usr/share/omarchy/config/foot/foot.ini ~/.config/foot/foot.ini`
    a cheap drift check after an Omarchy update.
  - **The font is kept in lockstep with ghostty**: `font=CaskaydiaMono Nerd Font:size=9:weight=semibold`
    is the fontconfig spelling of ghostty's `font-family` + `font-style = Semi Bold` +
    `font-size = 9`. Change one, change the other. Don't add `font-bold`/`font-italic` —
    ghostty derives those from the regular face too, and adding them would make the two diverge.
  - Colors come from the untouched `include=~/.local/state/omarchy/current/theme/foot.ini`;
    `omarchy-theme-set-foot` repaints *running* instances over OSC. Neither touches the font.
    Reload config without closing windows: `pkill -USR1 foot`.
  - **`omarchy-refresh-config foot/foot.ini` writes through the stow symlink into this repo.**
    Unlike `omarchy refresh shell`, it does a plain `cp -f` onto `~/.config/foot/foot.ini`, so
    the symlink survives but the tracked file is replaced by the Omarchy default — recover with
    `git checkout -- foot/`. There is no `omarchy-refresh-foot`, so this only fires when invoked
    explicitly; no shim is needed.
- **Parallel agent worktrees** — lanes live under a global root,
  `~/Work/worktrees/<Repo>/wt-<lane>`, created with `gwq add -b wt/<lane>`
  (`gwq` is pinned in mise; its config is the `gwq/` package). `gwq list -g` is the
  cross-repo dashboard and `gwq cd` is an fzf jump that works in herdr, tmux and a
  bare terminal alike — **herdr has no `tmux-sessionx` equivalent**, which is why
  both tools are present. Lanes are edit-and-commit only; see the stow rule above.
  - **quant-research is a pinned exception** and must keep its worktrees nested
    inside `./pqr` and `./platform`: `docker-compose.yml` mounts those directories,
    and `pqr/platform` is a symlink to the container-absolute
    `/quant-research/platform/research00`. Moving them breaks the build.
  - `worktree.baseRef` is set to `head` in `claudecode/.claude/settings.json`.
    Claude's native `EnterWorktree` defaults to branching from
    `origin/<default-branch>`, and this repo's `origin/HEAD` tracked `master` while
    all work is on `main` — 123 commits ahead. `origin/HEAD` now points at `main`.
- **`herdr/`** — Omarchy 4's terminal workspace manager (tmux replacement), launched by `SUPER + CTRL + RETURN`. `herdr/.config/herdr/config.toml` is hand-tuned to **mirror the tmux keymap** (same `ctrl+space` prefix, same pane/tab/workspace chords), so it occupies tmux's layer in `KEYBINDINGS.md` §2 — **any tmux keymap change must be mirrored into `config.toml`** or the two drift. Its one deliberate divergence: `rename_pane = "prefix+shift+o"` (stock `prefix+shift+p` collides with previous-workspace). Only `config.toml` is tracked; logs/sockets/session state gitignored.
- **`voxtype/`** — dictation daemon (`voxtype-bin`, AUR). Only `voxtype/.config/voxtype/config.toml` is tracked. **The hotkey is not in that file** (`[hotkey] enabled = false`) — the real bindings live in Hyprland (`SUPER+CTRL+X` toggle, `F9` push-to-talk) and only signal an already-running daemon. If a binding "does nothing", check `systemctl --user status voxtype` first — it runs as a user service (`~/.config/systemd/user/voxtype.service`, installed by `omarchy-voxtype-install`, not tracked). Whisper models live in `~/.local/share/voxtype/models/` (per-machine download, gitignored). `omarchy-voxtype-status` (= `voxtype status --follow`) streams forever — never invoke it non-interactively.
- **`mise/.config/mise/config.toml`** pins the CLI agent toolchain (`agy`, `claude`, `codex`, `crush`, `gh`, `npm:@xai-official/grok`, `opencode`) plus language runtimes (go/node/python/ruby/zig/zls/conan). Stowed on all three profiles as of commit `8711d55`; `gemini` was retired.
- **Recurring system freezes are under active investigation** — see `syshardening/PLAN.md`. Leading finding: of 18 classified boots, **9 of 9 that used s2idle suspend ended abruptly; 0 of 8 that never suspended did**, and 8 of the 9 followed a `upowerd` critical-battery suspend (`PercentageAction=2.0`, `CriticalPowerAction=Auto` degrading to Suspend because hibernation isn't configured). Secondary: the Goodix fingerprint reader (`27c6:659a`, `usb 3-6`) sits in a USB reset loop — 851 resets in one crash boot vs 4–12 in clean ones. Memory/zram pressure was the original hypothesis and is **not** supported (the one confirmed pressure event ended in a clean shutdown).
- **`membuild`** (`omarchy-overrides/.config/bin/`) wraps a build in a `systemd-run` scope with `MemoryHigh=5G`/`MemoryMax=7G` in `build.slice`, so a runaway compile or LTO link is OOM-killed in its own cgroup instead of thrashing the desktop. Override with `MEMBUILD_HIGH`/`MEMBUILD_MAX`. Needs `~/.config/bin` on `PATH` (via `environment.d`, so re-login after first stow).
- Remote GUI from uburemote uses **xpra** (not VNC/x2go/NoMachine). Aliases `xrun`/`xrejoin`/`xls`/`xstop` in `bash-omarchy/.bashrc` and `zsh/.zshrc` target display `:100` on the **`quomptblr`** host (the `quompt` alias was dropped from `ssh/.ssh/config`; the shell alias keeps the short name but now ssh's to `quomptblr`). xpra tunnels over SSH and needs no X11 forwarding — `ForwardX11` is commented out in that Host block because it does not work over tailscale. Server deps install via `scripts/deps_install.sh`; clients install `xpra` + (macOS) XQuartz manually.
