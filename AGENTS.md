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
| `omarchy` | 32 — full set incl. Wayland stack | Omarchy ThinkPad (omarchy-tp) |
| `macair` | 20 — cross-platform + `wezterm` + `zsh` | macOS Air |

`scripts/`, `dumpyard/` and `syshardening/` are NOT stow packages.

`syshardening/` holds `/etc` drop-ins (stow targets `$HOME`, so it can't place them). Install with `sudo ./syshardening/install.sh` (`--dry-run` / `--uninstall`). `syshardening/PLAN.md` is the root-cause investigation into the recurring system freezes — leading finding is **s2idle suspend**, specifically UPower's critical-battery action: 9 of 9 boots that suspended ended abruptly, 0 of 8 that never suspended did. Memory/zram pressure was the original hypothesis and is not supported.

## Stow Conventions

Standard layout: `pkg/.config/app/file  →  ~/.config/app/file`
Home dotfiles:   `pkg/.file           →  ~/.file`
Non-standard:    `vimium/` and `vpn/` place files at the package root.

**Always dry-run first**: `stow -n -v <pkg>` before linking.

**`lazyvim` needs a special invocation** due to intentional extra `nvim/` nesting:
```
stow -d <repo>/lazyvim nvim
```

## Omarchy 4 Layer Hierarchy

Host runs Omarchy `4.0.0.alpha` ("quattro"). Precedence:

1. `/usr/share/omarchy/default/` — **DO NOT EDIT** (root-owned pacman package, overwritten on update). `~/.local/share/omarchy` is a compat symlink to it.
2. `~/.local/state/omarchy/current/theme/` — managed by theme system (**moved** from `~/.config/omarchy/current/`)
3. `~/.config/<app>/` — user overrides (this repo)

**Hyprland is configured in Lua now**, not `.conf` — verify with `hyprctl systeminfo | grep -i configprovider` → `configProvider: lua`. Entry point `omarchy-hyprland/.config/hypr/hyprland.lua` does `dofile(bootstrap.lua)` → `require("default.hypr.omarchy")` → `require("hypr.{monitors,input,bindings,looknfeel,autostart}")` → `require("default.hypr.toggles")`. **Require order matters — do not reorder.** `bootstrap.lua` sets `package.path` to `~/.local/state/?.lua;~/.config/?.lua;$OMARCHY_PATH/?.lua`.

Alacritty, foot, ghostty, and kitty still use plain `source`/`include` — only hypr moved.

**The port to Lua is complete** (2026-08-22). All `source`-based `.conf` files were deleted; five `.lua` modules remain. Only genuine deviations from Omarchy's defaults belong there — 23 of the original 27 `bindd` lines were dropped because Omarchy 4 ships them verbatim, and re-adding one would double-bind it. Check `grep -n 'o\.bind' /usr/share/omarchy/default/hypr/bindings/*.lua` before adding (note: some lines read `o.bind( "KEY"` with a space, which a naive grep misses). `hyprctl binds` is ground truth. Still-live `.conf` files (separate daemons): `hypridle.conf`, `hyprlock.conf`, `hyprsunset.conf`, `xdph.conf`.

## Parallel worktrees

Multiple agent CLIs edit this repo in parallel via git worktrees. **One rule matters more than all the others: only the PRIMARY worktree may ever be stowed.**

```
~/Work/
├── worktrees/                      ← global root (gwq worktree.basedir)
│   └── ConfigFiles/wt-<lane>/        branch wt/<lane>
├── projects/quomptrade/configfiles/  ← PRIMARY, branch main, the ONLY stowable tree
└── learn/quant-research/           ← PINNED EXCEPTION — do not relocate
    ├── pqr/reseachr00/
    └── platform/research00/
```

**Why the primary is special.** `~/.stowrc` is itself a symlink into it and sets `--target=$HOME`, and every live symlink (`~/.bashrc`, `~/.config/hypr`, `~/.config/foot/foot.ini`) holds an *absolute* path into it. Stowing from a lane repoints `$HOME` at that lane; deleting the lane then breaks the shell, Hyprland and the terminal. `stow --adopt` from a lane is worse — it pulls live files in, silently reverting tracked config.

**Enforced in two layers**, not just documented — a Claude-only guard would miss opencode/codex/crush and hand-typed commands:

1. `scripts/bootstrap.sh` → `require_primary_worktree()`, covers every harness.
2. `claudecode/.claude/hooks/stow-guard.sh` → `PreToolUse` hook, also catches bare `stow`.

Both use the same path-independent test — true only in the primary:

```sh
[ "$(git rev-parse --absolute-git-dir)" = "$(realpath "$(git rev-parse --git-common-dir)")" ]
```

The hook is registered in the **global** `~/.claude/settings.json`, so it deliberately no-ops unless cwd is a linked worktree of a repo containing `stow/.stowrc` — it must never interfere with `pqr`, `platform` or anything else. Note the bootstrap guard only protects lanes created *after* it was committed, since a lane checks out a commit.

**The quant-research exception is load-bearing, not laziness.** `docker-compose.yml` mounts `./pqr` and `./platform`; those worktrees are nested *inside* the mounts, which is the only reason they reach the container. And `pqr/platform` is a root-owned symlink to `/quant-research/platform/research00` — a container-absolute path that does not exist on the host. Relocating them breaks the mount and PQR's `../platform` resolution. General rule: **the build system's view of the filesystem outranks the filing convention.**

**Tools.** `gwq` (pinned in mise, config in the `gwq/` package) creates lanes and gives `gwq list -g`, a cross-repo dashboard. Its fzf picker is multiplexer-agnostic, which is why it's here alongside `tmux-sessionx` — sessionx is tmux-only and **herdr has no equivalent** (its `config.toml` is keymap/theme/UI only). No new chords, so `KEYBINDINGS.md` is unaffected.

```bash
gwq add -b wt/agent-a          # lane at ~/Work/worktrees/ConfigFiles/wt-agent-a
gwq list -g                    # every lane, every repo
gwq cd                         # fzf jump — herdr, tmux, or bare terminal
git worktree remove <path> && git branch -d wt/agent-a
```

Lanes are **edit-and-commit only**: commit on `wt/<lane>`, merge into `main`, then stow from the primary. Two worktrees cannot check out the same branch, which is the built-in guard against two agents committing to `main`.

**`worktree.baseRef` is set to `head`** in `claudecode/.claude/settings.json`. Claude's native `EnterWorktree` defaults to `fresh` = branch from `origin/<default-branch>`; this repo's `origin/HEAD` tracked `master` while all work is on `main` (123 commits ahead), so `fresh` silently branched from a stale tree. `origin/HEAD` has since been repointed at `main`.

## Anti-Patterns

- **DO NOT** edit `/usr/share/omarchy/default/` — updates clobber it (`~/.local/share/omarchy` is a compat symlink to it)
- **DO NOT** run `stow opencode` or `bootstrap.sh` on this box yet — `~/.config/opencode` is a hand-made symlink to the *package root*, so the live config is the untracked `opencode/{opencode.json,tui.json,plugins/,skills/}` and the tracked `opencode/.config/opencode/` files are shadowed. `stow -n -v opencode` shows it would UNLINK the working link and litter `$HOME` with `node_modules`, `opencode.json`, `package.json`. `opencode` is in all three profiles
- **DO NOT** modify `tmux/.config/tmux/tmux.conf` — it's Omarchy-vendored. Add customizations to `tmux/.config/tmux/tmux.user.conf` instead (sourced from `tmux.conf`). The upstream `omarchy-refresh-tmux` is shimmed/blocked by `omarchy-overrides/`
- **DO NOT** stow `dumpyard/` — archived configs (i3, AstroNvim, old shell configs), not for linking
- **DO NOT** commit: `credentials.txt`, `lazy-lock.json`, `antigravity-accounts.json`, `.credentials.json` (most are gitignored)
- **NEVER** stow without dry-run (`stow -n -v`) first

## Shell Packages (Mutually Exclusive)

| Package | Hosts |
|---------|-------|
| `bash-omarchy` | Omarchy (Arch) + macOS when using bash (sources `~/.local/share/omarchy/default/bash/rc` — still resolves via the Omarchy 4 compat symlink; guarded) |
| `bash-ubuntu` | Ubuntu remote (`/etc/skel`-derived, same toolchain init) |
| `zsh` | macOS oh-my-zsh |

Pick **one** per host. xpra helpers (`xrun`/`xrejoin`/`xls`/`xstop`) live in the client packages (`bash-omarchy`, `zsh`), not in `bash-ubuntu` (uburemote is the xpra server).

## Config Quirks

- **btop**: `save_config_on_exit = false` — edits via the UI won't persist; edit `btop/.config/btop/btop.conf` directly
- **Hyprland bindings**: `o.bind("SUPER + SHIFT + R", "Description", "cmd")`; `hl.unbind(...)` before replacing a default; `hl.monitor({...})`, `hl.env(...)`, `o.window(...)`. Kill-switches `omarchy_default_bindings = false` / `omarchy_preinstalled_bindings = false` go in `hyprland.lua` *before* `require("default.hypr.omarchy")`. The old `bindd =` syntax is dead
- **Monitors**: `monitors.lua` matches by `desc:` not `DP-N` (port numbers shuffle across dock/replug), pins workspaces 1/2/3 to left BenQ / middle BenQ / laptop, and runs both BenQs at **75Hz** — the Omarchy-generated template had silently dropped them to 60
- **Hypr Lua tooling**: `omarchy-hyprland/.config/hypr/.luarc.json` points lua-ls at `/usr/share/hypr/stubs` and declares globals `hl`, `o`
- **herdr**: Omarchy 4's terminal workspace manager (tmux replacement), bound to `SUPER + CTRL + RETURN`. Its `herdr/.config/herdr/config.toml` is hand-tuned to mirror the tmux setup — same `ctrl+space` prefix, same pane/tab/workspace chords — so it shares tmux's conflict surface. Only `config.toml` is tracked; logs, sockets, and session state are gitignored
- **voxtype** (dictation, `voxtype-bin` from AUR): only `voxtype/.config/voxtype/config.toml` is tracked. The **hotkey is not in that file** -- `[hotkey] enabled = false` there, and the real bindings live in Hyprland (`SUPER+CTRL+X` toggle, `F9` push-to-talk). It runs as a **user service**, `~/.config/systemd/user/voxtype.service` (installed by `omarchy-voxtype-install`, not tracked); if a keybinding "does nothing", check `systemctl --user status voxtype` first -- the binding only signals a running daemon. Whisper models live in `~/.local/share/voxtype/models/` (~1.7 GB, per-machine download, gitignored). Note `omarchy-voxtype-status` is `voxtype status --follow` and streams forever -- do not call it non-interactively
- **foot** is the default terminal on omarchy-tp (2026-09-01). `foot/.config/foot/foot.ini` started as a byte-for-byte copy of Omarchy's shipped `/usr/share/omarchy/config/foot/foot.ini` and deviates by **exactly one line** — the `font=` — so `diff -u /usr/share/omarchy/config/foot/foot.ini ~/.config/foot/foot.ini` is a cheap drift check after an Omarchy update. Font mirrors ghostty: `CaskaydiaMono Nerd Font:size=9:weight=semibold` ≡ ghostty's `font-family`/`font-style = Semi Bold`/`font-size = 9`; keep the two in sync and do **not** add `font-bold`/`font-italic` (ghostty derives those too). Colors come from the untouched `include=~/.local/state/omarchy/current/theme/foot.ini`, and `omarchy-theme-set-foot` repaints running instances over OSC — neither touches the font. Reload without closing windows: `pkill -USR1 foot`
- **`omarchy-refresh-config foot/foot.ini` writes through the stow symlink into this repo.** Unlike `omarchy refresh shell` it does a plain `cp -f` onto `~/.config/foot/foot.ini`, so the symlink survives but the tracked file is replaced by the Omarchy default — recover with `git checkout -- foot/`. There is no `omarchy-refresh-foot`, so this only fires if invoked explicitly; no shim needed
- **`foot/.config/xdg-terminals.list`** is what actually selects the default terminal for `xdg-terminal-exec` (hence `SUPER + RETURN` and the tmux launchers in `bindings.lua`). It ships in the `foot` package, so switching terminals via the Omarchy menu now shows up as a repo diff
- **Keybindings**: `KEYBINDINGS.md` is the authoritative hierarchy doc; `omarchy-overrides/.config/bin/keybind-audit` regenerates the cross-program audit
- **Remote GUI**: xpra on `:100` — helpers `xrun`/`xrejoin`/`xls`/`xstop` in `bash-omarchy/.bashrc` (also `zsh`)
- **waybar is retired**: Omarchy 4 replaced it with **quickshell** (`quickshell -n -p /usr/share/omarchy/shell`, started by `omarchy-launch-shell`). `waybar/` and `omarchy-themes/` moved to `dumpyard/`. Bar config is now the **`omarchy-shell/`** package (via `omarchy-bar` / `omarchy-toggle-bar` / `omarchy-shell-config`, reload `omarchy-refresh-shell`). Those tools rewrite `shell.json` **through the symlink into this repo** — expect `git status` churn after using the bar's settings UI; it is mode `0600`
- **`omarchy-shell/` covers all of `~/.config/omarchy`, not just the bar** (2026-08-30). Seven curated files are linked: `shell.json`, `shell.toml`, `branding/{about,screensaver}.txt`, `extensions/{menu.sh,omarchy-menu.jsonc}`, `hooks/post-update.d/setup-agent.hook`. Everything else in that directory is Omarchy-generated state — `defaults/agent`, `backgrounds/*` theme symlinks, `themed/`, `*.sample`, `*.bak.*` — and is gitignored. Stow links **per file**, so `~/.config/omarchy` stays a real directory and Omarchy keeps writing its state there rather than into this repo. Keep it that way: never let the whole directory become one symlink
- **`omarchy refresh shell` breaks these symlinks.** It backs up and replaces the file, leaving a real file plus a `shell.json.bak.<epoch>` in `~/.config/omarchy` — that is exactly how this box ended up unstowed before 2026-08-30. After any `omarchy refresh`, re-link with `stow -n -v --adopt omarchy-shell` (dry-run) then `stow --adopt omarchy-shell`, and check `git diff` to see whether the refresh reverted your settings
- **VPN scripts**: salvaged from the retired waybar package into `omarchy-overrides/.config/bin/` (already on `PATH`). They still work as CLI toggles; only their waybar-JSON status mode has no consumer now

## File Formats

| Format | Packages | Style |
|--------|----------|-------|
| Lua | lazyvim | 2 spaces, 120 cols, `stylua` formatter |
| Lua | omarchy-hyprland | 2 spaces; keep Omarchy's commented template examples as inline docs |
| .conf | omarchy-hyprland (daemons only: hypridle, hyprlock, hyprsunset, xdph) | `#` comments, wiki links |
| TOML | alacritty, herdr, omarchy shell (`shell.toml`) | Standard TOML |
| INI | foot (`foot.ini`) | Omarchy-vendored baseline; `include=` needs an absolute or `~/` path, last value wins |
| JSON | omarchy shell (`shell.json`) | managed via `omarchy-shell-config`, not hand-edited |
| Shell | scripts, setup | `#!/usr/bin/env bash`, `snake_case` funcs, quote vars |

## Commit Convention

```
[package|package] description
```

Examples: `[lazyvim|ssh] comment out ai plugins`, `[hypr] retire .conf for .lua`
