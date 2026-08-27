# LazyVim Configuration

## Overview

LazyVim distribution with custom plugins for Omarchy theme integration, note-taking, and file browsing.

## Structure

```
lua/
├── config/
│   ├── lazy.lua        # Bootstrap — DO NOT restructure
│   ├── options.lua     # Only override: relativenumber = false
│   ├── keymaps.lua     # Empty — uses LazyVim defaults
│   └── autocmds.lua    # Empty — uses LazyVim defaults
└── plugins/
    ├── theme.lua                      # SYMLINK → Omarchy theme state (untracked)
    ├── all-themes.lua                 # 10 themes pre-loaded lazily for hot-swap
    ├── omarchy-theme-hotreload.lua    # Reloads on User LazyReload autocmd
    ├── oil.lua                        # File explorer (- keymap)
    ├── obsidian.lua                   # Vault: ~/Work/notes, templates, daily notes
    ├── telescope.lua                  # + Zotero academic PDF integration
    ├── nvim-spider.lua                # Subword motions replace w/e/b
    ├── guess-indent.lua               # Auto-detect indentation
    ├── snacks-animated-scrolling-off.lua
    ├── disabled-defaults.lua          # Neo-tree override
    └── disable-news-alert.lua         # Suppresses LazyVim/Neovim news
plugin/after/
└── transparency.lua    # Makes 40+ highlight groups transparent (ColorScheme autocmd)
```

## Where to Look

| Task | File | Notes |
|------|------|-------|
| Add a plugin | `lua/plugins/<name>.lua` | Return LazyVim plugin spec table |
| Change theme | *not a file* | Run `omarchy theme set <name>` — see Theme Wiring below |
| Edit keybindings | `lua/config/keymaps.lua` | Currently empty, add vim.keymap.set calls |
| Obsidian vault path | `lua/plugins/obsidian.lua` | Hardcoded `~/Work/notes` |

## Theme Wiring

The colorscheme is owned by Omarchy, not by this repo. `lua/plugins/theme.lua` is an
**absolute symlink** to `~/.local/state/omarchy/current/theme/neovim.lua` and is
**gitignored** — it is machine state, so a fresh clone on the Mac/Ubuntu boxes simply
has no `theme.lua` and falls back to LazyVim's default colorscheme.

- **To change the theme:** `omarchy theme set <name>` — never edit `theme.lua`.
- **To recreate the link** on a fresh Omarchy box:
  `scripts/link_omarchy_nvim_theme.sh` (also run automatically by
  `scripts/bootstrap.sh omarchy`).
- **How the live swap works:** `omarchy theme set` restages the state file;
  lazy.nvim's reloader polls every 2s with `fs_stat`, which follows the symlink, and
  fires `User LazyReload`; `omarchy-theme-hotreload.lua` catches that, re-applies the
  colorscheme, and re-sources `plugin/after/transparency.lua`.
- Change detection is disabled under `nvim --headless` (`lazy/core/config.lua`), so
  hot-reload can only be observed in a real UI session.
- `all-themes.lua` preloads the theme plugins so a swap has something to load. Its
  list has drifted from what the stock themes actually name — e.g. `everforest` wants
  `neanias/everforest-nvim`, `nord` wants `EdenEast/nightfox.nvim`, and
  `bjarneo/aether.nvim` (the template fallback for the 7 themes shipping no
  `neovim.lua`) is absent. Switching to one of those needs a `:Lazy sync` + restart
  the first time.

## Conventions

- **Formatting**: `stylua` — 2 spaces, 120 col width (see `stylua.toml`)
- **Plugin spec**: Standard LazyVim format — `return { { "author/plugin", opts = {} } }`
- **Disable a plugin**: `if true then return {} end` at top of file
- **Backup a plugin**: Rename to `.lua_bkp` (see AI plugins below)
- **Neovim API types**: enabled via `.neoconf.json` at config root (neodev + lua_ls); editing files in `lua/` gives full `vim.*` autocomplete and hover types

## AI Plugins (Currently Disabled)

Both AI coding plugins are backed up (`.lua_bkp` extension), NOT active:
- `claudecode.lua_bkp` — Claude Code integration (`<leader>a*` bindings)
- `opencode.lua_bkp` — OpenCode integration (`<C-a>`, `<C-x>`, `<C-.>` bindings)

**Note**: `lazyvim.json` still lists `claudecode` in extras — inconsistent with backup state.
To re-enable: rename `.lua_bkp` → `.lua` and run `:Lazy sync`.

## LazyVim Extras Enabled

From `lazyvim.json`: **Languages**: clangd, cmake, docker, git, json, markdown, python, rust, toml, typescript, yaml, zig | **Editor**: inc-rename, neo-tree, mini-surround, yanky | **DAP**: core, nlua | **Test**: core | **UI**: treesitter-context | **Util**: dot

## Anti-Patterns

- **DO NOT** edit `lazy-lock.json` — gitignored, machine-specific
- **DO NOT** put plugin configs in `config/` — they go in `plugins/`
- **DO NOT** add keymaps inside plugin specs unless plugin-specific — use `config/keymaps.lua`
