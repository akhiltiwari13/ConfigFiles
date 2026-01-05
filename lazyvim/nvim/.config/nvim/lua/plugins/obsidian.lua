return {
  "obsidian-nvim/obsidian.nvim",
  version = "v3.14.3", -- recommended, use latest release instead of latest commit
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  ---@module 'obsidian'
  ---@type obsidian.confg
  opts = {
    workspaces = {
      {
        name = "my-zettelkasten",
        path = "~/Work/notes",
      },
    },
    templates = {
      subdir = "obsidian-templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },
    daily_notes = {
      folder = "daily-notes",
      date_format = "%Y-%m-%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      -- alias_format = "%B %-d, %Y",
      alias_format = nil,
      default_tags = nil,
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil,
    },
    picker = { "folke/snacks.nvim" },
  },
}
