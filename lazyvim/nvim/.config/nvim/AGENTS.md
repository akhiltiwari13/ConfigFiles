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
    ├── theme.lua                      # TokyoNight (active theme)
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
| Change theme | `lua/plugins/theme.lua` | Also check `all-themes.lua` for available options |
| Edit keybindings | `lua/config/keymaps.lua` | Currently empty, add vim.keymap.set calls |
| Obsidian vault path | `lua/plugins/obsidian.lua` | Hardcoded `~/Work/notes` |

## Conventions

- **Formatting**: `stylua` — 2 spaces, 120 col width (see `stylua.toml`)
- **Plugin spec**: Standard LazyVim format — `return { { "author/plugin", opts = {} } }`
- **Disable a plugin**: `if true then return {} end` at top of file (see `example.lua`)
- **Backup a plugin**: Rename to `.lua_bkp` (see AI plugins below)

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
