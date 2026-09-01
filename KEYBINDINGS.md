# Keybinding hierarchy

Single source of truth for the keybinding leader hierarchy across the Configs/Utils. When adding a new tool/binding, follow the rules in [§5](#5-rules-for-adding-a-new-toolbinding) and update the [§3 conflict matrix](#3-conflict-matrix) if the change touches a chord that's already claimed.

## 1. Why this exists

Each program in the stack ships with its own bindings, and several of them — Hyprland, the terminal (foot/Ghostty), tmux, Neovim, lazygit, lazydocker — can each technically claim any chord. Without an agreed hierarchy, it's easy to bind something that silently shadows another layer. This file documents the layered design that's currently in place (audited 2026-05-05, **zero MED/HIGH conflicts**) and the rules that keep it that way.

A separate audit aggregator lives at [`omarchy-overrides/.config/bin/keybind-audit`](omarchy-overrides/.config/bin/keybind-audit) — run it any time the stack changes to re-inventory.

## 2. Leader hierarchy

```
Layer 0  Hyprland (WM)        →  SUPER family + ALT+TAB                 (outermost)
Layer 1  foot / Ghostty (term) →  transparent except 4 minor binds
Layer 2  tmux (multiplexer)   →  prefix=C-Space + unprefixed M-* / C-M-*
     2'  herdr (workspace mgr)→  same prefix=C-Space, by design (tmux replacement)
Layer 3  Neovim (LazyVim)     →  Space leader + standard vim chords
Layer 4  TUI apps (lazygit,   →  single letters, in-pane only           (innermost)
         lazydocker, ...)
```

**tmux and herdr occupy the same layer slot and never run inside one another** — herdr is
Omarchy 4's tmux replacement, and `herdr/.config/herdr/config.toml` deliberately mirrors the
tmux keymap (`prefix = "ctrl+space"`, `prefix+c/r/k` tabs, `alt+1..9`, `alt+arrows`,
`ctrl+alt+arrows` pane focus). That is a feature: whichever one is running, the chords are the
same. It also means **any change to the tmux rows below must be mirrored into herdr's
`config.toml`**, or the two drift apart.

**foot and Ghostty likewise share Layer 1 and claim identical chords.** foot is the default
terminal on omarchy-tp (see `foot/.config/xdg-terminals.list`); its `[key-bindings]`
`clipboard-copy`/`clipboard-paste` and its `[text-bindings]` CSI-u escapes
(`\x1b[13;2u` = `Shift+Return`, `\x1b[13;4u` = `Alt+Shift+Return`) are the exact
counterparts of Ghostty's `keybind =` lines. The layer is unchanged whichever one is
running — but **a chord change in one must be mirrored into the other**, the same
discipline as tmux ↔ herdr. foot has no counterpart to Ghostty's
`SUPER+CTRL+SHIFT+ALT+arrows` split resize (it has no splits).

Rationale per layer:

- **Layer 0 — Hyprland** owns `SUPER+*` because SUPER is the only chord family the WM actually needs to listen to globally without conflicting with terminal apps. foot/Ghostty/tmux/nvim never bind SUPER.
- **Layer 1 — foot / Ghostty** is intentionally near-transparent. The four bindings Ghostty claims (`Shift+Insert`, `Ctrl+Insert`, and the deeply-nested `SUPER+CTRL+SHIFT+ALT+arrows` for split resize) are designed not to collide with anything inner. foot claims the same clipboard pair and the same CSI-u text-bindings, minus the split-resize chords.
- **Layer 2 — tmux** uses `C-Space` as the prefix (Omarchy's choice; replaces oh-my-tmux's older `C-a`). It also uses unprefixed `M-1..M-9` / `M-arrows` / `C-M-arrows` for fast pane/window/session navigation, plus `C-h/j/k/l` (cross-boundary nav via vim-tmux-navigator) and `M-h/j/k/l` (pane resize) — these all live in the ALT family which Hyprland deliberately leaves alone.
- **Layer 2' — herdr** mirrors tmux rather than competing with it. Its only deliberate divergence is `rename_pane = "prefix+shift+o"`, because herdr's stock `prefix+shift+p` collides with previous-workspace. Launch chord is `SUPER+CTRL+RETURN` (Omarchy 4 default).
- **Layer 3 — Neovim (LazyVim)** uses `Space` as the leader. Tmux's prefix is `C-Space`, not bare `Space`, so they don't collide. LazyVim's plugin bindings (e.g. `<leader>fp`) are scoped to vim modes only.
- **Layer 4 — TUI apps** like lazygit/lazydocker bind only single letters within their focused pane — they never claim any chord that an outer layer would intercept.

## 3. Conflict matrix

Audited 2026-05-05. Severity scale: **NONE** (no overlap), **LOW** (theoretical edge case, not practical), **MED** (practical collision in some context), **HIGH** (practical collision in normal use).

| Chord | Claimed by | Notes | Severity |
|---|---|---|---|
| `C-M-Left/Right/Up/Down` | tmux (pane select, unprefixed) | Neither foot nor Ghostty intercepts | NONE |
| `M-1`..`M-9` | tmux (window select, unprefixed) | Hyprland uses `SUPER+code:10..18` for workspaces, not `M-` | NONE |
| `M-Left/Right` | tmux (window prev/next) | No other layer binds `M-arrows` | NONE |
| `M-Up/Down` | tmux (session prev/next) | Same | NONE |
| `M-S-Left/Right` | tmux (window swap) | Same | NONE |
| `C-h/j/k/l` | tmux (vim-tmux-navigator) + Neovim (split nav) | Intentional shared chord; tmux's `is_vim` predicate routes the chord to nvim when nvim is the focused pane process | NONE |
| `M-h/j/k/l` | tmux (pane resize) + Neovim (split resize) | Same `is_vim` passthrough as above; replaces the old `C-M-S-arrows` resize binding | NONE |
| `C-Space` | tmux prefix | Hyprland uses `SUPER+SPACE` for walker — different chord | NONE |
| `C-b` | tmux secondary prefix | Theoretically conflicts with readline `back-char` inside copy-mode; in practice you switch to copy-mode intentionally | LOW |
| `Space` | LazyVim leader | Tmux prefix is `C-Space`, not `Space`. Neither foot nor Ghostty intercepts | NONE |
| `Shift+Insert` / `Ctrl+Insert` | foot + Ghostty (paste/copy) | Standard X11/Wayland clipboard chords; nothing else binds them. Both terminals bind them identically | NONE |
| `Shift+Return` / `Alt+Shift+Return` | foot + Ghostty (CSI-u `\x1b[13;2u` / `\x1b[13;4u`) | Emitted as escapes, not swallowed, so tmux and TUIs can tell them apart from plain `Return`. Identical in both terminals | NONE |
| `SUPER+CTRL+SHIFT+ALT+arrows` | Ghostty (split resize) | Deeply nested; impossible to type by accident. foot has no splits and does not bind these | NONE |
| `ALT+TAB` / `ALT+SHIFT+TAB` | Hyprland (window cycle) | tmux does not intercept ALT+TAB | NONE |
| `SUPER+SPACE` | Hyprland (walker) | Distinct from tmux's `C-Space` | NONE |
| `SUPER+letter`, `SUPER+SHIFT+letter`, `SUPER+CTRL+*` | Hyprland (workspace, window mgmt, system utils) | No other layer binds SUPER | NONE |
| `SUPER+CTRL+RETURN` | Hyprland → **herdr** (Omarchy 4 default) | Took over this chord in the quattro upgrade. The remote-tmux binding it displaced moved to `SUPER+CTRL+SHIFT+RETURN` | NONE |
| `SUPER+CTRL+SHIFT+RETURN` | Hyprland (Tmux remote — ssh `quomptblr`) | Relocated here rather than unbinding Herdr | NONE |
| `SUPER+ALT+RETURN` | Hyprland (Tmux, session `muxy-tp`, workspace 1) | Overrides Omarchy's generic terminal-tmux launch | NONE |
| `SUPER+SHIFT+W` / `SUPER+SHIFT+S` | Hyprland (Typora / Slack) | Override Omarchy 4 defaults (Omawrite / Google Maps); each `hl.unbind` first | NONE |
| herdr `prefix+shift+o` | herdr (rename pane) | Deliberate divergence from herdr's stock `prefix+shift+p`, which collides with previous-workspace | NONE |

**No MED or HIGH conflicts as of 2026-08-22** (re-verified after the Omarchy 4 upgrade and the Hyprland Lua port).

## 4. tmux plugin layer

The plugins loaded via [`tmux/.config/tmux/tmux.user.conf`](tmux/.config/tmux/tmux.user.conf) add the following bindings. All defaults verified non-conflicting with the matrix above:

| Plugin | Default binding | Action |
|---|---|---|
| `tmux-plugins/tmux-resurrect` | `prefix + Ctrl-s` | Save tmux environment |
| `tmux-plugins/tmux-resurrect` | `prefix + Ctrl-r` | Restore tmux environment |
| `tmux-plugins/tmux-continuum` | (none) | Background daemon — auto-saves every 15 min, auto-restores on tmux start (`@continuum-restore 'on'`) |
| `omerxx/tmux-sessionx` | `prefix + O` | fzf session picker |
| `tmux-plugins/tmux-logging` | `prefix + Shift+P` | Toggle logging current pane to file |
| `tmux-plugins/tmux-logging` | `prefix + Alt+P` | Screen-capture current pane |
| `tmux-plugins/tmux-logging` | `prefix + Alt+Shift+P` | Save complete pane history |
| `tmux-plugins/tmux-logging` | `prefix + Alt+c` | Clear pane history |
| `timvx/tmux-assistant-resurrect` | (in-picker only) | UI overlay on resurrect; bindings live inside the picker, no global tmux chord |
| `christoomey/vim-tmux-navigator` | unprefixed `C-h/j/k/l`, `C-\` | Cross-boundary pane/split nav (tmux ↔ nvim). Pairs with the `lua/plugins/vim-tmux-navigator.lua` half on the nvim side. |

Omarchy's tmux base only claims these prefixed letters: `c, C, h, k, K, m, P, N, q, r, R, v, x` — no overlap with any plugin default above.

## 5. Rules for adding a new tool/binding

When adopting a new tool that binds keys, or adding a new binding to an existing tool:

1. **Identify which layer the new binding belongs to.** Layer 0 = WM, Layer 4 = TUI apps. The deeper the layer, the more constrained the chord vocabulary.
2. **Pick a chord that's already in the layer's owned family.** Outer layers shouldn't reach into inner-layer territory and vice versa:
   - Layer 0 only: SUPER family
   - Layer 2: prefixed letters not yet claimed (see §4 + Omarchy claims), or unprefixed M-/C-M-/C-M-S-arrows
   - Layer 3: `<leader>` chords (Space-prefixed) or vim-mode-scoped CTRL chords
   - Layer 4: single letters, scoped to in-pane focus
3. **Check the matrix in §3 — if the chord is listed, you're about to overwrite it.** Either pick a different chord, or update the matrix and explain the new owner.
4. **For tmux plugins specifically: verify defaults against §4.** If a plugin's default chord is already taken, either remap via the plugin's `set -g @<plugin>-bind '<key>'` option or pick a different plugin.
5. **Re-run [`bin/keybind-audit`](omarchy-overrides/.config/bin/keybind-audit) after the change** and update the matrix if anything moved between cells.

## 6. The `omarchy-refresh-tmux` block

Omarchy ships an `omarchy-refresh-tmux` command (also reachable from `omarchy-menu` → Setup → Tmux refresh) that overwrites `~/.config/tmux/tmux.conf` with Omarchy's default. Because that path is a stow symlink into this repo, the command would erase the trailing `source-file ~/.config/tmux/tmux.user.conf` line that loads our TPM plugin layer.

To prevent this, the [`omarchy-overrides/`](omarchy-overrides/) stow package installs:

- A wrapper at `~/.config/bin/omarchy-refresh-tmux` that calls `notify-send -u critical` and exits 1.
- A systemd-user `PATH` prepend at `~/.config/environment.d/00-omarchy-overrides.conf` so `~/.config/bin` comes before `/usr/share/omarchy/bin`. This makes the wrapper shadow the real command for both interactive shells AND Hyprland-launched menu/walker invocations.

**To deliberately bypass the block** (e.g., you really do want to reset tmux to Omarchy's default), invoke the upstream binary by absolute path:

```bash
command /usr/share/omarchy/bin/omarchy-refresh-tmux
```

**After an Omarchy update, re-verify the block still works:**

```bash
which omarchy-refresh-tmux
# expect: /home/quomptrade/.config/bin/omarchy-refresh-tmux

omarchy-refresh-tmux
# expect: BLOCKED stderr message + exit code 1
```

If a future Omarchy update changes `omarchy-menu` to invoke the binary by absolute path (currently it's a relative call via PATH on line 592 of `omarchy-menu`), the PATH-shim will be bypassed for menu invocations. Mitigations in that case: (a) replace the upstream script with a no-op (ephemeral; resets on next Omarchy update), or (b) intercept the menu key at the Hyprland layer.

## 7. Audit methodology

To re-run a full audit:

### Quick: the aggregator script

```bash
~/.config/bin/keybind-audit > /tmp/audit.md
```

Produces a markdown report on stdout with sections for Hyprland (`hyprctl binds`), Ghostty (`config` keybind lines), tmux (`list-keys` if a server is up; otherwise static parse), Neovim (`nvim --headless` map dump), and the high-risk-chord checklist.

> [!NOTE]
> The aggregator has **no foot parser yet**, even though foot is now the default terminal.
> Its conclusions still hold because foot's bindings are deliberately identical to Ghostty's
> (§2), but read `foot/.config/foot/foot.ini` by hand until the script grows a section for it.

### Thorough: parallel exploration + targeted reads

When the stack changes meaningfully (e.g. a new TUI tool joins, an Omarchy update changes Hyprland defaults), launch parallel Explore agents with these scoped reads:

1. **Hyprland**: `omarchy-hyprland/.config/hypr/bindings.lua`, `hyprland.lua`, plus `/usr/share/omarchy/default/hypr/**/*.lua` for the Omarchy-shipped defaults. Under Omarchy 4 the `.conf` files are no longer read — `hyprctl binds` is the ground truth.
2. **Ghostty**: `ghostty/.config/ghostty/config` — grep `^[[:space:]]*keybind[[:space:]]*=`.
   **foot** (the current default terminal): `foot/.config/foot/foot.ini` — the `[key-bindings]`, `[search-bindings]`, `[url-bindings]`, `[mouse-bindings]` and `[text-bindings]` sections. Mirrors Ghostty by design, so audit the two together and mirror any change. Note the aggregator script does *not* yet parse foot.
3. **tmux**: `tmux/.config/tmux/tmux.conf` (Omarchy base) + `tmux/.config/tmux/tmux.user.conf` (plugin layer). For plugin defaults, read each plugin's README at `~/.config/tmux/plugins/<name>/README.md`.
4. **LazyVim**: `lazyvim/nvim/.config/nvim/lua/config/keymaps.lua` plus `lua/plugins/*.lua` (grep for `keys = {` tables).
5. **lazygit / lazydocker**: read `~/.config/{lazygit,lazydocker}/config.yml` if present, otherwise document the well-known defaults.
6. **herdr**: `herdr/.config/herdr/config.toml` — the `[keys]` table. Mirrors tmux by design, so audit the two together and mirror any change.

Each agent should return: chord families used, specific chords claimed, and any inheritance-from-defaults vs explicit-rebind. Aggregate into the matrix in §3.

## 8. Snapshot

This is a static snapshot of the audit results from 2026-05-05. The aggregator script provides an up-to-the-minute version on demand.

> [!NOTE]
> Re-verified 2026-08-22, after the Omarchy 4 upgrade and the Hyprland `.conf` → `.lua` port.
> All 27 of the original personal bindings were confirmed still reachable; 23 of them are now
> served by Omarchy 4's own defaults rather than by this repo. `hyprctl binds` remains the
> ground truth — the repo's `bindings.lua` intentionally holds only the 4 deviations.

| Layer | Chord families used | Conflicts found |
|---|---|---|
| Hyprland | `SUPER+letter`, `SUPER+SHIFT+letter`, `SUPER+CTRL+*`, `SUPER+arrows`, `SUPER+code:N`, `ALT+TAB`, media keys | NONE |
| Ghostty | `Shift+Insert`, `Ctrl+Insert`, `SUPER+CTRL+SHIFT+ALT+arrows` | NONE |
| foot | `Shift+Insert`, `Ctrl+Insert`, CSI-u `Shift+Return` / `Alt+Shift+Return` | NONE (mirrors Ghostty by design) |
| tmux (Omarchy base) | prefix=`C-Space`/`C-b`, prefix-letter (`c, C, h, k, K, m, P, N, q, r, R, v, x`), unprefixed `M-1..9` / `M-arrows` / `C-M-arrows` (user layer unbinds the shipped `C-M-S-arrows` resize) | NONE |
| tmux (plugin layer) | prefix-`Ctrl-s/r`, prefix-`O`, prefix-`Shift-P` / `Alt-P` / `Alt-Shift-P` / `Alt-c`, unprefixed `C-h/j/k/l` (navigator) + `M-h/j/k/l` (resize) | NONE (verified §4) |
| herdr | prefix=`C-Space` (mirrors tmux), `prefix+c/r/k` tabs, `alt+1..9`, `alt+arrows`, `ctrl+alt+arrows`, `ctrl+alt+shift+arrows` | NONE (mirrors tmux by design) |
| Neovim (LazyVim) | `<Space>`-leader chords, vim-mode-scoped CTRL/ALT chords | NONE |
| lazygit / lazydocker | single letters in focused pane | NONE |

**End state: zero MED/HIGH conflicts across the whole stack.**
